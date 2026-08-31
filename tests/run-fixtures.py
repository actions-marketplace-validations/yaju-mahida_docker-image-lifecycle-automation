#!/usr/bin/env python3
"""Run deterministic composite-action fixtures without a production repository."""

from __future__ import annotations

import argparse
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "test-fixtures"


class FixtureFailure(RuntimeError):
    """A fixture's observed behavior did not match its declared contract."""


def action_script(action: str) -> str:
    action_file = ROOT / ".github" / "actions" / action / "action.yml"
    action_definition = yaml.safe_load(action_file.read_text(encoding="utf-8"))
    steps = action_definition["runs"]["steps"]
    if len(steps) != 1 or "run" not in steps[0]:
        raise FixtureFailure(f"{action} must expose one shell run step for fixture execution")
    return steps[0]["run"]


def parse_outputs(path: Path) -> dict[str, str]:
    outputs: dict[str, str] = {}
    if not path.exists():
        return outputs
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            outputs[key] = value
    return outputs


def git(command: list[str], cwd: Path) -> None:
    subprocess.run(["git", *command], cwd=cwd, check=True, capture_output=True, text=True)


def shell_path(path: Path) -> str:
    """Return a path accepted by Bash started from this Python process."""
    if os.name != "nt":
        return str(path)
    return subprocess.run(
        ["cygpath", "-u", str(path)], check=True, capture_output=True, text=True
    ).stdout.strip()


def initialize_git_repository(workspace: Path, history: dict[str, Any]) -> None:
    git(["init", "--quiet"], workspace)
    git(["config", "user.email", "fixture@example.invalid"], workspace)
    git(["config", "user.name", "Fixture Runner"], workspace)
    (workspace / ".fixture").write_text("fixture\n", encoding="utf-8")
    git(["add", ".fixture"], workspace)
    git(["commit", "--quiet", "-m", "fixture: initial state"], workspace)
    for tag in history.get("tags", []):
        git(["tag", tag], workspace)

    remote = workspace.parent / "origin.git"
    subprocess.run(["git", "init", "--bare", "--quiet", str(remote)], check=True)
    git(["remote", "add", "origin", "../origin.git"], workspace)
    git(["push", "--quiet", "origin", "HEAD", "--tags"], workspace)


def assert_expected(
    fixture: Path, expected: dict[str, Any], exit_code: int, outputs: dict[str, str], combined: str
) -> None:
    if exit_code != expected.get("exit_code", 0):
        raise FixtureFailure(
            f"{fixture}: expected exit {expected.get('exit_code', 0)}, got {exit_code}\n{combined}"
        )
    for key, value in expected.get("outputs", {}).items():
        actual = outputs.get(key, "")
        if str(value) != actual:
            raise FixtureFailure(
                f"{fixture}: output {key!r}: expected {value!r}, got {actual!r}\n{combined}"
            )
    for text in expected.get("stdout_contains", []):
        if text not in combined:
            raise FixtureFailure(f"{fixture}: expected output to contain {text!r}\n{combined}")


def run_fixture(fixture: Path) -> None:
    definition = yaml.safe_load((fixture / "expected-results.yml").read_text(encoding="utf-8"))
    action = definition["action"]
    expected = definition["expected"]
    # Git for Windows can briefly retain a handle to a just-used working
    # directory. Ignoring only cleanup errors on Windows keeps that platform
    # quirk from hiding fixture assertion failures; Linux CI stays strict.
    with tempfile.TemporaryDirectory(
        prefix="docker-image-lifecycle-automation-",
        ignore_cleanup_errors=os.name == "nt",
    ) as temp:
        workspace = Path(temp) / "workspace"
        workspace.mkdir()
        for item in fixture.iterdir():
            if item.name != "expected-results.yml":
                destination = workspace / item.name
                if item.is_dir():
                    shutil.copytree(item, destination)
                else:
                    # Fixtures are source data, so write their text through
                    # the repository's LF policy regardless of host OS.
                    destination.write_text(item.read_text(encoding="utf-8"), encoding="utf-8", newline="\n")
        for shim in (workspace / "bin").glob("*") if (workspace / "bin").exists() else []:
            shim.chmod(shim.stat().st_mode | 0o111)
        for shim in (fixture / "bin").glob("*") if (fixture / "bin").exists() else []:
            shim.chmod(shim.stat().st_mode | 0o111)
        history = definition.get("history")
        if history is not None:
            initialize_git_repository(workspace, history)

        output_file = workspace / "github-output"
        summary_file = workspace / "github-summary"
        script_file = workspace / "fixture-action.sh"
        script_environment = {
            **{key: str(value) for key, value in definition.get("inputs", {}).items()},
            # These are relative to the temporary workspace, avoiding
            # platform-specific path conversion between Python and Bash.
            "GITHUB_OUTPUT": output_file.name,
            "GITHUB_STEP_SUMMARY": summary_file.name,
        }
        # Use the checked-out fixture directory for executable shims. A
        # Windows temporary workspace may be remapped by MSYS, whereas this
        # repository path has a stable POSIX representation.
        shim_path = shell_path(fixture / "bin") if (fixture / "bin").exists() else ""
        shim_export = (
            f"export PATH={shlex.quote(shim_path)}:/usr/local/bin:/usr/bin:/bin:$PATH\n"
            if shim_path
            else ""
        )
        shim_assertions = ""
        if (fixture / "bin" / "curl").exists():
            shim_assertions = 'test "$(command -v curl)" = "$FIXTURE_CURL"\n'
            script_environment["FIXTURE_CURL"] = f"{shim_path}/curl"
        exports = "\n".join(
            f"export {key}={shlex.quote(value)}" for key, value in script_environment.items()
        )
        script_file.write_text(
            f"#!/usr/bin/env bash\n{shim_export}{exports}\n{shim_assertions}{action_script(action)}",
            encoding="utf-8",
            newline="\n",
        )
        result = subprocess.run(
            ["bash", script_file.name],
            cwd=workspace,
            text=True,
            capture_output=True,
        )
        shim_log = workspace / "curl.log"
        evidence = result.stdout + result.stderr
        if shim_log.exists():
            evidence += "\nFixture curl calls:\n" + shim_log.read_text(encoding="utf-8")
        assert_expected(
            fixture,
            expected,
            result.returncode,
            parse_outputs(output_file),
            evidence,
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite", action="append", help="Fixture suite to run (repeatable)")
    arguments = parser.parse_args()
    fixtures = sorted(FIXTURES.glob("*/**/expected-results.yml"))
    if arguments.suite:
        wanted = set(arguments.suite)
        fixtures = [path for path in fixtures if path.parent.parent.name in wanted]
    if not fixtures:
        raise FixtureFailure("No fixtures selected.")

    failures: list[str] = []
    for expected_results in fixtures:
        fixture = expected_results.parent
        try:
            run_fixture(fixture)
            print(f"PASS {fixture.relative_to(ROOT)}")
        except (FixtureFailure, subprocess.CalledProcessError) as error:
            failures.append(str(error))
            print(f"FAIL {fixture.relative_to(ROOT)}: {error}", file=sys.stderr)
    if failures:
        print(f"{len(failures)} fixture(s) failed.", file=sys.stderr)
        return 1
    print(f"{len(fixtures)} fixture(s) passed.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except FixtureFailure as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(2)
