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
COPY --from=builder /codapi /app/codapi
COPY sandboxes /app/sandboxes
COPY codapi.json /app/codapi.json
USER codapi
EXPOSE 1313
ENTRYPOINT ["/app/codapi"]
