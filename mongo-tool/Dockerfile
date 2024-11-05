FROM golang:1.21-alpine3.18 AS mongo-tools-builder

ARG MONGODB_TOOLS_VERSION=100.8.0

RUN apk add --no-cache git build-base krb5-dev && \
    git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION

WORKDIR /go/mongo-tools
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    CI=1 EVG_VARIANT=ubuntu2204 go run build.go build; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    CI=1 EVG_VARIANT=ubuntu2204-arm64 go run build.go build; \
    else \
    echo "Unsupported architecture: $TARGETARCH"; \
    exit 1; \
    fi