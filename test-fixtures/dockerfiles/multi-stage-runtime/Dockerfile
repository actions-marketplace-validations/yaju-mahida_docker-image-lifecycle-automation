FROM golang:1.23 AS build
WORKDIR /src
RUN echo build

FROM --platform=linux/amd64 alpine:3.20
COPY --from=build /src /app
