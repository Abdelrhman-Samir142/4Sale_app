# 4Sale Mobile — Standalone Project

مشروع **4Sale** متكامل ومستقل تماماً عن الويب.

## 📁 هيكل المشروع

```
forsale_mobile/
├── backend/              ← Django REST API + SQLite Database
│   ├── manage.py
│   ├── db.sqlite3        ← قاعدة البيانات (تتنشئ تلقائياً)
│   ├── media/            ← صور المنتجات
│   ├── marketplace/      ← المنتجات، المزادات، الشات
│   ├── rag/              ← البحث الذكي (اختياري)
│   ├── ai/               ← التصنيف بالذكاء الاصطناعي (اختياري)
│   └── refurbai_backend/ ← إعدادات Django
│
├── flutter_app/          ← تطبيق Flutter الموبايل
│   └── lib/              ← كود التطبيق
│
├── start_backend.bat     ← تشغيل الباكند (ضغطة واحدة)
└── README.md
```

## 🚀 التشغيل

### 1. تشغيل الباكند
```bash
# طريقة 1: دبل كليك على start_backend.bat

# طريقة 2: من الـ Terminal
cd backend
python manage.py runserver 0.0.0.0:8000
```

### 2. تشغيل الـ Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

## 🔐 حساب الأدمن
- **Username:** `admin`
- **Password:** `admin123`
- **Admin Panel:** http://localhost:8000/admin

## 📡 الـ API
- **من المتصفح:** http://localhost:8000/api
- **من الـ Emulator:** http://10.0.2.2:8000/api
- **من موبايل حقيقي:** استخدم IP جهازك (مثلاً `http://192.168.1.x:8000/api`)

### لو بتستخدم موبايل حقيقي:
عدّل ملف `flutter_app/lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://192.168.1.X:8000/api'; // ← حط IP جهازك
```

## 🗄️ قاعدة البيانات
- **النوع:** SQLite (مش محتاج PostgreSQL)
- **الملف:** `backend/db.sqlite3`
- **لإعادة التعيين:** احذف `db.sqlite3` وشغّل `python manage.py migrate` تاني

## ✅ الميزات المتاحة بدون أي خدمات خارجية
| الميزة | الحالة |
|--------|--------|
| التسجيل وتسجيل الدخول | ✅ |
| إضافة وعرض المنتجات | ✅ |
| المزادات + المزايدة | ✅ |
| الرسائل والمحادثات | ✅ |
| المفضلة | ✅ |
| الملف الشخصي + Trust Score | ✅ |
| الإشعارات | ✅ |
| Dark/Light Mode | ✅ |
| عربي/إنجليزي | ✅ |
| تصنيف AI (YOLO) | ⚠️ يحتاج HF_SPACE_URL |
| البحث الذكي RAG | ⚠️ يحتاج openai + google-genai |
| الوكيل الذكي | ⚠️ يحتاج langchain + groq |
