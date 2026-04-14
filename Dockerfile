FROM golang:alpine AS builder
 
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/main.go
 
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata curl && \
    curl -L -o sing-box.tar.gz https://github.com/SagerNet/sing-box/releases/download/v1.13.7/sing-box-1.13.7-linux-amd64-musl.tar.gz && \
    tar -xzf sing-box.tar.gz && \
    mv sing-box-1.13.7-linux-amd64-musl/* /usr/local/bin/ && \
    rm -rf sing-box.tar.gz sing-box-1.13.7-linux-amd64-musl
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/source ./source
 
ENV APP_DATA_DIR=/app
RUN mkdir -p /app/app_data
EXPOSE 8080
CMD ["./main"]