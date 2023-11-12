# Start with the official Go image
FROM golang:1.21.3 as builder

# Set build arguments and environment variables
ARG TARGETARCH
ENV GOARCH=$TARGETARCH

# Set the working directory inside the container
WORKDIR /go/src/github.com/jmorganca/ollama

# Install additional dependencies if needed
RUN apt-get update && apt-get install -y git build-essential cmake

# Copy your source code into the container
COPY . .

# Generate and build your application
RUN go generate ./... \
    && go build -ldflags '-w -s' .



# Final Stage
FROM ubuntu:20.04

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


