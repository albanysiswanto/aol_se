# Build stage (Menggunakan Go 1.24)
FROM golang:1.24 AS builder

# Set working directory
WORKDIR /app

# Copy semua file proyek
COPY . .

# Download dependencies
RUN go mod tidy

# Build static binary tanpa CGO
RUN CGO_ENABLED=0 go build -o lapar_backend

# Final stage: Menggunakan Alpine yang ringan
FROM alpine:latest

# Set working directory
WORKDIR /root/

# Copy binary hasil build
COPY --from=builder /app/lapar_backend .

# Jalankan aplikasi
CMD ["/root/lapar_backend"]
