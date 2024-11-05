# Stage 1: Build MongoDB tools on Ubuntu
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS mongo-tools-builder

# Set MongoDB tools version as a build argument
ARG MONGODB_TOOLS_VERSION=100.8.0
ARG TARGETOS
ARG TARGETARCH

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    libkrb5-dev \
    golang-go \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for Go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Clone the MongoDB tools repository
RUN git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION /go/mongo-tools

# Set working directory
WORKDIR /go/mongo-tools

# List of MongoDB tools to build
ENV TOOLS="bsondump mongoimport mongoexport mongodump mongorestore mongostat mongofiles mongotop"

# Conditionally build tools for each architecture
RUN for tool in $TOOLS; do \
    if [ "$TARGETARCH" = "amd64" ]; then \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /build/$tool -ldflags "-X main.VersionStr=$MONGODB_TOOLS_VERSION -X main.GitCommit=$(git rev-parse HEAD)" -tags "ssl sasl gssapi failpoints" $tool/main/$tool.go; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /build/$tool -ldflags "-X main.VersionStr=$MONGODB_TOOLS_VERSION -X main.GitCommit=$(git rev-parse HEAD)" -tags "ssl sasl failpoints" $tool/main/$tool.go; \
    else \
    echo "Unsupported architecture: $TARGETARCH"; \
    exit 1; \
    fi; \
    done

# Stage 2: Create the final lightweight image with MongoDB tools
FROM alpine:3.18

# Install only necessary libraries for MongoDB tools to run
RUN apk add --no-cache \
    libc6-compat \
    krb5-libs \
    ca-certificates

# Copy the MongoDB tools from the build stage
COPY --from=mongo-tools-builder /build/* /usr/bin/

# Verify the installation by displaying the version of each tool
RUN for tool in bsondump mongoimport mongoexport mongodump mongorestore mongostat mongofiles mongotop; do \
    /usr/bin/$tool --version || echo "$tool not found"; \
    done
