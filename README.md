# lnreader-plugins-mirror

Salinan [lnreader/lnreader-plugins](https://github.com/lnreader/lnreader-plugins) (lisensi MIT, lihat `LICENSE`),
branch `plugins/v3.0.0`. Dipakai [Hub Reader](https://github.com/Bayu-Pasifik/hub-reader) sebagai repo plugin cadangan.

- Branch `plugins/v3.0.0` disinkronkan tiap hari oleh `.github/workflows/sync.yml` (`sync.sh`).
- URL kode di `.dist/plugins*.json` ditulis ulang ke repo ini supaya tetap jalan bila upstream hilang.
- Sinkron tidak memakai force-push dan dibatalkan bila jumlah plugin turun lebih dari 20% atau manifest kosong.
