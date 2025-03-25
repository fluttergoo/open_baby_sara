# 👶 Sara: Baby Tracker & Sounds

**Track sleep, feeding, diapers & recipes — All-in-one baby care: Track, Feed, Sleep, and Grow Together.**

Sara is an open-source Flutter app designed to make parenting easier by helping parents and caregivers track daily baby activities, share responsibilities, and create a calm environment with soothing sleep sounds and baby food recipes.

---

## 🚼 Key Features

- 🍼 Track breastfeeding, bottle feeding, solid foods & pumping
- 🧷 Diaper change logs
- 😴 Sleep tracking with background sounds
- 📈 Growth milestones and vaccine records
- 🍲 Baby-friendly food recipes with filters
- 👨‍👩‍👧 Shared tracking with family members
- 🕒 Activity history and daily logs

---

## 📲 App Structure

### 🟣 Onboarding
- 👤 Create user account
- 👶 Enter baby details

### 🟡 Activity Tracker
- Breastfeeding / Bottle / Solid / Combo feeding
- Pumping
- Diaper changes
- Sleep tracking
- Baby’s first milestones
- Growth monitoring
- Medical records / Vaccinations

### 🔵 Sleep Sounds
- Relaxing background baby sleep sounds

### 🟢 Recipes
- Community-submitted baby food recipes
- Filter by baby’s age or meal type (e.g., breakfast, lunch)

### 🟠 History
- View daily and hourly activity logs

### ⚙️ Account & Settings
- Add caregivers or family members
- App settings and help section
- Share the app with others

## 🧪 Tech Stack

### 🖼️ Frontend
- **Flutter** – UI toolkit for crafting natively compiled mobile applications

### 🛠️ Backend
- **Firebase**
    - **Firestore** – NoSQL database for storing structured data
    - **Firebase Auth** – User authentication and management
    - **Cloud Functions** – Serverless backend logic
    - **Storage** – For user-generated media or files

### 🔔 Notifications
- **Firebase Cloud Messaging (FCM)** – Push notifications to iOS and Android devices

### 💾 Local Storage
- **Hive** *(or)* **Shared Preferences** – For storing personal and offline data locally

### 🚀 Deployment
- **App Store** & **Google Play** – For publishing the mobile application

### 🔄 Version Control
- **Git** – Source code management and collaboration

### ⚙️ CI/CD
- **GitHub Actions** – Continuous integration and deployment workflows

---

## 🚀 Getting Started

To run the app locally:

```bash
flutter pub get
flutter run
```

