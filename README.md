# 📚 Latin Balochi Tutor

A modern, AI-powered mobile application designed to bridge the gap between the **Arabic** and **Latin** scripts for the Balochi language. 

Built with **Flutter** and powered by **Groq AI**, this app serves as a converter, a tutor, and a reference guide for the *Balóchiay Látini Syáhag (2026 Standard)*.

---

## ⚠️ Accuracy & Disclaimer

**Please Note:** While the custom logic engine is designed to follow the 2026 Standard rules strictly, automated script conversion **is not 100% accurate** in all cases. 

Balochi is a rich language with various dialects and complex contextual nuances that a rule-based algorithm might occasionally miss. 
* **The AI Tutor** is helpful but relies on the underlying logic engine.
* **The Converter** works best with standard spelling but may struggle with irregular words.

**We need you!** If you spot an incorrect conversion or a missing rule, please contribute to the code to help us perfect the standard.

---

## ✨ Key Features

### 🔄 **Instant Script Converter**
* **Two-Way Translation:** Convert text seamlessly from Latin to Arabic script and vice versa.
* **Smart Logic Engine:** Custom-built algorithm handles complex digraphs (`dh`, `ch`, `sh`), vowel mapping (`á`, `é`, `ó`), and special rules like *Tashdid* (doubling letters).

### 🤖 **AI Tutor (Powered by Groq)**
* **Context-Aware Chat:** Ask general questions about the language or grammar.
* **Smart Assistance:** The AI detects when you need a conversion and validates its answer against the internal logic engine.

### 📖 **Reference Library**
* **Alphabet Guide:** Complete list of the 29-letter Latin alphabet with Arabic equivalents.
* **Grammar Rules:** Learn specific rules like the "No F" rule (`F` -> `P`) and how to handle beginning vowels.

### 🧠 **Quiz Mode**
* Test your knowledge with interactive quizzes to reinforce your learning.

### 🎨 **Modern UI & Settings**
* **Dark/Light Mode:** Fully adaptive themes.
* **Profile Customization:** Set your name, bio, and profile picture (Camera/Gallery support).

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** Provider / ChangeNotifier
* **AI Backend:** Groq API (LLaMA 3 model)
* **Key Packages:**
    * `http`: For API communication.
    * `image_picker`: For profile picture handling.
    * `path_provider`: For local file storage.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK installed ([Guide](https://flutter.dev/docs/get-started/install))
* VS Code or Android Studio

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR-USERNAME/latin_balochi_tutor.git](https://github.com/YOUR-USERNAME/latin_balochi_tutor.git)
    cd latin_balochi_tutor
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **🔑 Set up the API Key (Important):**
    * This project uses the Groq API for AI features. The key is not included in this repo for security.
    * Open `lib/main.dart`.
    * Find the line: `const String groqApiKey = "PASTE_YOUR_API_KEY_HERE";`
    * Replace it with your actual Groq API key.

4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📸 Screenshots

| Home Screen | Translator | AI Chat | Dark Mode |
|:---:|:---:|:---:|:---:|
| *(screenshot will be added here soon)* | *(screenshot will be added here soon)* | *(screenshot will be added here soon)* | *(screenshot will be added here soon)* |

---

## 🤝 Contributing

Contributions are heavily encouraged! Since this tool is still evolving, your help is vital to improve accuracy.

**How you can help:**
* **Fix Logic Errors:** Found a word converting wrong? Edit `BalochiLogic` class in `main.dart`.
* **Add Rules:** Improve the `ScriptData` rules list.
* **UI Improvements:** Make the app look even better.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/FixConversionLogic`)
3.  Commit your Changes (`git commit -m 'Fixed conversion for letter Dh'`)
4.  Push to the Branch (`git push origin feature/FixConversionLogic`)
5.  Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Developed with ❤️ by Ghazen Khalid**
*Turbat, Balochistan*
