# moto_gp_schedule

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Saya pilih sessionId sebagai string reference di Reminder, bukan IsarLink ke CachedSession. Alasannya: kalau cache di-refresh (data lama dihapus, data baru masuk), IsarLink akan putus dan reminder jadi orphan. Dengan string reference + data ter-denormalize (sessionName, eventName, sessionStartUtc disalin langsung ke Reminder), reminder tetap valid meski CachedSession aslinya sudah diganti.
Trade-off: kalau ada perubahan jadwal (misal sesi reschedule), sessionStartUtc di Reminder bisa jadi tidak sinkron dengan CachedSession yang baru. Untuk MVP ini saya anggap acceptable — itu edge case yang jarang terjadi (reschedule sesi MotoGP tidak sering)