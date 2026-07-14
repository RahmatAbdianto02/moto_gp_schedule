# 🏍️ MotoGP Schedule App

Aplikasi Android untuk agregasi jadwal MotoGP dengan fitur notifikasi pengingat sesi. Dibangun menggunakan Flutter dengan arsitektur MVVM + Repository Pattern.

---

## 📱 Fitur

- **Jadwal GP** — Daftar semua event MotoGP season berjalan, diambil langsung dari API resmi MotoGP
- **Detail Sesi** — FP1, FP2, Qualifying, Sprint, Race lengkap dengan status (Upcoming / Berlangsung / Selesai)
- **Zona Waktu** — Pilih tampilan waktu dalam WIB, WITA, atau WIT
- **Notifikasi Pengingat** — Set multiple reminder per sesi (10, 15, 30, 60, atau 120 menit sebelum sesi dimulai)
- **Offline Support** — Data di-cache lokal, app tetap bisa dibuka tanpa internet
- **Neobrutalist UI** — Desain bold dengan border hitam tebal, shadow offset, dan palet merah-kuning

---

## 🛠️ Tech Stack

| Kategori | Teknologi |
|----------|-----------|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Database Lokal | sqflite |
| Notifikasi | flutter_local_notifications |
| HTTP Client | http |
| Timezone | timezone |
| Arsitektur | MVVM + Repository Pattern |

---

## 🗂️ Struktur Folder

```
lib/
├── core/
│   ├── constants/        # Warna, tema, konstanta API
│   └── notifications/    # Helper notifikasi
├── data/
│   ├── models/           # Model class (CachedEvent, CachedSession, Reminder)
│   ├── datasources/
│   │   ├── local/        # SQLite operations
│   │   └── remote/       # API fetch
│   └── repositories/     # Business logic layer
└── presentation/
    ├── providers/         # ScheduleProvider, ReminderProvider
    ├── screens/           # Home, Jadwal, Detail
    └── widgets/           # NeoLoading, komponen reusable
```

---

## 🔌 Data Source

App menggunakan API tidak resmi dari MotoGP yang didokumentasikan komunitas:

- **Referensi:** [robschmitt/MotoGP-API](https://github.com/robschmitt/MotoGP-API)
- **Base URL:** `https://api.motogp.pulselive.com/motogp/v1`
- **Endpoint yang dipakai:**
  - `GET /results/seasons` — ambil season aktif
  - `GET /events?seasonYear={year}` — ambil semua event + sesi

Data di-cache lokal selama 24 jam. Jika fetch gagal, app fallback ke cache terakhir.

---

## 🏗️ Arsitektur

```
UI (Widgets)
    ↕ context.watch / context.read
Provider (ChangeNotifier)
    ↕ method calls
Repository
    ↕                    ↕
Remote DataSource    Local DataSource
(HTTP + JSON)        (SQLite)
```

Setiap layer hanya mengenal layer di sebelahnya — UI tidak tahu dari mana data berasal, apakah dari internet atau database lokal.

---

## ⚙️ Cara Jalankan

### Prerequisites
- Flutter SDK 3.x
- Android device / emulator (Android 8.0+)

### Langkah

```bash
# Clone repo
git clone https://github.com/RahmatAbdianto02/moto_gp_schedule.git
cd moto_gp_schedule

# Install dependencies
flutter pub get

# Jalankan app
flutter run
```

---

## 📋 Known Limitations

- API MotoGP yang dipakai adalah unofficial/hidden API — tidak ada SLA dan bisa berubah sewaktu-waktu
- Jika jadwal sesi berubah (reschedule), waktu reminder yang sudah di-set tidak otomatis terupdate
- Notifikasi exact alarm membutuhkan izin tambahan di Android 12+
- Fitur hasil balapan (fastest lap, klasemen) belum diimplementasi di versi ini

---

## 🗺️ Roadmap

- [ ] Fitur fastest lap FP1/FP2/FP3
- [ ] Catatan waktu kualifikasi
- [ ] Klasemen rider & konstruktor
- [ ] Widget homescreen Android
- [ ] Daftar rider & tim

---

## 👨‍💻 Developer

**Rahmat Abdianto**
Flutter Developer — Palu, Sulawesi Tengah

---

## 📄 Lisensi

MIT License — bebas digunakan dan dimodifikasi.
