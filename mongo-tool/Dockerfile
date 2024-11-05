# Use an Ubuntu base image with a specified platform
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS mongo-tools-builder

# Set the MongoDB tools version as a build argument
ARG MONGODB_TOOLS_VERSION=100.8.0

# Install dependencies for building MongoDB tools and Go
RUN apt-get update && \
    apt-get install -y --no-install-recommends git build-essential libkrb5-dev golang-go && \
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
RUN ./make build