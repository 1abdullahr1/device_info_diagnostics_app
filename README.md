# Device Specs & Hardware Diagnostics Android App 📱

Built by **Abdullah Bhatti**

A clean, modern Flutter Android application designed for deep device hardware inspection, real-time diagnostic text benchmarks, and smart specifications evaluation.

---

## ✨ Features

1. **📊 Comprehensive Device Specifications**:
   - Manufacturer, Brand, Product & Model details
   - CPU Architecture, SoC Platform & 64-bit ABI instruction sets
   - Android OS version, SDK / API levels, and Build Fingerprints
   - Display Resolution, Pixel Density (DPI/PPI) & 120Hz Refresh Rate
   - RAM memory technology & Storage speed standards (UFS 4.0 / UFS 3.1)
   - Battery health metrics & charging wattage
   - Widevine DRM Level 1 HD/4K streaming security verification

2. **🔍 Instant Search Engine**:
   - Search across all hardware items, values, acronyms, and concept definitions in real time.
   - Quick keyword filter chips (e.g. *RAM, CPU/SoC, Display, UFS Storage, Widevine, Battery, 64-bit ABI*).

3. **🎓 Hardware Concepts & Specs Evaluation Guide**:
   - Masterclass glossary breaking down what every spec means in plain English.
   - Real-world practical explanations: Why does LPDDR5X vs LPDDR4X or UFS 4.0 vs eMMC matter?
   - Smartphone buying checklist and evaluation thresholds.

4. **⚡ Live Diagnostics & "Run Text" Benchmarks**:
   - **Text Stream Engine**: Live high-throughput diagnostic text stream measuring lines/second rendering performance.
   - **CPU Arithmetic Benchmark**: 5,000,000 mathematical operations benchmark scoring single-thread compute throughput.
   - **Multi-Touch & Screen Canvas**: Interactive multi-touch responsiveness testing.

5. **👤 About Developer ("Built By Abdullah Bhatti")**:
   - Developer showcase profile.
   - One-tap "Export Full Device Report" to clipboard.

---

## 🚀 Cloud Build via GitHub Actions (Get Final APK)

This repository includes a ready-to-run GitHub Actions CI/CD workflow (`.github/workflows/build_apk.yml`).

### How to trigger and download your APK:
1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Device Info App by Abdullah Bhatti"
   git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>.git
   git branch -M main
   git push -u origin main
   ```
2. **Go to GitHub Actions**:
   - Open your repository on GitHub.
   - Click on the **Actions** tab.
   - Watch the `Build Flutter APK` workflow run automatically on GitHub's cloud runners.
3. **Download APK**:
   - Once completed (green checkmark), scroll down to **Artifacts**.
   - Click **`app-release-apk`** to download your finalized Android APK!
