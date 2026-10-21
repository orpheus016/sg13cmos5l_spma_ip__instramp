# Changelog & Troubleshooting: PEX Mode RC untuk `gain_ota`

Dokumen ini mencatat diagnosa akar masalah (*root causes*), perubahan script, dan langkah verifikasi yang dilakukan untuk memungkinkan ekstraksi parasitik resistansi + kapasitansi (PEX RC via Magic `extresist`) dan karakterisasi post-layout CACE pada sel analog **`gain_ota`** (proses IHP SG13CMOS5L).

---

## 1. Ringkasan Masalah Awal

Pada saat karakterisasi skematik dan post-layout C (hanya kapasitansi via KPEX 2.5D), seluruh pengujian lulus:
- **Skematik CACE**: 44/44 parameter **Pass ✅** (`runs/RUN_2026-10-21_06-34-59/summary.md`).
- **Post-Layout C**: 40/40 parameter **Pass ✅** (`runs/pex_cace/gain_ota/RUN_2026-10-21_07-35-21/summary.md`).

Namun, saat ekstraksi dan simulasi post-layout RC (`gain_ota.rc.spice`) dijalankan:
- Open-loop gain runtuh menjadi $A_0 = -0.865\text{ dB}$ (seharusnya $\approx 62\text{ dB}$).
- Phase Margin (PM) rusak ($10925^\circ$), Gain Margin (GM) dan GBW bernilai kosong (`Error ❗`).
- ngspice melaporkan `Warning: singular matrix: check node x2.pn19`. Dynamic gmin stepping dan source stepping gagal.
- Titik kerja DC bergeser drastis: $I_Q = 258\,\mu\text{A}$ (skematik $74\,\mu\text{A}$), $V_{OS} = 91\text{ mV}$ (skematik $0.69\text{ mV}$).

---

## 2. Diagnosa Akar Masalah Teknis

### A. Sambungan Terminal Kapasitor MoM Terputus (`pn1` vs `V_out`)
- **Letak Bug**: [scripts/pex_prepare_gds.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_prepare_gds.py)
- **Mekanisme**:
  Kompensasi Miller pada `gain_ota` menggunakan empat unit kapasitor $8.5\,\mu\text{m} \times 8.5\,\mu\text{m}$ ($XC4$, $m=4$) yang dipasang seri dengan resistor nol $R_z$ ($R2$).
  Pada layout, rute top-level menuju output terhubung ke kapasitor pada **Metal 3**.
  Script `pex_prepare_gds.py` sebelumnya menghapus *semua* Metal 1–3 dan Via 1–3 di dalam sel `cap_cmomi`, dan hanya menyisakan batang Metal 4 ($\ge 0.4\,\mu\text{m}$).
  Akibatnya, tumpukan via vertikal dari Metal 4 ke Metal 3 terputus!
  Saat Magic membaca titik koordinat terminal, Magic mendeteksi batang Metal 4 tersebut sebagai simpul mengambang `pn1` (bukan `V_out`):
  ```text
  # raw.spice.capnodes (sebelum perbaikan):
  pn6 pn1
  pn6 pn1
  pn6 pn1
  pn6 pn1
  pn13 V_out
  ```
  Di netlist RC, $XC4$ terpasang ke simpul `pn1` yang tidak terhubung ke sirkuit (loop terbuka), sehingga loop gain runtuh total.

### B. Floating Node & Singular Matrix pada Resistor Poly (`pn18`, `pn19`)
- **Letak Bug**: [scripts/pex_magic.tcl](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_magic.tcl)
- **Mekanisme**:
  Magic mengekstrak tubuh material resistor `rhigh` sebagai layer `xres`.
  Script `pex_magic.tcl` sebelumnya menamai dan membuat port pada *semua* node dari Magic `.ext`.
  Perintah `extresist all` kemudian mengekstrak resistansi tubuh tersebut menjadi komponen tersendiri:
  `R0 pn19 pn19_t0 5440` dan `R1 pn18 pn18_t0 20400`.
  Kedua ujung resistor ini tidak terhubung ke rangkaian listrik DC, menyebabkan ngspice mendeteksi *singular matrix* pada simpul `x2.pn19`.

### C. Penyeragaman Ukuran Kapasitor Menjadi $25\,\mu\text{m}$
- **Letak Bug**: [scripts/pex_netlist.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_netlist.py)
- **Mekanisme**:
  Fungsi `schematic_info()` hanya mengambil baris kapasitor pertama dari skematik (`and not cap:`), yaitu `XC3` ($25\,\mu\text{m} \times 25\,\mu\text{m}$).
  Saat `gain_ota.rc.spice` dibuat, kelima kapasitor di-instansiasi dengan `w=25e-6 l=25e-6`. Hal ini membuat $XC4$ (yang seharusnya $4 \times 8.5\,\mu\text{m} \approx 540\text{ fF}$) membesar menjadi $4 \times 25\,\mu\text{m} \approx 4.6\text{ pF}$ ($8\times$ lebih besar).

### D. Hierarki Subsel Tidak Ter-flatten Penuh (`top.flatten(True)`)
- **Letak Bug**: [scripts/pex_prepare_gds.py](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_prepare_gds.py) & [scripts/pex_magic.tcl](file:///home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/scripts/pex_magic.tcl)
- **Mekanisme**:
  Di KLayout Python API, argumen `Cell.flatten(levels)` menerima integer. `True` di Python bernilai `1`, sehingga hanya meratakan 1 tingkat hierarki.
  Saat Magic membaca koordinat terminal kapasitor $25\,\mu\text{m}$, terdapat subsel yang belum ter-expand sehingga Magic menyeleksi *bounding box* sel (bukan paint), menghasilkan eror:
  `You must select paint (not a cell) to use getnode.` dan menghasilkan `{}` atau alias ganda `{c_n5135_1663# pn12}`.

---

## 3. Rincian Perubahan Script

### 1. `scripts/pex_prepare_gds.py`
- **Mempertahankan bus bar di semua metal**: Menyimpan bentuk metal lebar ($\ge \text{min\_width}$) di Metal 1, Metal 2, Metal 3, dan Metal 4 (bukan hanya Metal 4).
- **Mempertahankan via bus bar**: Menggunakan fungsi `boxes_overlap` untuk mempertahankan Via 1, Via 2, dan Via 3 yang beririsan dengan bus bar, sehingga tumpukan kontak vertikal utuh. Hanya via pada *fine fingers* yang dihapus.
- **Mengekspor dimensi $W$ dan $L$**: Di `write_caps()`, ukuran marker bounding box ($W$ dan $L$) disertakan ke dalam file `.caps`.
- **Full Recursive Flattening**: Mengubah `top.flatten(True)` menjadi `top.flatten(-1)` agar KLayout meratakan seluruh hierarki ke level poligon mentah.

### 2. `scripts/pex_magic.tcl`
- **Mengabaikan layer resistor body**: Melewati node bertipe `xres` (`if {$type eq "xres" || [string match "*res*" $type]} { continue }`) saat memberi label port `pn$k`.
- **Recursive Cell Expansion**: Mengubah `select top cell; expand` menjadi `select top cell; expand *`.
- **Meneruskan $W/L$ ke `.capnodes`**: Mendukung pembacaan argumen ekstra dimensi dari `.caps` dan meneruskannya ke file `.capnodes`.
- **Filtering Alias Tile Internal**: Jika `getnode` mengembalikan daftar nama tile (misalnya `{c_n5135_1663# pn12}`), script otomatis memfilter nama berakhiran `#` dan mengambil nama port listrik (`pn12`).

### 3. `scripts/pex_netlist.py`
- **Dukungan Dimensi Dinamis MoM Cap**: Membaca parameter $W$ dan $L$ per kapasitor dari baris `.capnodes`, sehingga kapasitor $8.5\,\mu\text{m}$ dan $25\,\mu\text{m}$ di-instansiasi dengan ukuran aslinya masing-masing.
- **Robust Regex Token Parsing**: Mendukung penguraian token jika ada kurung kurawal `{...}` pada nama simpul.
- **Dangling Resistor Stub Pruning**: Memangkas otomatis resistor parasitik yang salah satu ujungnya mengambang (hanya muncul 1 kali di seluruh rangkaian) guna mencegah singular matrix di masa mendatang.

### 4. `scripts/run_pex.sh`
- Memperbaiki pemanggilan `klayout_pex` (menghapus subcommand `extract` yang tidak dikenali).
- Menjaga default `rthresh=0` agar blok lain tidak terpengaruh, sementara pengguna dapat meneruskan `--rthresh 30000` secara fleksibel via CLI.

---

## 4. Hasil Verifikasi Akhir

Setelah perbaikan di atas diterapkan, hasil file `runs/pex/gain_ota/magic/raw.spice.capnodes`:

```text
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn5 V_out 10.200u 8.650u
pn12 V_out 26.160u 25.560u
```

- Baris 1–4: Keempat kapasitor $XC4$ terhubung ke node $R_z$ (`pn5`) dan output (`V_out`) dengan ukuran $W \approx 10.2\,\mu\text{m}, L \approx 8.65\,\mu\text{m}$.
- Baris 5: Kapasitor $XC3$ terhubung ke node diferensial $F2$ (`pn12`) dan output (`V_out`) dengan ukuran $W \approx 26.16\,\mu\text{m}, L \approx 25.56\,\mu\text{m}$.

---

## 5. Prosedur Eksekusi

```bash
# 1. Jalankan ekstraksi PEX RC (dengan threshold 30 Ohm untuk analog block)
./scripts/run_pex.sh gain_ota --use rc --rthresh 30000 --skip-lvs

# 2. Verifikasi daftar simpul kapasitor
cat runs/pex/gain_ota/magic/raw.spice.capnodes

# 3. Jalankan karakterisasi CACE post-layout RC
./scripts/run_postlayout.sh gain_ota --netlist rc
```

