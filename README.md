# 🌟 CosmoSafe

<div align="center">
  <h3>AI-Powered Cosmetic Ingredient Intelligence</h3>
  
  <p>
    Scan cosmetic back labels instantly to uncover ingredient safety ratings based on international compliance standards (IS 4707, EU, US FDA). 
  </p>

  <div>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Meta_Llama-0467DF?style=for-the-badge&logo=meta&logoColor=white" alt="Llama" />
    <img src="https://img.shields.io/badge/NVIDIA_NIM-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA" />
  </div>
</div>

---

## 📖 Overview

**CosmoSafe** is an intelligent, cross-platform Flutter application engineered to decode and evaluate cosmetic ingredients. Leveraging **Google ML Kit** for precise on-device Optical Character Recognition (OCR) and an advanced 3-layer system prompt architecture powered by **Meta Llama Models via NVIDIA NIM API**, CosmoSafe transforms a simple product scan into a comprehensive, personalized safety report.

Our platform supports a **dual-mode architecture**: performing deep, contextual analysis when online via Meta Llama (using `llama-3.1-405b` and `llama-3.2-90b-vision`), while maintaining a robust **offline fallback mechanism** utilizing a comprehensive local regulatory database (CDSCO IS 4707).

## ✨ Key Features

- **📸 Advanced On-Device OCR:** Instantly extract ingredient text from product labels using your camera or gallery with high-accuracy ML Kit integrated locally.
- **🧠 Regulatory Intelligence Engine:** AI-powered analysis cross-referencing ingredients against Indian (CDSCO), EU, and US FDA guidelines using Meta Llama models.
- **📊 Comprehensive Safety Ratings:** Get clear A to E safety ratings with breakdown of potential risks, irritants, and allergens.
- **🔄 Dual-Mode Architecture:** Seamless offline/online detection. Performs local compliance checks when offline, and detailed LLM-driven evaluations when connected to the internet.
- **👤 Personalized Recommendations:** Tailors safety profiles and daily usage guidance based on your selected skin type and sensitivities.
- **💻 True Cross-Platform:** Implemented in Flutter with support for Android, iOS, Web, Windows, macOS, and Linux.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (`^3.7.2`)
- **State Management:** Provider
- **AI & LLM:** Meta Llama 3.1/3.2 via NVIDIA NIM API
- **OCR Engine:** Google ML Kit Text Recognition
- **Local Database:** Core regulatory datasets pre-loaded (IS 4707)
- **UI & Animations:** Google Fonts, Flutter Animate, Percent Indicator

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart](https://dart.dev/get-dart)
- IDE (VS Code, Android Studio, IntelliJ)

### 1. Clone the repository

```bash
git clone https://github.com/your-username/cosmosafe.git
cd cosmosafe
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Environment Configuration Setup

CosmoSafe requires API configuration for the Regulatory Engine. Ensure you have a `.env` file in the root of your project directory (`d:\COSMO\cosmosafe\.env`).

Example `.env` format:
```env
NVIDIA_API_KEY=your_nvidia_api_key_here
```
*(Note: Never commit your `.env` file to version control)*

### 4. Run the Application

**For Windows (Desktop):**
```bash
flutter run -d windows --dart-define-from-file=.env
```

**For Web (Chrome):**
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security" --dart-define-from-file=.env
```

**For Android / iOS:**
```bash
flutter run --dart-define-from-file=.env
```

## 🏗️ Architecture Breakdown

1. **Presentation Layer:** State-of-the-art UI utilizing `flutter_animate` for a fluid, premium user experience. Domain-driven feature split (Scanner, Results, User Profile).
2. **Analysis Engine (Domain):** Orchestrates the data flow between local Regex/Database matching and Remote LLM generation (via NVIDIA NIM). 
3. **Data Layer:** Handles API calls, local generic storage (`shared_preferences`), network status (`connectivity_plus`), and OCR extraction.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

---
<div align="center">
  <i>Built to empower cleaner and safer cosmetic choices globally.</i>
</div>
