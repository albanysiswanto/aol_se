# Lapar (Latihan Parenting)

**Lapar** adalah aplikasi edukatif berbasis Flutter dan Go yang dirancang untuk membantu orang tua dalam mengatur waktu layar anak serta memberikan kuis-kuis pembelajaran. Aplikasi ini memiliki dua peran utama: **Orang Tua** dan **Anak**.

## ✨ Fitur Utama

### 👨‍👩‍👧 Untuk Orang Tua:
- Menambahkan anak
- Mengundang anak melalui invite email
- Menambahkan soal (kuis)
- Menentukan waktu screen time untuk anak
- Melihat profil

### 🧒 Untuk Anak:
- Menerima undangan token dari orang tua (dikirim melalui email)
- Mengerjakan soal dari orang tua
- Melihat progress soal yang telah dikerjakan
- Melihat profil

## 🛠 Teknologi yang Digunakan
- **Flutter** – untuk antarmuka pengguna (Frontend)
- **Go** – untuk layanan backend (API dan logika bisnis)

## 🚀 Cara Instalasi dan Menjalankan

### Backend (Go)
1. Clone repository:
    ```bash
    git clone <repo-url>
    cd <nama-folder-backend>
    ```
2. Buat file `.env` sesuai kebutuhan (misalnya konfigurasi database, port, dll).
3. Jalankan aplikasi:
    ```bash
    go run main.go
    ```

### Frontend (Flutter)
1. Clone repository:
    ```bash
    git clone <repo-url>
    cd <nama-folder-frontend>
    ```
2. Install dependencies dan jalankan aplikasi:
    ```bash
    flutter pub get
    flutter run
    ```

## 📦 Contoh Penggunaan
1. Orang tua membuat akun dan mengundang anak melalui token.
2. Anak menerima token melalui email dan menggunakannya untuk bergabung.
3. Orang tua membuat soal dan mengatur waktu screen time anak.
4. Anak harus menyelesaikan kuis yang telah diberikan untuk mendapatkan waktu bermain.

## 👨‍💻 Kontributor
- Albany Siswanto – 2702304592  
- Djuhar Geusan Harum Manik – 2702324253  
- Naufal Ghifari Hidayat – 2702314460
