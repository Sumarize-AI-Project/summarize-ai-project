# 📦 Phase 1 — Code Diff Report

> **Status:** ✅ Hoàn thành  
> **`flutter pub get`:** ✅ Got dependencies!

---

## Cấu trúc thư mục sau Phase 1

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          ← Breakpoints, durations, spacing
│   ├── routes/
│   │   └── app_router.dart             ← GoRouter với placeholder screens
│   ├── theme/
│   │   ├── app_colors.dart             ← Color palette (neon green, dark bg)
│   │   ├── app_text_styles.dart        ← Typography (Outfit + Inter)
│   │   ├── app_theme.dart              ← Material 3 ThemeData (dark/light)
│   │   └── glassmorphism.dart          ← Blur/glass decoration helpers
│   ├── utils/
│   │   └── responsive_helper.dart      ← isMobile/isTablet/isDesktop
│   └── widgets/
│       ├── app_button.dart             ← Gradient button + hover + loading
│       ├── app_text_field.dart         ← Custom TextField + focus glow
│       ├── glass_card.dart             ← Glassmorphism card widget
│       └── loading_shimmer.dart        ← Shimmer placeholders
├── features/
│   ├── auth/.gitkeep.dart              ← (Phase 2)
│   ├── dashboard/.gitkeep.dart         ← (Phase 3)
│   ├── pdf_summary/.gitkeep.dart       ← (Phase 4)
│   ├── ai_chat/.gitkeep.dart           ← (Phase 4)
│   ├── history/.gitkeep.dart           ← (Phase 5)
│   └── profile/.gitkeep.dart           ← (Phase 5)
├── shared/
│   └── mock_services/
│       ├── mock_auth_service.dart       ← Fake login/register
│       ├── mock_summary_service.dart    ← Fake PDF summarize + history
│       └── mock_chat_service.dart       ← Fake AI chat responses
└── main.dart                            ← ProviderScope + GoRouter + Theme
```

---

## 1. `pubspec.yaml` — Dependencies Added

```diff:pubspec.yaml
name: summarize_ai_app
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
===
name: summarize_ai_app
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # UI & Icons
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1

  # State Management
  flutter_riverpod: ^2.6.1

  # Navigation
  go_router: ^14.8.1

  # Networking
  dio: ^5.7.0

  # Responsive
  responsive_framework: ^1.5.1

  # Animations
  flutter_animate: ^4.5.2
  shimmer: ^3.0.0

  # Charts
  fl_chart: ^0.70.2

  # File Handling
  file_picker: ^8.1.7

  # PDF Viewer
  syncfusion_flutter_pdfviewer: ^28.2.12

  # Markdown
  flutter_markdown: ^0.7.6

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```

---

## 2. `main.dart` — Complete Rewrite

```diff:main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
===
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AiSummarizerApp(),
    ),
  );
}

/// Root application widget.
class AiSummarizerApp extends ConsumerWidget {
  const AiSummarizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Dark mode mặc định

      // ── Routing ────────────────────────────────────────────────────
      routerConfig: AppRouter.router,

      // ── Responsive Breakpoints ─────────────────────────────────────
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(
            start: 0,
            end: AppConstants.mobileBreakpoint,
            name: MOBILE,
          ),
          const Breakpoint(
            start: AppConstants.mobileBreakpoint + 1,
            end: AppConstants.tabletBreakpoint,
            name: TABLET,
          ),
          const Breakpoint(
            start: AppConstants.tabletBreakpoint + 1,
            end: AppConstants.desktopBreakpoint,
            name: 'TABLET_LANDSCAPE',
          ),
          const Breakpoint(
            start: AppConstants.desktopBreakpoint + 1,
            end: double.infinity,
            name: DESKTOP,
          ),
        ],
      ),
    );
  }
}

```

> [!IMPORTANT]
> `main.dart` bây giờ có:
> - `ProviderScope` bọc toàn app (Riverpod)
> - `MaterialApp.router` thay cho `MaterialApp`
> - `ThemeMode.dark` làm mặc định
> - `ResponsiveBreakpoints.builder` cho responsive layout

---

## 3. Core Theme Files

### 3.1 `app_colors.dart` — Color Palette

```dart
// Key colors:
static const Color primary = Color(0xFF00E676);       // Green accent
static const Color neonGreen = Color(0xFF39FF14);      // Neon highlight
static const Color darkBg = Color(0xFF0A0A0A);         // Main background
static const Color darkSurface = Color(0xFF1A1A2E);    // Surface color
static const Color glassWhite = Color(0x1AFFFFFF);     // Glassmorphism fill
static const Color glassBorder = Color(0x33FFFFFF);    // Glass border
```

[View full file → app_colors.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/theme/app_colors.dart)

### 3.2 `app_text_styles.dart` — Typography

- **Headings:** Outfit (48px → 18px, w700 → w500)
- **Body:** Inter (16px → 12px)
- **Special:** `neonAccent` (Outfit, green), `codeBlock` (Fira Code)

[View full file → app_text_styles.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/theme/app_text_styles.dart)

### 3.3 `app_theme.dart` — Material 3 Theme

- **Dark Theme:** Custom `ColorScheme.dark`, scaffold bg `#0A0A0A`, glassmorphism inputs, gradient buttons
- **Light Theme:** Optional, basic configuration
- **Components styled:** AppBar, Card, Input, Button, Tooltip, SnackBar, Dialog, BottomNav, Drawer

[View full file → app_theme.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/theme/app_theme.dart)

### 3.4 `glassmorphism.dart` — Glass Effects

3 presets: `cardDecoration`, `subtleDecoration`, `strongDecoration`  
Plus `blurContainer()` widget builder.

[View full file → glassmorphism.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/theme/glassmorphism.dart)

---

## 4. Core Widgets

### 4.1 `GlassCard`
Reusable frosted glass container with `BackdropFilter` + customizable blur, colors, border.

[View full file → glass_card.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/widgets/glass_card.dart)

### 4.2 `AppButton`
- Gradient fill hoặc outlined variant
- Icon + label support
- Loading spinner state
- **Desktop hover glow** (neon green shadow)

[View full file → app_button.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/widgets/app_button.dart)

### 4.3 `AppTextField`
- Focus-animated glow effect
- Prefix icon color changes on focus
- Optional label above the field

[View full file → app_text_field.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/widgets/app_text_field.dart)

### 4.4 `LoadingShimmer`
- Base shimmer line
- `LoadingShimmer.textBlock()` — multi-line text placeholder
- `LoadingShimmer.card()` — card-shaped placeholder

[View full file → loading_shimmer.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/widgets/loading_shimmer.dart)

---

## 5. Routing — `app_router.dart`

```
Routes:
├── /splash          → PlaceholderScreen("Splash")
├── /login           → PlaceholderScreen("Login")
├── /register        → PlaceholderScreen("Register")
└── /dashboard       → ShellRoute (→ PlaceholderShell)
    ├── /dashboard           → "Dashboard Home"
    ├── /dashboard/summary   → "PDF Summary"
    ├── /dashboard/chat      → "AI Chat"
    ├── /dashboard/history   → "History"
    ├── /dashboard/analytics → "Analytics"
    └── /dashboard/profile   → "Profile"
```

> [!NOTE]
> Tất cả routes hiện trỏ đến `_PlaceholderScreen` với icon 🔧 và text "Coming in next phase...". Sẽ được thay thế bằng real screens ở các Phase tiếp theo.

[View full file → app_router.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/routes/app_router.dart)

---

## 6. Mock Services

### 6.1 `MockAuthService`
- `login()` → returns `MockUser` after 2s delay
- `register()` → returns `MockUser` after 2s delay
- `logout()` → 0.5s delay

### 6.2 `MockSummaryService`
- `uploadPdf()` → returns upload ID after 2s
- `summarize()` → returns **rich markdown** summary after 3s (tables, headings, bullets)
- `getHistory()` → returns 12 mock `MockSummaryItem`s

### 6.3 `MockChatService`
- `sendMessage()` → returns random AI response (1-3s delay)
- `getInitialMessages()` → welcome message
- `getChatHistory()` → 5 mock chat sessions
- **5 diverse mock responses** with markdown formatting

---

## 7. Utilities

### `responsive_helper.dart`
- `isMobile()` / `isTablet()` / `isDesktop()`
- `responsiveValue<T>()` — select value based on screen size
- `getSidebarWidth()` / `getChatPanelWidth()`

[View full file → responsive_helper.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/utils/responsive_helper.dart)

---

## ✅ Phase 1 Checklist

| Item | Status |
|------|--------|
| `pubspec.yaml` + `flutter pub get` | ✅ |
| Clean Architecture folder structure | ✅ |
| `app_colors.dart` — Color palette | ✅ |
| `app_text_styles.dart` — Typography | ✅ |
| `app_theme.dart` — Dark/Light themes | ✅ |
| `glassmorphism.dart` — Glass helpers | ✅ |
| `app_constants.dart` — Breakpoints etc. | ✅ |
| `app_router.dart` — GoRouter routes | ✅ |
| `GlassCard` widget | ✅ |
| `AppButton` widget | ✅ |
| `AppTextField` widget | ✅ |
| `LoadingShimmer` widget | ✅ |
| `responsive_helper.dart` | ✅ |
| Mock Auth Service | ✅ |
| Mock Summary Service | ✅ |
| Mock Chat Service | ✅ |
| `main.dart` — ProviderScope + Router | ✅ |

---

> [!TIP]
> **Sẵn sàng cho Phase 2:** Nền tảng đã vững — theme, routing, widgets, mock services đều sẵn sàng. Phase 2 sẽ triển khai Splash → Login → Register screens sử dụng các components đã tạo ở đây.
