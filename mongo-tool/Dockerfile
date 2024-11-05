FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.18 AS mongo-tools-builder

ARG MONGODB_TOOLS_VERSION=100.8.0
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git build-base krb5-dev

RUN git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION /go/mongo-tools

WORKDIR /go/mongo-tools

# Set environment variables for cross-compilation
ENV CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}

# Build MongoDB tools
RUN go run build.go build