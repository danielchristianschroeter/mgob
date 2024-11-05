FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.18 AS mongo-tools-builder

ARG MONGODB_TOOLS_VERSION=100.8.0
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git build-base

# Install krb5-dev only for amd64
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    apk add --no-cache krb5-dev; \
    fi

RUN git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION /go/mongo-tools

WORKDIR /go/mongo-tools

# Set environment variables for cross-compilation
ENV CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}

# Build MongoDB tools
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    go run build.go build -tags "ssl sasl failpoints" ; \
    else \
    go run build.go build -tags "ssl sasl gssapi failpoints" ; \
    fi