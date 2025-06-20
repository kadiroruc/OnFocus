# 🕒 Online Work Timer App (In Development)

An **iOS productivity app** designed to enhance focus through structured work sessions, extended statistics, and social features — inspired by the Pomodoro technique.

---

## 🚧 Project Status

This app is currently **under development**.  
Core functionalities are being actively implemented and tested.

---

## 🛠️ Technologies Used

- `Swift` & `UIKit`
- **MVVM Architecture** (work in progress)
- **Programmatic UI**
- Generic Network Layer - URL Session
- DIContainer
- [`DGCharts`](https://github.com/danielgindi/Charts) – Charting library
- [`FSCalendar`](https://github.com/WenchaoD/FSCalendar) – Calendar integration
- **Firebase** – Authentication & Cloud Firestore

---

## ✨ Features

### 🎯 Productivity System
- ⏱️ **Pomodoro Timer**  
  Follows the classic 25/5 model with a 15-minute long break after 4 sessions. All focus times are logged and visualized via charts.

- 🕒 **Free Mode**  
  Allows users to manually start and record custom-duration sessions, outside the Pomodoro format.

### 📊 Statistics Dashboard
- View data across **daily**, **weekly**, **monthly**, **yearly**, and **5-year** intervals.
- See **average daily work time** and **percentage improvement** over the previous period.
- All stats are visualized using interactive charts.

### 👥 Social Features
- Add friends and view:
  - Their current activity status
  - Their total work time for the day
- Compete via the **Leaderboard**:
  - Displays top users by work time for daily, weekly, and monthly periods.

### 👤 User & Profile
- Firebase-authenticated **account creation & login**
- Session data stored securely in **Cloud Firestore**
- Calendar view showing **daily login streaks** and **work history**

---

## 📱 Screenshots
<img width="300" alt="Screenshot 2025-05-20 at 21 31 10" src="https://github.com/user-attachments/assets/85742010-06f4-40d9-b1b8-1f3f9deda56f" />
<img width="300" alt="Screenshot 2025-05-20 at 21 50 21" src="https://github.com/user-attachments/assets/19839489-7189-43ea-8ab6-bf65cf82fd5b" />
<img width="300" alt="Screenshot 2025-05-20 at 21 50 24" src="https://github.com/user-attachments/assets/069c59fc-1e13-48e6-976f-3b9246e57c58" />
<img width="300" alt="Screenshot 2025-05-20 at 21 50 30" src="https://github.com/user-attachments/assets/5678744a-eb7c-49c6-8af5-9fdde61fced3" />
<img width="300" alt="Screenshot 2025-05-20 at 21 50 39" src="https://github.com/user-attachments/assets/663cd430-54a5-45b6-a76c-d952a08f880c" />
<img width="300" alt="Screenshot 2025-05-20 at 21 51 07" src="https://github.com/user-attachments/assets/0c9ec1f1-c5ae-4328-b61e-94c2455ce452" />

---

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kadiroruc/TimerApp.git
cd TimerApp
```
---

### 📦 SPM Dependencies

Xcode uses **Swift Package Manager (SPM)** to manage dependencies.

- ✅ Xcode will automatically resolve and fetch all listed dependencies.
- 📄 The `.xcodeproj` (or `.xcworkspace`) file includes dependency references.

---

### 🔐 Firebase Setup

This project uses **Firebase** for user authentication and cloud data storage.

#### What’s Needed:
1. Request the `GoogleService-Info.plist` file.
2. Drag and drop it into the root of your Xcode project.
3. Ensure it’s added to your app target.

#### Security Note:
There is a sample Config.plist file for imgBB Api.


