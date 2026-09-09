# Return to Mysterious Island – Windows 10/11 Crash Fix & Launcher

> Arabic/English. حل جذري يُصلح انغلاق اللعبة فجأة وتجمّدها ومشكلة الماوس على ويندوز 10/11.

![Status](https://img.shields.io/badge/status-working-green)
![Platform](https://img.shields.io/badge/Windows-10%20%2F%2011-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## المشكلة / The Problem

لعبة **Return to Mysterious Island** (2004، محرك Kheops Staff) كانت تخرج/تُغلق من تلقاء نفسها بعد ثوانٍ من الفتح على ويندوز 10/11 الحديث، مع أخطاء في سجل الأحداث مثل:

```
Faulting application name: Game.exe, version: 1.0.3.2
Faulting module name:    Game.exe
Exception code:          0xc0000005   (Access Violation)
```

وفي بعض الأجهزة كانت النافذة تظهر لكن اللعبة **لا تستجيب** (`Application Hang`)، أو كان **الماوس لا يتحرك** داخلها.

### السبب الجذري / Root Cause

اللعبة تعتمد على **DirectDraw** القديم (حتى Microsoft أوقفته رسمياً لاحقاً). وضع **ملء الشاشة الحصري** (Exclusive Fullscreen) لم يعد مدعوماً بشكل سليم في ويندوز 10/11:

| الوضع | النتيجة بدون إصلاح |
|---|---|
| `bFullScreen=1` (ملء الشاشة) | انهيار بـ `0xc0000005` خلال ثوانٍ |
| `bFullScreen=0` (نافذة) | تجمّد / تعليق (App Hang) أو نحافة |
| `bCenterMouse=1` | الماوس محسور داخل النافذة |

الحل: **غلاف DirectDraw حديث** (`cnc-ddraw`) يعترض نداءات DirectDraw ويعرضها عبر Direct3D/OpenGL/Vulkan بشكل متوافق مع ويندوز الحديث.

---

## الحل / The Fix

هذا السكربت يقوم بـ **3 خطوات تلقائية**:

1. **تحميل وتثبيت `cnc-ddraw`** تلقائياً داخل مجلد اللعبة (إن لم يكن موجوداً) → يوقف الانهيار ويصلح ملء الشاشة.
2. **تعديل `config.ini`** تلقائياً:
   - `bFullScreen=1` (الغلاف يتحكم بالعرض بشكل آمن)
   - `bCenterMouse = 0` (لتتحرك بمؤشر الماوس بحرية)
   - `PATH=...datas` (مسار البيانات الصحيح لمجلد اللعبة)
   - **يُنشئ نسخة احتياطية** `config.ini.bak`
3. **تشغيل اللعبة** تلقائياً (`RtMI.exe` أو `Game.exe`) من مجلد العمل الصحيح.

## المتطلبات / Requirements

- Windows 10 أو Windows 11 (32/64-bit)
- PowerShell 5.1 أو أحدث (مدمج مع ويندوز)
- اتصال إنترنت مرة واحدة فقط (لتحميل `cnc-ddraw` إن لم يكن مثبتاً)
- نسخة اللعبة كاملة (GOG أو أي نسخة) في مجلد واحد

## طريقة الاستخدام / How to Use

1. نزّل الملفين التاليين وضعها داخل مجلد اللعبة (بجانب `Game.exe`):
   - `RTMI_Fix_and_Play.bat`
   - `rtmi-fix.ps1`
2. **انقر نقراً مزدوجاً** على `RTMI_Fix_and_Play.bat`.
3. انتظر حتى يجهّز العناوين الثلاثة ثم ستبدأ اللعبة.

يمكنك أيضاً تشغيل الـ PowerShell مباشرة:

```powershell
# تشغيل عادي (ينزّل cnc-ddraw إن لزم ثم يعلّب الإعدادات ويفتح اللعبة)
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1

# خيارات إضافية:
#  -Force          أعد تحميل وتثبيت cnc-ddraw من جديد حتى لو كان موجوداً
#  -SkipInstall    لا تنزّل أي شيء، فقط صحّح الإعدادات وشغّل اللعبة
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1 -Force
powershell -ExecutionPolicy Bypass -File .\rtmi-fix.ps1 -SkipInstall
```

## ماذا لو بقيت مشكلة؟ / Troubleshooting

- **ملء الشاشة ليس مثالياً / أبعاد غريبة**: افتح `cnc-ddraw config.exe` داخل مجلد اللعبة واضبط *Presentation* (Scaling / Aspect Ratio / Windowed-Borderless).
- **الماوس عالق بعد فتح اللعبة**: اضغط `Ctrl+Tab` (قفل مؤشر الغلاف) أو اضبط *Mouse* في cofig.exe.
- **اللعبة تختفي عند التنقل Alt+Tab**: في `cnc-ddraw config.exe` جرّب خيار `Nonexclusive` أو فعّل `Windowed Borderless`.
- **ملف config.ini تالف**: احذف `config.ini.bak` وامسح التعديلات، أو انسخ `config.ini.bak` فوقه ثم أعد التشغيل.
- **اللعبة مقطوعة الصوت**: من إعدادات اللعبة اختر جهاز الصوت default، أو ثبّت OpenAL من `_Redist\oalinst.exe`.

## الملفات في هذا المستودع / Repository Files

| الملف | الغرض |
|---|---|
| `RTMI_Fix_and_Play.bat` | الواجهة التنفيذية (نقر مزدوج) |
| `rtmi-fix.ps1` | منطق الإصلاح والتشغيل |
| `README.md` | الوثائق (هذا الملف) |

ملاحظة: هذا المستودع **لا يحتوي ملفات اللعبة نفسها** — النسخة كاملة من لعبتك الخاصة. نبني فقط أداة إصلاح.

## كيف يعمل cnc-ddraw من الداخل؟ / How It Works

1. لعبة 2004 تستدعي `LoadLibrary("ddraw.dll")`.
2. ويندوز يبحث عن `ddraw.dll` في **مجلد التطبيق أولاً** → يجد نسخة `cnc-ddraw`.
3. الغلاف يعترض كل نداءات DirectDraw (سطوح، عرض، مؤشر...).
4. يعرض الإطارات عبر **Direct3D 9 / OpenGL** متوافقة مع ويندوز الحديث، مع دعم ملء الشاشة الآمن والماوس.

`cnc-ddraw` هو مشروع مفتوح المصدر: [FunkyFr3sh/cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw)

## الترخيص / License

هذا السكربت مرخّص بـ [MIT](LICENSE). أداة `cnc-ddraw` لها رخصة مستقلة خاصة بها.

---

*اكتُشفت المشكلة وحُلّت على Windows 11 25H2 مع نسخة GOG من اللعبة. لا تنسَ أن اللعبة نفسها مرخّصة لك وتحتاج نسخة أصلية/متوافقة للاستخدام الخاص.*