# Use an Ubuntu base image with a specified platform
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS mongo-tools-builder

# Set the MongoDB tools version as a build argument
ARG MONGODB_TOOLS_VERSION=100.8.0

# Set build architecture and OS
ARG TARGETOS
ARG TARGETARCH

# Install dependencies for building MongoDB tools and Go
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libkrb5-dev \
    golang-go \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set the Go environment variables
ENV GOPATH=/go PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH}

# Clone the MongoDB tools repository
RUN git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION /go/mongo-tools

# Set the working directory
WORKDIR /go/mongo-tools

# Conditionally build MongoDB tools based on architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    TOOLS="bsondump mongoimport mongoexport mongodump mongorestore mongostat mongofiles mongotop"; \
    for tool in $TOOLS; do \
    go build -o bin/$tool -ldflags "-X main.VersionStr=$MONGODB_TOOLS_VERSION -X main.GitCommit=$(git rev-parse HEAD)" -tags "ssl sasl gssapi failpoints" $tool/main/$tool.go; \
    done; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    TOOLS="bsondump mongoimport mongoexport mongodump mongorestore mongostat mongofiles mongotop"; \
    for tool in $TOOLS; do \
    go build -o bin/$tool -ldflags "-X main.VersionStr=$MONGODB_TOOLS_VERSION -X main.GitCommit=$(git rev-parse HEAD)" -tags "ssl sasl failpoints" $tool/main/$tool.go; \
    done; \
    else \
    echo "Unsupported architecture: $TARGETARCH"; \
    exit 1; \
    fi && \
    apt-get remove -y golang-go git build-essential && \
    apt-get autoremove -y && \
    rm -rf /go/pkg /var/lib/apt/lists/*
