# Maestro AI - مساعد شخصي ذكي للتحكم بالهاتف

<p align="center">
  <img src="assets/icons/app_icon.png" width="120" height="120" alt="Maestro AI Logo">
</p>

<p align="center">
  <b>تحكم في هاتفك بصوتك - بدون إنترنت</b>
</p>

---

## 🌟 المميزات الرئيسية

- 🎙️ **تحكم صوتي كامل** - تنفيذ أوامر صوتية للتحكم في كل aspect من هاتفك
- 🔒 **يعمل بدون إنترنت** - جميع المعالجة تتم على الجهاز لحماية خصوصيتك
- 🧠 **ذكاء اصطناعي متقدم** - يستخدم نموذج Llama 3.2 لفهم الأوامر الطبيعية
- ⚡ **استجابة فورية** - تنفيذ الأوامر في أجزاء من الثانية
- 📱 **أكثر من 50 أمراً** - تحكم في التطبيقات، المكالمات، الإعدادات، الملفات، والمزيد
- 🎨 **واجهة مستخدم جميلة** - تصميم عصري مع دعم كامل للغة العربية

---

## 📋 قائمة الأوامر المدعومة

### 📱 التحكم بالتطبيقات
- `افتح [اسم التطبيق]` - فتح أي تطبيق مثبت
- `اغلق [اسم التطبيق]` - إغلاق التطبيق
- `اعرض التطبيقات` - عرض قائمة التطبيقات

### 📞 المكالمات والرسائل
- `اتصل بـ [الاسم]` - إجراء مكالمة
- `اتصل على [الرقم]` - الاتصال برقم محدد
- `أرسل رسالة إلى [الاسم]: [النص]` - إرسال رسالة

### ⚙️ الإعدادات
- `شغل/اطفي الواي فاي` - التحكم بالواي فاي
- `شغل/اطفي البلوتوث` - التحكم بالبلوتوث
- `زود/خفض السطوع` - ضبط سطوع الشاشة
- `ارفع/خفض الصوت` - ضبط مستوى الصوت

### 💻 معلومات النظام
- `كم البطارية` - عرض حالة البطارية
- `كم المساحة` - عرض المساحة التخزينية
- `كم الرام` - عرض استخدام الذاكرة
- `معلومات الجهاز` - عرض معلومات الجهاز

### 🎵 الوسائط
- `شغل أغنية [الاسم]` - تشغيل موسيقى
- `وقف` - إيقاف الوسائط
- `التالي/السابق` - التنقل بين المقاطع
- `صور` - التقاط صورة

### 📁 الملفات
- `اعرض الملفات` - عرض الملفات
- `أنشئ مجلد [الاسم]` - إنشاء مجلد جديد
- `احذف الملف [الاسم]` - حذف ملف

---

## 🚀 التثبيت

### المتطلبات
- Flutter 3.22 أو أحدث
- Dart 3.0 أو أحدث
- Android SDK 24 أو أحدث

### خطوات التثبيت

1. **استنساخ المستودع**
```bash
git clone https://github.com/yourusername/maestro_ai.git
cd maestro_ai
```

2. **تثبيت الاعتماديات**
```bash
flutter pub get
```

3. **تشغيل التطبيق**
```bash
flutter run
```

### بناء إصدار الإنتاج

```bash
flutter build apk --release
```

سيتم إنشاء ملف APK في:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🏗️ هيكل المشروع

```
maestro_ai/
├── android/                    # كود Android Native (Kotlin)
│   └── app/src/main/kotlin/
│       └── com/maestro/ai/
│           ├── MainActivity.kt
│           └── services/
│               ├── SystemCommandExecutor.kt
│               └── MaestroAccessibilityService.kt
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/          # الثوابت والإعدادات
│   │   └── theme/              # الثيم والألوان
│   ├── models/                 # نماذج البيانات
│   ├── providers/              # Riverpod Providers
│   ├── services/               # الخدمات الأساسية
│   │   ├── ai_service.dart
│   │   ├── native_bridge.dart
│   │   ├── voice_service.dart
│   │   └── download_service.dart
│   ├── screens/                # الشاشات
│   │   ├── home/
│   │   ├── onboarding/
│   │   ├── commands/
│   │   └── settings/
│   └── widgets/                # الويدجات المشتركة
├── assets/                     # الموارد
└── pubspec.yaml
```

---

## 🔧 التقنيات المستخدمة

### Flutter & Dart
- **Flutter 3.22+** - إطار العمل الرئيسي
- **Dart 3.0+** - لغة البرمجة
- **Riverpod** - إدارة الحالة

### AI & ML
- **llama_cpp_dart** - تشغيل نموذج Llama محلياً
- **Llama 3.2 1B Instruct** - نموذج اللغة المستخدم

### Voice & Speech
- **speech_to_text** - التعرف على الكلام
- **flutter_tts** - تحويل النص لكلام

### Storage
- **Hive** - قاعدة بيانات محلية
- **path_provider** - الوصول للمسارات

### Native Android (Kotlin)
- **MethodChannel** - التواصل بين Flutter و Android
- **AccessibilityService** - خدمة إمكانية الوصول
- **SystemCommandExecutor** - منفذ أوامر النظام

---

## 📱 الصلاحيات المطلوبة

| الصلاحية | الغرض |
|---------|--------|
| `RECORD_AUDIO` | التعرف على الأوامر الصوتية |
| `CALL_PHONE` | إجراء المكالمات |
| `SEND_SMS` | إرسال الرسائل |
| `READ_CONTACTS` | الوصول لجهات الاتصال |
| `ACCESS_FINE_LOCATION` | الموقع الجغرافي |
| `CAMERA` | التقاط الصور |
| `READ_EXTERNAL_STORAGE` | قراءة الملفات |
| `WRITE_EXTERNAL_STORAGE` | كتابة الملفات |
| `ACCESS_WIFI_STATE` | التحكم بالواي فاي |
| `BLUETOOTH` | التحكم بالبلوتوث |
| `BIND_ACCESSIBILITY_SERVICE` | خدمة إمكانية الوصول |

---

## 🤝 المساهمة

نرحب بمساهماتكم! للمساهمة:

1. انسخ المستودع (Fork)
2. أنشئ فرعاً جديداً (`git checkout -b feature/amazing-feature`)
3. أجرِ تغييراتك (`git commit -m 'Add amazing feature'`)
4. ادفع للفرع (`git push origin feature/amazing-feature`)
5. افتح طلب دمج (Pull Request)

---

## 📝 الترخيص

هذا المشروع مرخص بموجب [MIT License](LICENSE).

---

## 🙏 الشكر والتقدير

- [Llama.cpp](https://github.com/ggerganov/llama.cpp) - تشغيل نماذج Llama
- [Hugging Face](https://huggingface.co/) - توفير النماذج
- [Flutter Team](https://flutter.dev) - إطار العمل الرائع

---

## 📧 التواصل

للأسئلة والاقتراحات، يمكنكم التواصل عبر:

- البريد الإلكتروني: contact@maestroai.app
- تويتر: [@MaestroAI](https://twitter.com/maestroai)

---

<p align="center">
  صنع بـ ❤️ بواسطة فريق Maestro AI
</p>
