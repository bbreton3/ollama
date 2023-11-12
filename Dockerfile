# Build Stage
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as builder

ARG TARGETARCH
ARG GOFLAGS="'-ldflags=-w -s'"

WORKDIR /go/src/github.com/jmorganca/ollama
RUN apt-get update && apt-get install -y git build-essential cmake
ADD https://dl.google.com/go/go1.21.3.linux-$TARGETARCH.tar.gz /tmp/go1.21.3.tar.gz
RUN mkdir -p /usr/local && tar xz -C /usr/local </tmp/go1.21.3.tar.gz

COPY . .
ENV GOARCH=$TARGETARCH
ENV GOFLAGS=$GOFLAGS
RUN /usr/local/go/bin/go generate ./... \
    && /usr/local/go/bin/go build .

# Final Stage
FROM alpine:latest

# Install ca-certificates and other necessary tools
RUN apk --no-cache add ca-certificates

# Copy the built binary and other necessary files from the builder stage
COPY --from=builder /go/src/github.com/jmorganca/ollama/ollama /bin/ollama
COPY pull-model.sh /bin/pull-model.sh 
RUN chmod +x /bin/pull-model.sh

# Diagnostic step: Uncomment to check for missing libraries
# RUN ldd /bin/ollama || true

# Launch the download of the model using the script
RUN /bin/pull-model.sh

EXPOSE 11434

# Set the necessary environment variable
ENV OLLAMA_HOST 0.0.0.0

ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]


