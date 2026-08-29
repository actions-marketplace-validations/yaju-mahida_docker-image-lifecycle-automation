# Test Fixtures

Each fixture is an isolated, declarative contract for one composite action.
`expected-results.yml` supplies action environment inputs, optional disposable
Git history, expected exit status, action outputs, and diagnostic fragments.

Run deterministic fixtures locally:

```bash
python3 tests/run-fixtures.py
python3 tests/run-fixtures.py --suite dockerfiles
```

Fixtures never use production repositories, production credentials, or mutable
public image digests. OCI protocol behavior that needs a registry is tested by
the local OCI integration lane; a separate smoke test validates the public
Marketplace action against Docker Hub.

`build-arg-unresolved` is intentionally an expected failure. Build-argument
resolution is not a v1 capability and must not be represented as supported.
