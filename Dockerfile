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
WORKDIR /app
RUN addgroup -S codapi && adduser -S codapi -G codapi
COPY --chown=codapi:codapi --from=builder /codapi /app/codapi
COPY --chown=codapi:codapi sandboxes /app/sandboxes
COPY --chown=codapi:codapi codapi.json /app/codapi.json
COPY --chown=codapi:codapi codapi-cli /app/codapi-cli
USER codapi
EXPOSE 1313
ENTRYPOINT ["/app/codapi"]
