# syntax=docker/dockerfile:1

# Build stage
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /codapi ./cmd/main.go

# Runtime stage
FROM alpine:latest

# The GID of the docker group on the host.
# Will be passed in as a build-arg.
ARG DOCKER_GID=988

WORKDIR /app
RUN apk update && apk add --no-cache docker-cli bash curl tar

# Create a docker group with the same GID as the host's docker group
RUN addgroup -S -g ${DOCKER_GID} docker

# Create the codapi user and add it to the new docker group
RUN adduser -S -G docker codapi

COPY --from=builder /codapi /app/codapi
COPY sandboxes /app/sandboxes
COPY codapi.json /app/codapi.json

# Switch to the non-root user
USER codapi
EXPOSE 1313
ENTRYPOINT ["/app/codapi"]
