<div align="center">

![Persona 3 Reload AWTRIX Preview](assets/preview.svg)

# awtrix-p3r-clock

### Persona 3 Reload Clock for AWTRIX NG

[![AWTRIX NG](https://img.shields.io/badge/AWTRIX-NG-blue.svg)](https://github.com/Blueforcer/awtrix-ng)
[![Display](https://img.shields.io/badge/Display-52x16%20Matrix-00AEEF.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-Ulanzi%20TC002%20%7C%20ESP32-orange.svg)]()
[![Language](https://img.shields.io/badge/Language-Berry%20(Standalone)-green.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

<p>A clock and calendar application inspired by <strong>Persona 3 Reload</strong> (P3R) underwater visuals, designed for <strong>Ulanzi TC002</strong> and 52×16 RGB LED matrix displays running <strong>AWTRIX NG</strong>.</p>

</div>

---

## ✨ Features

- **Standalone On-Device App**: Written in Berry script (`p3r.be`), running natively on the ESP32 without external servers or dependencies.
- **Normal Mode**:
  - **Left 16×16 Icon**: Makoto Yuki underwater pixel art icon.
  - **Right 36×16 Panel**: Ocean blue gradient background with rising bubbles animation.
  - **Date & Weekday**: Date (`MM/DD`) and weekday (yellow for weekdays, red for Sunday).
  - **Clock**: 4×7 digital clock (`HH:MM:SS`).
- **Dark Hour Mode (00:00 ~ 00:59)**:
  - Automatically activates at midnight, or can be forced via settings.
  - **Left 16×16 Icon**: Dark Hour Full Moon pixel art icon.
  - **Right 36×16 Panel**: Dark green gradient background.
  - **Clock**: Neon green hours/minutes with red seconds.
- **P3 Logo Rotation**:
  - Alternates the weekday slot with the `P3` logo every 4 seconds while keeping the date visible.
- **Web UI Configuration (`@config`)**:
  - Configure timezone, force Dark Hour mode, and toggle logo cycling via the AWTRIX NG web UI.

---

## 📸 Screenshots

| Mode | Preview |
|---|---|
| **Normal Mode (Weekday)**<br>Makoto Yuki Icon + Date / Weekday + Time | ![Normal WED](assets/preview_normal_wed.png) |
| **Normal Mode (P3 Logo)**<br>Makoto Yuki Icon + Date / P3 Logo + Time | ![Normal P3](assets/preview_normal_p3.png) |
| **Dark Hour Mode (Weekday)**<br>Full Moon Icon + Date / Weekday + Neon Clock | ![Dark WED](assets/preview_dark_wed.png) |
| **Dark Hour Mode (P3 Logo)**<br>Full Moon Icon + Date / P3 Logo + Neon Clock | ![Dark P3](assets/preview_dark_p3.png) |

---

## 🛠️ Requirements

- **Hardware**: Ulanzi TC002 or any ESP32 / ESP32-S3 powered 52×16 RGB LED matrix.
- **Firmware**: [AWTRIX NG](https://github.com/Blueforcer/awtrix-ng).
- **Display Resolution**: 52×16 pixels (`# @display 52x16`).

---

## 🚀 Installation

### Option 1: AWTRIX Hub (Recommended)
1. Open your AWTRIX NG Web UI and navigate to the **Hub** tab (or visit [AWTRIX Hub](https://blueforcer.github.io/awtrix-ng/)).
2. Search for **Persona 3 Reload Clock**.
3. Click **Send to AWTRIX** to install directly to your device.

### Option 2: Manual Installation
1. Open your AWTRIX NG Web UI (`http://<your-device-ip>`).
2. Go to the **Scripts** tab.
3. Click **Add Script** and name the file `p3r.be`.
4. Copy the entire contents of [`app/p3r.be`](app/p3r.be) and paste into the editor.
5. Click **Save**. The app will be added to your app rotation.

---

## ⚙️ Configuration

Click the gear icon (**⚙️**) next to **Persona 3 Reload Clock** in the AWTRIX NG **Apps** management page:

| Setting | Type | Default | Description |
|---|---|---|---|
| `Timezone` (`timezone`) | `text` | `"Asia/Taipei"` | IANA timezone (e.g. `Asia/Taipei`, `Asia/Tokyo`, `UTC`) or numeric offset (`+8`, `-5`). Set to `"auto"` to use device system time. |
| `Force Dark Hour` (`force_dark`) | `bool` | `false` | Force Dark Hour theme (full moon and dark green palette). |
| `Cycle P3 Logo` (`enable_p3_cycle`) | `bool` | `true` | Alternate weekday slot every 4 seconds with the P3 logo. |

---

## 📂 Project Structure

```text
awtrix-p3r-clock/
├── app/
│   └── p3r.be                 # Berry application for AWTRIX NG
├── assets/
│   ├── preview.svg            # LED preview banner
│   ├── preview_normal_wed.png # Normal mode with Weekday
│   ├── preview_normal_p3.png  # Normal mode with P3 Logo
│   ├── preview_dark_wed.png   # Dark Hour mode with Weekday
│   └── preview_dark_p3.png    # Dark Hour mode with P3 Logo
├── LICENSE                    # MIT License
├── README.md                  # English Documentation
├── README.zh-TW.md            # Traditional Chinese Documentation
├── README.ja.md               # Japanese Documentation
└── README.ko.md               # Korean Documentation
```

---

## 📄 License & Disclaimer

- Code released under the [MIT License](LICENSE).
- *Persona 3 Reload* and related characters/assets are property of **ATLUS / SEGA**. This is a non-commercial fan creation.
