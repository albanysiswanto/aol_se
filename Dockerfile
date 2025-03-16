# Gunakan image base Go untuk membangun aplikasi
FROM golang:1.24 AS builder

# Set working directory di dalam container
WORKDIR /app

# Copy dependency files terlebih dahulu untuk caching lebih baik
COPY go.mod go.sum ./

# Download dependencies
RUN go mod tidy

# Copy semua file source code ke dalam container
COPY . .

# Build aplikasi dengan nama 'lapar_backend'
RUN go build -o lapar_backend

# Gunakan image ringan untuk menjalankan aplikasi
FROM gcr.io/distroless/base-debian11

# Set working directory
WORKDIR /root/

# Copy binary dari tahap build
COPY --from=builder /app/lapar_backend .

# Tentukan port aplikasi (Opsional, tetapi direkomendasikan)
EXPOSE 2020

# Jalankan aplikasi dengan ENTRYPOINT
ENTRYPOINT ["/root/lapar_backend"]
