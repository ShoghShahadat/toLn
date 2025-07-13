

<h1 align="center">toLn: کتابخانه انقلابی محلی‌سازی برای فلاتر</h1>

<p align="center">
  <strong>کلیدها را فراموش کنید. تنظیمات دستی را فراموش کنید. فقط کد خود را بنویسید.</strong>
</p>
<p align="center">
  <a href="https://pub.dev/packages/toln"><img src="https://img.shields.io/pub/v/toln.svg?style=for-the-badge&logo=dart" alt="Pub Version"></a>
  <a href="https://github.com/your_username/toln/blob/main/LICENSE"><img src="https://img.shields.io/github/license/your_username/toln.svg?style=for-the-badge" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/platform-flutter-02569B.svg?style=for-the-badge&logo=flutter" alt="Platform"></a>
  <a href="https://github.com/your_username/toln/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge" alt="PRs Welcome"></a>
</p>

<p align="center">
  <a href="https://github.com/ShoghShahadat/toLn/blob/main/README.md">[English Version]</a>
</p>

---

**toLn** فقط یک کتابخانه محلی‌سازی دیگر نیست؛ این یک بازنگری کامل در فلسفه این فرآیند است. ما یک دستیار هوشمند ساخته‌ایم که تمام گردش کار خسته‌کننده بین‌المللی‌سازی را به عهده می‌گیرد و به شما اجازه می‌دهد روی چیزی که واقعاً اهمیت دارد تمرکز کنید: ساختن اپلیکیشن‌های شگفت‌انگیز.

## فهرست مطالب
- [فهرست مطالب](#فهرست-مطالب)
- [🚀 انقلاب: چه چیزی `toLn` را متفاوت می‌کند؟](#-انقلاب-چه-چیزی-toln-را-متفاوت-میکند)
- [✨ ویژگی‌های کلیدی در یک نگاه](#-ویژگیهای-کلیدی-در-یک-نگاه)
- [🛠️ راهنمای عملی: محلی‌سازی یک اپلیکیشن در ۵ دقیقه](#️-راهنمای-عملی-محلیسازی-یک-اپلیکیشن-در-۵-دقیقه)
  - [قدم اول: اپلیکیشن محلی‌سازی نشده](#قدم-اول-اپلیکیشن-محلیسازی-نشده)
  - [قدم دوم: دستور جادویی `auto-apply`](#قدم-دوم-دستور-جادویی-auto-apply)
  - [قدم سوم: فایل‌های تولید شده](#قدم-سوم-فایلهای-تولید-شده)
  - [قدم چهارم: ترجمه کردن](#قدم-چهارم-ترجمه-کردن)
  - [قدم پنجم: تعاملی کردن](#قدم-پنجم-تعاملی-کردن)
- [⚙️ گردش کار `toLn`](#️-گردش-کار-toln)
- [📚 بررسی عمیق: مرجع API و CLI](#-بررسی-عمیق-مرجع-api-و-cli)
  - [کلاس `ToLn`](#کلاس-toln)
    - [`static Future<void> init({required String baseLocale, String? initialLocale})`](#static-futurevoid-initrequired-string-baselocale-string-initiallocale)
    - [`static Future<void> loadLocale(String newLocale)`](#static-futurevoid-loadlocalestring-newlocale)
    - [`static Future<List<LocaleInfo>> getAvailableLocales()`](#static-futurelistlocaleinfo-getavailablelocales)
    - [`static TextDirection get currentDirection`](#static-textdirection-get-currentdirection)
    - [`static final ValueNotifier<Locale> localeNotifier`](#static-final-valuenotifierlocale-localenotifier)
  - [متد الحاقی `.toLn()`](#متد-الحاقی-toln)
    - [`String toLn({String? key})`](#string-tolnstring-key)
  - [رابط خط فرمان (CLI)](#رابط-خط-فرمان-cli)
    - [`dart run toln auto-apply`](#dart-run-toln-auto-apply)
    - [`dart run toln extract`](#dart-run-toln-extract)
    - [`dart run toln sync`](#dart-run-toln-sync)
- [⚠️ تله `const`: یک نکته بسیار مهم](#️-تله-const-یک-نکته-بسیار-مهم)
- [💖 مشارکت](#-مشارکت)
- [📄 مجوز](#-مجوز)

---

## 🚀 انقلاب: چه چیزی `toLn` را متفاوت می‌کند؟

محلی‌سازی سنتی، یک کابوس از مدیریت کلیدها، بروزرسانی دستی فایل‌ها و خطاهای انسانی مداوم است. **`toLn` تمام این‌ها را حذف می‌کند.** ما معتقدیم که کد شما باید تنها منبع حقیقت باشد.

| قابلیت | روش قدیمی (دردسر) | روش `toLn` (جادو) |
| :--- | :--- | :--- |
| **افزودن متن جدید** | ۱. یک کلید اختراع کن. ۲. فایل `en.json` را باز کن. ۳. کلید را اضافه کن. ۴. فایل `fa.json` را باز کن. ۵. دوباره اضافه کن... | بنویسید `Text('سلام دنیا'.toLn())`. **تمام!** |
| **بازسازی یک پروژه**| غیرممکن است. باید به صورت دستی به هر رشته متنی، محلی‌سازی اضافه کنید. | `dart run toln auto-apply`. کتابخانه به صورت هوشمند تمام کدبیس شما را برایتان بازسازی می‌کند. |
| **اصلاح یک غلط املایی** | کلید را پیدا کن، آن را در تمام فایل‌های ترجمه بروز کن و امیدوار باش یکی را از قلم نینداخته باشی. | فقط متن را در کد خود اصلاح کنید. **دستیار هوشمند** ما آن را تشخیص داده و پیشنهاد استفاده مجدد از کلید قدیمی را می‌دهد. |
| **همگام‌سازی ترجمه‌ها** | مقایسه دستی فایل‌های JSON برای پیدا کردن کلیدهای گمشده. | `dart run toln sync`. تمام کلیدهای گمشده به صورت خودکار به فایل‌های زبان شما اضافه می‌شوند. |
| **بروزرسانی UI** | استفاده از `setState` یا راه‌حل‌های پیچیده مدیریت وضعیت برای بازسازی. | **کاملاً خودکار.** UI با تغییر زبان، فوراً خود را بازسازی می‌کند. |

## ✨ ویژگی‌های کلیدی در یک نگاه

-   ✅ **گردش کار بدون کلید**: شما دیگر هرگز مجبور به اختراع یا مدیریت کلید ترجمه نخواهید بود.
-   🪄 **`auto-apply` هوشمند**: با یک دستور، پروژه موجود و محلی‌سازی نشده شما را به صورت خودکار بازسازی می‌کند.
-   🧠 **دستیار هوشمند**: غلط‌های املایی و اصلاحات را تشخیص داده و برای صرفه‌جویی در کار شما، پیشنهاد استفاده مجدد از ترجمه‌های موجود را می‌دهد.
-   🔄 **بروزرسانی خودکار UI**: با استفاده از `ValueNotifier`، رابط کاربری با تغییر زبان و بدون نیاز به فراخوانی دستی `setState`، فوراً بروز می‌شود.
-   🌍 **تشخیص خودکار جهت متن**: به صورت خودکار بین چیدمان‌های راست‌چین و چپ‌چین جابجا می‌شود.
-   ⚙️ **CLI کاملاً خودکار**: یک رابط خط فرمان قدرتمند برای `extract`، `sync` و `auto-apply` کردن ترجمه‌ها.
-   🌐 **کشف پویای زبان‌ها**: به صورت خودکار تمام زبان‌های موجود در پروژه شما را برای ساخت منوهای انتخاب زبان، پیدا می‌کند.
-   💅 **نام‌های قابل تنظیم برای زبان‌ها**: از کلید اختیاری `ln_name` در فایل‌های خود استفاده کنید تا به زبان‌ها نام‌های نمایشی زیبا بدهید (مثلاً "فارسی" به جای "FA").

---

## 🛠️ راهنمای عملی: محلی‌سازی یک اپلیکیشن در ۵ دقیقه

بیایید یک اپلیکیشن واقعی را چندزبانه کنیم.

### قدم اول: اپلیکیشن محلی‌سازی نشده

فرض کنید این صفحه ساده فلاتر را دارید. به زبان انگلیسی نوشته شده و هیچ محلی‌سازی‌ای ندارد.

```dart
// lib/main.dart (قبل از toLn)
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final String username = "Maria";
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Text("Welcome, ${username}!"),
      ),
    );
  }
}
```

### قدم دوم: دستور جادویی `auto-apply`

ترمینال خود را در ریشه پروژه باز کرده و این دستور جادویی را اجرا کنید:

```bash
dart run toln auto-apply
```

### قدم سوم: فایل‌های تولید شده

`toLn` اکنون چندین کار انجام داده است:
1.  **کد شما را تغییر داده است**: `.toLn()`، `import` و فراخوانی `ToLn.init()` را اضافه کرده است.
2.  **`extract` را اجرا کرده است**: کد تغییر یافته را اسکن کرده و فایل‌هایی در `assets/locales/` ایجاد کرده است.

فایل `main.dart` شما اکنون به این شکل است:

```dart
// lib/main.dart (بعد از toLn)
import 'package:flutter/material.dart';
import 'package:toln/toln.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ToLn.init(baseLocale: 'en'); // 'en' زبان کد شماست
  runApp(const MyApp());
}
// ... (MyApp اکنون در یک ValueListenableBuilder قرار گرفته است)
class MyHomePage extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final String username = "Maria";
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page".toLn()),
      ),
      body: Center(
        child: Text("Welcome, ${username}!".toLn()),
      ),
    );
  }
}
```

و فایل `assets/locales/base.ln` شما ایجاد شده است:

```json
{
  "ln_name": "",
  "keLn1": "My App",
  "keLn2": "Home Page",
  "keLn3": "Welcome, $s!"
}
```

### قدم چهارم: ترجمه کردن

1.  `base.ln` را کپی کرده و نام آن را به `fa.ln` برای فارسی تغییر دهید.
2.  فایل جدید را باز کرده و مقادیر و نام نمایشی را ترجمه کنید.

```json
// assets/locales/fa.ln
{
  "ln_name": "فارسی",
  "keLn1": "اپلیکیشن من",
  "keLn2": "صفحه اصلی",
  "keLn3": "خوش آمدی، $s!"
}
```

### قدم پنجم: تعاملی کردن

حالا، یک انتخابگر زبان به `AppBar` اضافه می‌کنیم. `toLn` این کار را فوق‌العاده آسان می‌کند.

```dart
// در متد build ویجت MyHomePage، داخل AppBar
actions: [
  FutureBuilder<List<LocaleInfo>>(
    future: ToLn.getAvailableLocales(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();
      return PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        onSelected: ToLn.loadLocale, // جادو! نیازی به setState نیست.
        itemBuilder: (context) => snapshot.data!
            .map((locale) => PopupMenuItem(value: locale.code, child: Text(locale.name)))
            .toList(),
      );
    },
  ),
],
```
تمام شد! شما اکنون یک اپلیکیشن کاملاً محلی‌سازی شده با UI خودکار و یک منوی زبان پویا دارید.

---

## ⚙️ گردش کار `toLn`

`toLn` به گونه‌ای طراحی شده که یک گردش کار کامل باشد، نه فقط یک کتابخانه.

1.  **`dart run toln auto-apply`**: این دستور را یک بار روی پروژه خود اجرا کنید تا آن را برای محلی‌سازی آماده کنید. این دستور به صورت خودکار `extract` را نیز پس از اتمام کار خود اجرا می‌کند.
2.  **`dart run toln extract`**: هر زمان که متنی را در UI خود اضافه یا تغییر دادید، این دستور را اجرا کنید تا فایل `base.ln` شما بروز شود.
3.  **`dart run toln sync`**: این دستور را پس از `extract` اجرا کنید تا کلیدهای جدید را به تمام فایل‌های زبان دیگر شما (`fa.ln`, `de.ln` و غیره) اضافه کند تا برای ترجمه آماده شوند.

---

## 📚 بررسی عمیق: مرجع API و CLI

در اینجا یک تفکیک دقیق از تمام اجزای اکوسیستم `toLn` آورده شده است.

### کلاس `ToLn`

این کلاس اصلی است که وضعیت محلی‌سازی را مدیریت می‌کند.

#### `static Future<void> init({required String baseLocale, String? initialLocale})`
مهم‌ترین متد. این متد کل کتابخانه را راه‌اندازی می‌کند.
-   **`baseLocale`**: (الزامی) کد زبان متنی که در سورس کد خود می‌نویسید (مثلاً 'en', 'fa').
-   **`initialLocale`**: (اختیاری) زبانی که در هنگام راه‌اندازی بارگذاری می‌شود. اگر ارائه نشود، `toLn` به صورت هوشمند تلاش می‌کند از زبان سیستم دستگاه استفاده کند. اگر زبان سیستم در دسترس نباشد، به `baseLocale` شما بازمی‌گردد.

#### `static Future<void> loadLocale(String newLocale)`
زبان فعلی برنامه را تغییر می‌دهد.
-   **`newLocale`**: کد زبانی که می‌خواهید به آن جابجا شوید (مثلاً 'fa', 'de').
-   **چگونه کار می‌کند**: این متد فایل `.ln` مربوطه را بارگذاری می‌کند، جهت متن را بروز می‌کند و از طریق `ToLn.localeNotifier` به تمام شنوندگان اطلاع می‌دهد تا یک بازسازی خودکار UI را آغاز کنند.

#### `static Future<List<LocaleInfo>> getAvailableLocales()`
به صورت خودکار پوشه `assets/locales/` شما را اسکن کرده و لیستی از تمام زبان‌های موجود را برمی‌گرداند.
-   **خروجی**: یک `List` از اشیاء `LocaleInfo`. `LocaleInfo` یک رکورد است که به صورت `({String code, String name})` تعریف شده است.
-   **`code`**: کد زبان از نام فایل (مثلاً 'en').
-   **`name`**: نام نمایشی از کلید `ln_name` داخل فایل. اگر `ln_name` وجود نداشته باشد یا خالی باشد، به صورت پیش‌فرض از کد زبان با حروف بزرگ استفاده می‌شود (مثلاً 'EN').

#### `static TextDirection get currentDirection`
یک getter استاتیک که `TextDirection` صحیح (`TextDirection.rtl` یا `TextDirection.ltr`) را برای زبان فعال فعلی برمی‌گرداند.

#### `static final ValueNotifier<Locale> localeNotifier`
موتور پشت بروزرسانی‌های خودکار UI. شما می‌توانید `MaterialApp` خود (یا هر بخشی از UI خود) را در یک `ValueListenableBuilder` که به این notifier گوش می‌دهد، قرار دهید. وقتی `loadLocale` فراخوانی می‌شود، این notifier فعال شده و UI شما با ترجمه‌های جدید بازسازی می‌شود.

### متد الحاقی `.toLn()`

این متدی است که شما بیشترین استفاده را از آن خواهید داشت.

#### `String toLn({String? key})`
-   **چگونه کار می‌کند**: وقتی روی یک `String` فراخوانی می‌شود، از سینگلتون `ToLn` برای پیدا کردن ترجمه صحیح برای زبان فعلی استفاده می‌کند. این متد به صورت هوشمند رشته‌های با و بدون متغیر را مدیریت می‌کند.
-   **`key`**: (اختیاری) یک کلید دستی (مثلاً 'keLn5'). این برای موارد نادری است که می‌خواهید دو متن منبع متفاوت به یک کلید ترجمه یکسان اشاره کنند.

### رابط خط فرمان (CLI)

CLI دستیار هوشمند شما برای مدیریت فایل‌های ترجمه است.

#### `dart run toln auto-apply`
قدرتمندترین دستور. این دستور کل پروژه شما را تحلیل کرده و به صورت هوشمند برای محلی‌سازی بازسازی می‌کند.
-   **چه کاری انجام می‌دهد**:
    1.  `.toLn()` را به رشته‌های متنی داخل ویجت‌های نمایشی رایج (`Text`, `Tooltip` و غیره) و خصوصیات `InputDecoration` اضافه می‌کند.
    2.  به صورت خودکار `import 'package:toln/toln.dart';` را به هر فایلی که تغییر می‌دهد، اضافه می‌کند.
    3.  تابع `main()` شما را بررسی کرده و اطمینان حاصل می‌کند که `async` است و شامل `WidgetsFlutterBinding.ensureInitialized()` و `ToLn.init()` می‌باشد.
    4.  پس از اتمام، به **صورت خودکار دستور `extract` را اجرا می‌کند** تا فایل‌های ترجمه شما را تولید کند.
-   **گزینه‌ها**:
    -   `--dry-run`: گزارشی از آنچه تغییر خواهد کرد را بدون تغییر واقعی هیچ فایلی، نمایش می‌دهد.

#### `dart run toln extract`
پروژه شما را برای تمام فراخوانی‌های `.toLn()` اسکن کرده و فایل‌های `base.ln` و `key_map.ln` را تولید/بروزرسانی می‌کند.
-   **دستیار هوشمند**: اگر یک رشته جدید پیدا کند که بسیار شبیه به یک رشته موجود است (مثلاً شما یک غلط املایی را اصلاح کرده‌اید)، از شما می‌پرسد که آیا می‌خواهید از کلید قدیمی استفاده مجدد کنید تا ترجمه‌های موجود شما حفظ شود.

#### `dart run toln sync`
تمام فایل‌های ترجمه شما (`fa.ln`, `de.ln` و غیره) را با فایل اصلی `base.ln` شما همگام‌سازی می‌کند.
-   **چه کاری انجام می‌دهد**: کلیدهایی را که در `base.ln` وجود دارند اما در فایل‌های زبان دیگر شما موجود نیستند، پیدا کرده و به آن‌ها اضافه می‌کند. مقدار آن، متن اصلی از `base.ln` خواهد بود تا پیدا کردن و ترجمه متون جدید برای شما یا مترجمتان آسان شود.

---

## ⚠️ تله `const`: یک نکته بسیار مهم

**مشکل:** زبان من تغییر می‌کند، اما متن روی صفحه تغییر نمی‌کند!

این مشکل تقریباً همیشه به دلیل کلمه کلیدی `const` است. وقتی شما یک ویجت را به صورت `const` تعریف می‌کنید، به فلاتر می‌گویید: "این ویجت تغییرناپذیر است و **هرگز** نیازی به بازسازی نخواهد داشت."

وقتی `toLn` زبان را تغییر می‌دهد، نیاز به بازسازی UI شما دارد. اگر در مسیر خود به یک ویجت `const` برخورد کند، متوقف می‌شود و متن قدیمی شما باقی می‌ماند.

**نادرست:**
```dart
// این با تغییر زبان بروز نخواهد شد!
home: const MyAwesomePage(),
```

**صحیح:**
```dart
// حالا فلاتر اجازه دارد این صفحه را بازسازی کند.
home: MyAwesomePage(),
```

**قانون کلی: اگر یک ویجت یا هر یک از فرزندان آن حاوی متنی است که نیاز به ترجمه دارد، از `const` برای آن یا والدین آن در متد build استفاده نکنید.**

## 💖 مشارکت

ما `toLn` را ساختیم تا یک تغییردهنده بازی باشد، اما ما تازه شروع کرده‌ایم. از مشارکت‌ها، گزارش مشکلات و درخواست ویژگی‌ها استقبال می‌کنیم! با خیال راحت [صفحه مشکلات ما](https://github.com/your_username/toln/issues) را بررسی کنید.

## 📄 مجوز

این پروژه تحت مجوز MIT منتشر شده است - برای جزئیات به فایل [LICENSE](LICENSE) مراجعه کنید.
