# 🍔 Mu Delivery

**Mu Delivery** is a modern food delivery app built with **Flutter** and **Firebase**.  
It offers a clean and smooth user experience for both customers and restaurant owners.  
Users can browse restaurants, explore menus, add food to their cart, manage favorites (watchlist), and place orders easily — all in one app.

---

## 🚀 Features

### 🧑‍🍳 Customer UI
- 🔐 **Firebase Authentication** — Secure login & signup with email/password.  
- 🍽️ **Restaurant & Menu Browsing** — View restaurants and their menu items in real-time.  
- 🛒 **Cart Management** — Add, remove, and update quantities before checkout.  
- ❤️ **Watchlist System** — Save favorite foods or restaurants and remove them anytime.  
- 📦 **Order Placement & Tracking** — Simple checkout flow with live order tracking.  
- 🔄 **Real-time Data Updates** — All pages update instantly using Firebase Firestore streams.  
- 🌗 **Dark Mode Support** — Seamless theme switching saved using a provider.

---

### 🏢 Restaurant / Admin UI 
- 🧾 **View Incoming Orders**  
- 📊 **Track Food Items and Status**  
- 🔥 **Firestore Integration** for real-time updates

---

## 🧠 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | Flutter (Dart) |
| **State Management** | Provider |
| **Backend** | Firebase Firestore |
| **Authentication** | Firebase Auth |
| **Cloud Storage** | Firebase Storage (for food & restaurant images) |


## ⚙️ How to Run
|
 Clone the repo:  
```bash|
git clone https://github.com/Muaz2004/mu_delivery.git
cd mu_delivery
Install dependencies:

bash
Copy code
flutter pub get
Add Firebase config (google-services.json for Android, GoogleService-Info.plist for iOS)

Run the app:

bash
Copy code
flutter run
(Optional) Build APK for Android:

bash
Copy code
flutter build apk --release
📱 Access
Open the app on your phone

Signup/Login to start using Customer or Admin UI