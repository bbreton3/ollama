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



FROM ubuntu:22.04
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=0 /go/src/github.com/jmorganca/ollama/ollama /bin/ollama
COPY pull-model.sh /bin/pull-model.sh 
RUN chmod +x /bin/pull-model.sh


# Launch the download of the model using the script
RUN /bin/pull-model.sh

EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]

