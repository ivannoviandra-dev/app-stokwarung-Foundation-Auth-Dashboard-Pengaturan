# 📝 Task List — Pembagian Kerja Tim StokWarung

> **Jumlah Anggota**: 3 orang  
> **Referensi**: [PRD_StokWarung.md](./PRD_StokWarung.md)

---

## 👥 Pembagian Anggota

| Anggota | Peran | Modul |
|---|---|---|
| **Anggota 1** | Foundation & Auth | Setup Project, Auth, Dashboard, Pengaturan |
| **Anggota 2** | Inventory | Manajemen Barang, Barcode, Reminder |
| **Anggota 3** | Transaction | Transaksi POS, Buku Utang, Laporan |

---

## 🏗️ Anggota 1 — Foundation, Auth, Dashboard, Pengaturan

### Setup Project & Design System
- [ ] Buat folder structure sesuai PRD (`features/`, `core/`, `app/`)
- [ ] Setup `pubspec.yaml` dengan semua dependencies
- [ ] Buat `theme.dart` — warna, typography, spacing, color palette
- [ ] Buat shared widgets: `AppButton`, `AppTextField`, `AppCard`
- [ ] Setup Google Fonts

### Routing & Navigasi
- [ ] Setup `go_router` dengan semua routes
- [ ] Route guard berdasarkan role (Owner/Kasir)
- [ ] Bottom Navigation Bar (Owner: 4 tab, Kasir: 3 tab)

### Firebase Setup
- [ ] Buat Firebase project di console
- [ ] Integrasi `firebase_core`, `firebase_auth`, `cloud_firestore`
- [ ] Setup Firestore security rules

### Autentikasi (AUTH-01 s/d AUTH-06)
- [ ] Halaman Login (email & password)
- [ ] Halaman Register Owner (nama toko, email, password)
- [ ] Lupa Password (reset via email)
- [ ] Auth service (login, register, logout, cek session)
- [ ] Splash screen + cek auth state
- [ ] Role-based redirect setelah login
- [ ] Form tambah akun Kasir (AUTH-03)

### Dashboard
- [ ] **Dashboard Owner** — 4 card (Laba Hari Ini, Total Barang, Transaksi Hari Ini, Total Piutang) + section alert barang
- [ ] **Dashboard Kasir** — Tombol "Mulai Transaksi", info transaksi hari ini, quick access
- [ ] Pull-to-refresh

### Pengaturan (SET-01 s/d SET-05)
- [ ] Profil toko (nama, alamat, no HP)
- [ ] Manajemen kasir (daftar, nonaktifkan, hapus)
- [ ] Ubah password
- [ ] Set stok minimum default
- [ ] Pengaturan reminder

### Polish
- [ ] Loading states, error handling, snackbar
- [ ] Animasi transisi antar halaman
- [ ] Empty states untuk semua list
- [ ] Test flow Owner & Kasir + permission guard

---

## 📦 Anggota 2 — Manajemen Barang, Barcode, Reminder

### Data Model & Repository
- [ ] Model `Barang` (entity + fromJson/toJson)
- [ ] Model `Kategori`
- [ ] Repository `BarangRepository` + Firestore datasource
- [ ] Struktur koleksi: `toko/{tokoId}/barang`, `toko/{tokoId}/kategori`

### Barcode Scanner
- [ ] Setup `mobile_scanner` package
- [ ] Buat `BarcodeService` wrapper
- [ ] Widget `BarcodeScannerView` reusable
- [ ] Handle permissions kamera

### CRUD Barang (STK-01 s/d STK-09)
- [ ] **Daftar Barang** — list + search + filter kategori + sorting
- [ ] **Tambah Barang** — form lengkap (nama, barcode scan/manual, kategori, satuan, harga beli, harga jual, auto margin, stok awal, stok minimum, tanggal kedaluwarsa) + validasi
- [ ] **Edit Barang** — pre-fill form + update Firestore
- [ ] **Hapus Barang** — konfirmasi dialog
- [ ] **Detail Barang** — semua info + margin (Rp & %) + tombol edit/hapus (Owner only)
- [ ] **Update Stok** — dialog tambah/kurangi stok (restock)
- [ ] **Kategori Barang** — CRUD kategori + default (Makanan, Minuman, Sembako, Rokok, Lainnya)

### Reminder & Notifikasi (REM-01 s/d REM-04)
- [x] Query barang stok ≤ minimum → alert stok rendah
- [x] Query barang kedaluwarsa ≤ 7 hari → klasifikasi 🟢🟡🔴
- [x] Badge count di ikon notifikasi
- [x] **Halaman Alert** — tab Stok Rendah & Kedaluwarsa + quick action
- [ ] Setup `flutter_local_notifications` + schedule daily check

### Polish
- [ ] Optimasi pencarian (debounce)
- [ ] Handle edge cases (barang tanpa exp, stok 0)
- [ ] Test CRUD + barcode + reminder

---

## 🛒 Anggota 3 — Transaksi POS, Buku Utang, Laporan

### Data Model & Repository
- [ ] Model `Transaksi` + `TransaksiItem`
- [ ] Model `Pelanggan` + `Utang`
- [ ] Repository interfaces + Firestore datasource
- [ ] Utility: format Rupiah, format tanggal Indonesia, kalkulasi margin/laba/kembalian

### Transaksi POS (TRX-01 s/d TRX-10)
- [ ] **Halaman POS** — search bar + scan barcode + keranjang
- [ ] **Keranjang** — list item, atur jumlah (+/−), hapus item, total otomatis
- [ ] **Pembayaran** — pilih metode (Tunai/Utang), input jumlah bayar + kembalian, pilih pelanggan jika utang
- [ ] **Simpan Transaksi** — simpan ke Firestore, kurangi stok otomatis, tampilkan ringkasan, reset keranjang
- [ ] **Riwayat Transaksi** — daftar hari ini + filter tanggal + detail (Owner only)

### Buku Utang Pelanggan (UTG-01 s/d UTG-07)
- [ ] **Tambah Pelanggan** — form nama + no HP
- [ ] **Daftar Pelanggan** — list + total utang + search + sorting
- [ ] **Detail Utang** — riwayat utang & bayar per pelanggan (timeline)
- [ ] **Bayar Utang** — form jumlah + keterangan, bayar sebagian/lunas
- [ ] Total piutang keseluruhan (Owner only)

### Laporan (LAP-01 s/d LAP-07)
- [ ] **Laba Harian** — total penjualan, modal, laba bersih, jumlah transaksi, breakdown tunai/utang
- [ ] **Penjualan Harian** — daftar transaksi per hari + date picker
- [ ] **Laporan Mingguan** — grafik tren 7 hari (`fl_chart`)
- [ ] **Laporan Bulanan** — ringkasan per bulan
- [ ] **Barang Terlaris** — ranking top 10
- [ ] **Barang Margin Tertinggi** — ranking top 10
- [ ] **Export PDF** — generate & share laporan (`pdf` + `printing` package)

### Polish
- [ ] Test flow transaksi (tunai & utang)
- [ ] Test buku utang (catat, bayar, lunas)
- [ ] Test laporan dengan data nyata

---

## 🔗 Dependencies Antar Anggota

> **Anggota 1 harus setup project & auth terlebih dahulu**, baru Anggota 2 & 3 bisa mulai kerja di modul masing-masing.

```
Anggota 1 (Setup + Auth)  ──► Anggota 2 & 3 (butuh project structure & Firebase)
Anggota 2 (Data Barang)   ──► Anggota 3    (POS butuh data barang untuk keranjang)
Anggota 3 (Transaksi)     ──► Anggota 3    (Utang & Laporan butuh data transaksi)
Anggota 2 (Reminder)      ──► Anggota 1    (Dashboard butuh data alert)
```

---

## 📋 Git Branching

```
main ── develop ─┬─ feature/auth         ← Anggota 1
                 ├─ feature/dashboard    ← Anggota 1
                 ├─ feature/settings     ← Anggota 1
                 ├─ feature/barang       ← Anggota 2
                 ├─ feature/barcode      ← Anggota 2
                 ├─ feature/reminder     ← Anggota 2
                 ├─ feature/transaksi    ← Anggota 3
                 ├─ feature/utang        ← Anggota 3
                 └─ feature/laporan      ← Anggota 3
```

---

## ✅ Checklist Sebelum Release

- [ ] Login & register berjalan normal
- [ ] Role Owner & Kasir sesuai permission
- [ ] CRUD barang tanpa bug
- [ ] Scan barcode berfungsi
- [ ] Transaksi tunai & utang lancar
- [ ] Buku utang tercatat & bisa dibayar
- [ ] Laporan laba harian data benar
- [ ] Reminder stok & kedaluwarsa muncul
- [ ] Tidak ada crash / error fatal
- [ ] UI konsisten & responsif

---

*Dibuat pada: 5 Juni 2026*
