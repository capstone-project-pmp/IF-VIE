# 📱 Aplikasi Dating Mahasiswa / Campusync (Flutter + Firebase)

Aplikasi dating sederhana Campusync berbasis Flutter untuk mahasiswa di seluruh Indonesia. Aplikasi ini menggunakan integrasi Google Sign-In, Firebase, dan Cloudinary untuk fitur login, pembuatan profil, pencarian teman, serta sistem *like* dan *match*.

## Anggota Kelompok 3 : 
   - Dewanda Camilla Zahra   220660121145 
   - Silmi Ainun Ashafani    220660121055 
   - Iqbal Hakim Nugraha     220660121147 
   - Muhammad Reza Fadlillah 230660121146 

---

## 🚀 Fitur Utama

### 🔐 Autentikasi & Profil
- Login menggunakan akun Google
- Pengisian data profil:
  - Nama lengkap
  - Username
  - Universitas (seluruh kampus di Indonesia)
  - Program studi (Prodi)
  - Gender
  - Hoby
  - Kategori umur

### 🏠 Halaman Beranda
- Menampilkan foto profil pengguna lain
- Klik kartu profil untuk:
  - Melihat detail profil
  - Memberi *like*
  - Membuka halaman chat (non-realtime)

### ❤️ Match & Geser Profil
- Swipe kanan/kiri untuk melihat pengguna lain
- Bisa *like* untuk menyukai
- Match bersifat acak dari pengguna yang terdaftar

### 💬 Riwayat & Chat
- Menampilkan riwayat percakapan (non-realtime)
- Menampilkan foto, nama, dan info pengguna
- Fitur edit profil & data diri

### 🔍 Pencarian & Filter
- Cari pengguna berdasarkan nama universitas
- Fitur pencarian dan filter berdasarkan:
  - Prodi
  - Gender
  - Kategori umur

### 🔔 Notifikasi (Manual)
- Notifikasi *like* dari pengguna lain (tidak menggunakan FCM)
- Notifikasi chat **tidak tersedia**

### ⚙️ Pengaturan & Navigasi
- Menu tiga titik di pojok aplikasi:
  - Teman:
    - Daftar pengguna yang kamu sukai
    - Daftar pengguna yang menyukai kamu
  - Pengaturan:
    - Logout
    - Hapus akun
  - Pusat Bantuan

---

## 🖼️ Manajemen Gambar
- Menggunakan **Cloudinary** untuk upload dan menampilkan foto profil

---

## 🔧 Teknologi yang Digunakan

- **Flutter** – Antarmuka pengguna
- **Firebase** – Auth, Firestore, dan Storage
- **Cloudinary** – Manajemen gambar

---

## 🛠️ Cara Menjalankan

```bash

git clone https://github.com/campusyn/IF-VIE.git
cd Kelompok_3/Source_Code/campusync
flutter pub get
flutter run
