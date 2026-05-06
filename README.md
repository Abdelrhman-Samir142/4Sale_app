# 4Sale Mobile — Standalone Marketplace Ecosystem

A premium, cross-platform mobile marketplace application built with **Flutter** and powered by a robust **Django REST API**. This project is a complete, standalone ecosystem designed for high-performance commerce, auctions, and real-time interaction.

---

## 📁 Project Architecture

The workspace is organized into two primary components:

```text
forsale_mobile/
├── backend/              ← Django REST Framework API
│   ├── marketplace/      ← Products, Auctions, Conversations logic
│   ├── ai/               ← Computer Vision (YOLO) classification
│   ├── rag/              ← Retrieval-Augmented Generation for Smart Search
│   ├── media/            ← Product imagery storage
│   └── db.sqlite3        ← Local SQLite database
│
├── flutter_app/          ← Flutter Mobile Application
│   ├── lib/              ← Clean Architecture (Core, Providers, Screens)
│   └── assets/           ← Lottie animations, SVGs, and brand assets
│
├── start_backend.bat     ← One-click backend initialization
└── README.md
```

---

## 🚀 Getting Started

### 1. Backend Setup
The backend serves the API and handles business logic, database management, and AI processing.

```bash
# Option A: Quick Start (Windows)
# Double-click 'start_backend.bat' in the root directory.

# Option B: Manual Execution
cd backend
python -m venv venv
source venv/bin/activate # On Windows use `venv\Scripts\activate`
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### 2. Flutter App Setup
Ensure you have the Flutter SDK installed and a device/emulator connected.

```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🔐 Administration & API
- **Admin Panel:** [http://localhost:8000/admin](http://localhost:8000/admin)
  - **Credentials:** `admin` / `admin123`
- **API Browser:** [http://localhost:8000/api](http://localhost:8000/api)
- **Local Connectivity:**
  - For Android Emulators: Use `http://10.0.2.2:8000/api`
  - For Physical Devices: Update `lib/core/constants/api_constants.dart` with your machine's local IP.

---

## ✨ Key Features & Capabilities

### 🛍️ Marketplace
- **Seamless Auth:** JWT-based login, registration, and secure session management.
- **Product Lifecycle:** List, browse, and filter products with high-performance caching.
- **Wishlist:** Save items for later with persistent local storage.

### 🔨 Live Auctions
- **Bidding System:** Real-time auction participation with live updates.
- **Dynamic Timers:** Synchronized countdowns for auction endings.

### 💬 Real-Time Communication
- **In-App Chat:** Direct messaging between buyers and sellers.
- **Notifications:** Badge updates and global snackbar alerts for new messages.

### 🧠 AI & Smart Features
- **Object Detection:** Automatic product classification using YOLO (Requires `HF_SPACE_URL`).
- **Smart Search:** RAG-based natural language search (Requires `OpenAI` or `Google GenAI`).
- **AI Agent:** Conversational assistant for marketplace guidance (Requires `Groq`/`LangChain`).

### 🎨 Premium UI/UX
- **Modern Aesthetics:** Cairo typography, glassmorphism effects, and smooth micro-animations (Lottie & Flutter Animate).
- **Themes:** High-fidelity Dark and Light mode support.
- **Localization:** Fully bilingual support (Arabic & English).

---

## 🤖 AI Engine Capabilities

The 4Sale platform integrates cutting-edge AI features to enhance user interaction and safety:

- **Computer Vision (YOLO v8):** Automatically analyzes uploaded product photos to suggest appropriate categories and verify item presence, reducing fraudulent listings.
- **Natural Language Search (RAG):** Uses Vector Embeddings to understand user intent. Instead of just matching keywords, users can search for *"A high-end laptop for video editing under $1000"* and get relevant results.
- **Smart Agent (LangChain):** An autonomous assistant that can answer questions about marketplace rules, compare product prices, and help users navigate the bidding process.
- **Trust Scoring:** A proprietary algorithm that calculates seller reliability based on historical data, response times, and transaction feedback.

---

## ✅ Core Feature Matrix

| Category | Feature | Status | Technology |
|---|---|---|---|
| **Auth** | JWT Secure Session | ✅ | Django Rest + SecureStorage |
| **Marketplace** | Product Lifecycle (CRUD) | ✅ | Django + Flutter Dio |
| **Marketplace** | Category Filtering | ✅ | Riverpod + Backend API |
| **Auctions** | Real-time Bidding | ✅ | StreamProviders + Django Views |
| **Social** | In-app Messaging | ✅ | Real-time Polling / Webhooks |
| **Social** | Notification Badges | ✅ | Background Services |
| **AI** | Image Classification | ⚙️ | YOLO v8 (Optional) |
| **AI** | Smart Search (RAG) | ⚙️ | OpenAI / Google GenAI |
| **UI/UX** | Dark / Light Mode | ✅ | Flutter ThemeExtension |
| **UI/UX** | Bilingual (AR/EN) | ✅ | Flutter Intl |

*✅ = Fully Implemented \| ⚙️ = Requires External API Keys (OpenAI/Google/Groq)*

---

## 🛠️ Technology Stack


| Layer | Technology |
|---|---|
| **Mobile** | Flutter, Riverpod, GoRouter, Dio, ScreenUtil, Hive |
| **Backend** | Django, Django REST Framework, SQLite |
| **AI/ML** | YOLO v8, LangChain, OpenAI/Gemini (Optional) |
| **Styling** | Google Fonts (Cairo), Lottie, Shimmer |

---

## 🗄️ Database Management
The system uses **SQLite** for zero-configuration setup.
- Database file: `backend/db.sqlite3`
- To reset the environment: Delete the `.sqlite3` file and re-run migrations.

---

## 📱 Application Modules Deep Dive

The application is structured into modular screens, each handling a specific domain of the marketplace:

### 1. **Core Experience**
- **Home Screen:** Features a dynamic bento-grid layout for featured items, smart search bar, and category filtering.
- **Store Screen:** Dedicated view for official stores and verified sellers with brand-specific layouts.
- **Product Details:** High-fidelity view with image carousels, seller trust scores, and quick-action buttons (Chat, Buy, Bid).

### 2. **Commerce & Transactions**
- **Auctions:** Dedicated bidding module with real-time countdowns and incremental bidding logic.
- **Sell Module:** Step-by-step form for listing products, including AI-powered image classification to suggest categories.
- **Wishlist:** Personal gallery for tracking items of interest with status update badges.

### 3. **Social & Communication**
- **Chat System:** Secure, private messaging between users with support for image sharing and quick replies.
- **Notifications Hub:** Centralized feed for system alerts, bidding updates, and message previews.
- **Profiles:** Detailed user statistics, "Trust Score" visualization, and activity history.

### 4. **Smart Utilities**
- **Smart Search:** Natural language search leveraging RAG (Retrieval-Augmented Generation) for intuitive discovery.
- **Agent Screen:** A conversational interface for the AI Marketplace Assistant to help users find deals or evaluate items.
- **Admin Dashboard:** In-app management tools for moderators to oversee listings and user reports.

---

## 🛠️ Technical Implementation

### **State Management (Riverpod)**
The app follows a unidirectional data flow using **Riverpod 2.x**:
- `authProvider`: Manages session state, JWT refresh logic, and user permissions.
- `productsProvider`: Handles async pagination, filtering, and local state sync for marketplace items.
- `auctionsProvider`: Dedicated state for live bidding, ensuring low-latency updates.
- `themeProvider`: Manages dynamic switching between Light, Dark, and System modes.

### **Network & Security**
- **Dio Client:** Singleton instance with a dedicated `_AuthInterceptor` that automatically injects JWT tokens and handles `401 Unauthorized` responses via the `AuthGuard` logout flow.
- **Secure Storage:** Uses `flutter_secure_storage` for AES-encrypted persistence of sensitive tokens.
- **Connectivity:** Real-time network monitoring using `ConnectivityService` to provide "Offline Mode" feedback to users.

### **Responsiveness & UI**
- **ScreenUtil:** Ensures the layout remains consistent across varying device sizes and aspect ratios by scaling pixels relative to a design draft.
- **Lottie Animations:** Strategic use of micro-animations for feedback loops (Success, Error, Empty States).
- **Shimmer Effects:** Premium loading experience using skeleton screens for async data fetching.

---

## 👨‍💻 Development Workflow

To add a new feature to the application:
1. **Model:** Define the data structure in `lib/models/`.
2. **Provider:** Create a Riverpod provider in `lib/providers/` to handle business logic and API calls.
3. **Screen:** Build the UI in `lib/screens/` using atomic widgets from `lib/widgets/`.
4. **Router:** Register the new route in `lib/core/router/app_router.dart`.

---

**4Sale** — *Reimagining the future of mobile commerce.*

