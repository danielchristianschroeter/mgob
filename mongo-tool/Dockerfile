FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.18 AS mongo-tools-builder

ARG MONGODB_TOOLS_VERSION=100.8.0
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git build-base krb5-dev
RUN apk add --no-cache git build-base krb5-dev libc-dev gcc musl-dev && \
    git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION

WORKDIR /go/mongo-tools

RUN CGO_ENABLED=1 GOOS=$TARGETOS GOARCH=$TARGETARCH ./make build
