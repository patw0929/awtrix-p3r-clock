<div align="center">

![Persona 3 Reload AWTRIX 미리보기](assets/preview.svg)

# awtrix-p3r-clock

### Persona 3 Reload Clock for AWTRIX NG

[![AWTRIX NG](https://img.shields.io/badge/AWTRIX-NG-blue.svg)](https://github.com/Blueforcer/awtrix-ng)
[![Display](https://img.shields.io/badge/Display-52x16%20Matrix-00AEEF.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-Ulanzi%20TC002%20%7C%20ESP32-orange.svg)]()
[![Language](https://img.shields.io/badge/Language-Berry%20(Standalone)-green.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

<p>《페르소나 3 리로드》(Persona 3 Reload, P3R)의 수중 비주얼 테마에서 영감을 받은 시계 및 캘린더 애플리케이션입니다.<br><strong>Ulanzi TC002</strong> 및 <strong>AWTRIX NG</strong> 펌웨어가 구동되는 52×16 RGB LED 매트릭스 디스플레이를 위해 제작되었습니다.</p>

</div>

---

## ✨ 주요 기능

- **단독 네이티브 구동 (Standalone)**: Berry 스크립트(`p3r.be`)로 작성되어 외부 서버나 추가 라이브러리 없이 ESP32 기기 자체에서 독립적으로 실행됩니다.
- **일반 모드 (Normal Mode)**:
  - **좌측 16×16 아이콘**: 주인공 유키 마코토의 수중 픽셀 아트 아이콘.
  - **우측 36×16 패널**: 떠오르는 물방울 애니메이션 효과가 적용된 오션 블루 수직 그라데이션 배경.
  - **날짜 및 요일**: 날짜(`MM/DD`)와 요일 표시 (월~토요일은 옐로우, 일요일은 레드).
  - **디지털 시계**: 가독성 높은 4×7 디지털 시계(`HH:MM:SS`).
- **섀도 타임 모드 (Dark Hour / 00:00 ~ 00:59)**:
  - 자정(00:00)이 되면 자동으로 섀도 타임으로 전환 (설정에서 상시 강제 활성화 가능).
  - **좌측 16×16 아이콘**: 섀도 타임 보름달(Full Moon) 픽셀 아트 아이콘.
  - **우측 36×16 패널**: 다크 그린 그라데이션 배경.
  - **디지털 시계**: 네온 그린 시/분과 붉은색 초 단위 표시.
- **💥 소환기(Evoker) 페르소나 소환 연출 (버튼 상호작용)**:
  - 기기 버튼(기본값: 가운데 **Select** 버튼)을 누르면 상징적인 페르소나 소환 컷씬 애니메이션이 발동됩니다 (소환기 조준, 눈빛 컷인, 격발 섬광, 유리 파편 및 푸른 불꽃 이펙트).
  - **음성 및 소환 효과음 지원**: 유키 마코토의 소환 대사와 총소리 효과음을 재생합니다 (내장 하드웨어 신디사이저 자동 대체 기능 포함).
- **P3 로고 순환 (Cycle P3 Logo)**:
  - 날짜 표시를 유지하면서 요일 슬롯이 4초마다 요일과 `P3` 로고로 교차 전환됩니다.
- **웹 UI 설정 지원 (`@config`)**:
  - AWTRIX NG 웹 관리 페이지에서 타임존 설정, 섀도 타임 강제 활성화, P3 로고 순환 여부, 소환 버튼 매핑, 음성 켜기/끄기를 손쉽게 제어할 수 있습니다.

---

## 📸 스크린샷

| 모드 | 미리보기 |
|---|---|
| **💥 소환기 페르소나 소환 애니메이션**<br>자세 + 눈빛 컷인 + 격발 섬광 + 유리 파편 & 푸른 불꽃 PERSONA | ![Summon Preview](assets/preview_summon.gif) |
| **일반 모드 (요일 표시)**<br>유키 마코토 아이콘 + 날짜 / 요일 + 시계 | ![Normal WED](assets/preview_normal_wed.png) |
| **일반 모드 (P3 로고 표시)**<br>유키 마코토 아이콘 + 날짜 / P3 로고 + 시계 | ![Normal P3](assets/preview_normal_p3.png) |
| **섀도 타임 모드 (요일 표시)**<br>보름달 아이콘 + 날짜 / 요일 + 네온 시계 | ![Dark WED](assets/preview_dark_wed.png) |
| **섀도 타임 모드 (P3 로고 표시)**<br>보름달 아이콘 + 날짜 / P3 로고 + 네온 시계 | ![Dark P3](assets/preview_dark_p3.png) |

---

## 🛠️ 요구 사양

- **하드웨어**: Ulanzi TC002 또는 ESP32 / ESP32-S3 기반 52×16 RGB LED 매트릭스 디스플레이.
- **펌웨어**: [AWTRIX NG](https://github.com/Blueforcer/awtrix-ng).
- **디스플레이 해상도**: 52×16 픽셀 (`# @display 52x16`).

---

## 🚀 설치 방법

### 방법 1: AWTRIX Hub에서 설치 (권장)
1. AWTRIX NG 웹 관리 페이지를 열고 **Hub** 탭으로 이동합니다 (또는 [AWTRIX Hub](https://blueforcer.github.io/awtrix-ng/) 방문).
2. **Persona 3 Reload Clock**을 검색합니다.
3. **Send to AWTRIX**를 클릭하면 기기에 즉시 설치됩니다.

### 방법 2: 수동 설치
1. 브라우저에서 AWTRIX NG 웹 관리 페이지(`http://<기기-IP>`)에 접속합니다.
2. **Scripts** 탭으로 이동합니다.
3. **Add Script** 버튼을 클릭하고 파일명으로 `p3r.be`를 입력합니다.
4. [`app/p3r.be`](app/p3r.be)의 코드 전체를 복사하여 편집기에 붙여넣습니다.
5. **Save**를 클릭하여 저장하면 앱 목록에 등록됩니다.

---

## 🔊 소환 음성 및 효과음 주의사항

본 앱은 페르소나 소환 애니메이션 실행 시 유키 마코토의 소환 음성("Persona!") 및 총소리 효과음 재생을 지원합니다. 설치 경로에 따른 사운드 처리 방식은 다음과 같습니다:

### 1. AWTRIX Hub에서 설치 (권장, 사운드 자동 포함)
- **AWTRIX Hub**에서 검색하여 설치할 경우, AWTRIX NG가 스크립트와 함께 전용 8-bit `persona.mp3` 오디오 파일을 번들로 자동 다운로드합니다(`/SCRIPTS/Persona3/persona.mp3`에 저장).
- **설치 즉시 사용 가능**: 가운데 Select 버튼을 누르면 별도의 추가 설정 없이 바로 음성과 효과음이 재생됩니다.

### 2. 수동 설치 (음원 미업로드 시 하드웨어 신시사이저로 자동 대체)
- 단일 `.be` 스크립트 파일은 바이너리 사운드 데이터를 담을 수 없으므로, 코드를 직접 붙여넣어 설치할 경우 기기 내에 `persona.mp3`가 존재하지 않습니다.
- **자동 폴백(Fallback) 메커니즘**: MP3 파일이 없을 경우, 스크립트가 **TC002 내장 하드웨어 신시사이저(Song Synthesizer)로 자동 전환**됩니다. 외부 파일 없이 칩 자체에서 8-bit 스타일의 에볼커 총소리 노이즈와 "Per-so-na!" 멜로디를 합성 출력합니다.
- **수동으로 8-bit 음성 등록하기**:
  1. AWTRIX NG 웹 관리자(`http://<기기IP>`)를 엽니다.
  2. **Audio** 탭으로 이동하거나, **Scripts** 탭 편집기 상단의 **🎵 음표 아이콘**을 클릭합니다.
  3. 저장소의 [`assets/persona.mp3`](assets/persona.mp3) 파일(AWTRIX 펌웨어 규격인 MPEG-1 Layer III 44.1 kHz로 최적화됨)을 업로드하면 정식 8-bit 보이스가 활성화됩니다.

---

## ⚙️ 설정 항목

AWTRIX NG 웹 관리자의 **Apps** 페이지에서 **Persona 3 Reload Clock** 옆의 톱니바퀴 아이콘(**⚙️**)을 클릭하여 설정합니다:

| 설정 항목 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `Timezone` (`timezone`) | `text` | `"Asia/Taipei"` | IANA 표준 시간대(예: `Asia/Seoul`, `Asia/Tokyo`, `UTC`) 또는 숫자 오프셋(`+9`, `-5`). `"auto"` 설정 시 기기 시스템 시간 사용. |
| `Force Dark Hour` (`force_dark`) | `bool` | `false` | 섀도 타임 테마(보름달 및 다크 그린 팔레트)를 강제로 활성화합니다. |
| `Cycle P3 Logo` (`enable_p3_cycle`) | `bool` | `true` | 요일 슬롯을 4초마다 요일과 P3 로고로 번갈아 순환 표시합니다. |
| `Summon Button` (`trigger_btn`) | `text` | `"select"` | 소환 애니메이션을 실행할 기기 물리 버튼: `select`(가운데 버튼), `middle`, `left`, `right`, 또는 `any`. |
| `Enable Sound` (`enable_sound`) | `bool` | `true` | 소환 시 음성 및 효과음 재생 활성화 여부. |

---

## 📂 프로젝트 구조

```text
awtrix-p3r-clock/
├── app/
│   └── p3r.be                   # AWTRIX NG용 Berry 애플리케이션
├── assets/
│   ├── persona.mp3              # "Persona!" 소환 음성 (AWTRIX Audio에 업로드)
│   ├── preview.svg              # LED 미리보기 배너
│   ├── preview_summon.gif       # 소환기 페르소나 소환 애니메이션 미리보기
│   ├── preview_normal_wed.png   # 일반 모드 (요일)
│   ├── preview_normal_p3.png    # 일반 모드 (P3 로고)
│   ├── preview_dark_wed.png     # 섀도 타임 모드 (요일)
│   └── preview_dark_p3.png      # 섀도 타임 모드 (P3 로고)
├── LICENSE                      # MIT 라이선스
├── README.md                    # 영문 문서
├── README.zh-TW.md              # 번체 중국어 문서
├── README.ja.md                 # 일본어 문서
└── README.ko.md                 # 한국어 문서
```

---


