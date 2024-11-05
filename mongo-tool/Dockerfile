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
    ca-certificates \
    libc6 \
    libgssapi-krb5-2 \
    libkrb5-3 \
    libk5crypto3 \
    libcomerr2 \
    libkrb5support0 \
    libkeyutils1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the Go environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Clone the MongoDB tools repository
RUN git clone https://github.com/mongodb/mongo-tools.git --depth 1 -b $MONGODB_TOOLS_VERSION /go/mongo-tools

# Set the working directory
WORKDIR /go/mongo-tools

# Build MongoDB tools
RUN CI=1 EVG_VARIANT=ubuntu2204 go run build.go build