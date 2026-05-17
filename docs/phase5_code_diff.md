# 📦 Phase 5 — Code Diff: History, Analytics Dashboard & Profile

> **Status:** ✅ Build thành công  
> **Build:** `√ Built summarize_ai_app.exe` (11.7s)

---

## Cấu trúc thư mục mới

```
lib/
├── core/providers/
│   └── theme_provider.dart              ← NEW: Global dark/light toggle
├── features/
│   ├── analytics/
│   │   ├── providers/
│   │   │   └── dashboard_provider.dart  ← NEW: Mock stats & chart data
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── analytics_dashboard_screen.dart  ← NEW
│   │       └── widgets/
│   │           ├── stat_card.dart        ← NEW: Animated counter card
│   │           └── dashboard_charts.dart ← NEW: Line/Bar/Pie charts
│   ├── history/
│   │   ├── data/models/
│   │   │   └── history_item.dart        ← NEW: History item model
│   │   ├── providers/
│   │   │   └── history_provider.dart    ← NEW: Filter/sort/search
│   │   └── presentation/screens/
│   │       └── history_screen.dart      ← NEW
│   └── profile/
│       └── presentation/screens/
│           └── profile_screen.dart      ← NEW: Avatar + theme toggle
├── main.dart                            ← UPDATED: themeProvider wiring
└── core/routes/app_router.dart          ← UPDATED: All 5 branches real screens
```

**Files mới: 9** | **Files cập nhật: 2** (main.dart, router)

---

## 1. Theme Provider — Dark/Light Toggle

```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(); // Default: ThemeMode.dark
});
```

- Toggle via `ref.read(themeProvider.notifier).toggleTheme()`
- Wired into `MaterialApp.router(themeMode: ref.watch(themeProvider))`

[View → theme_provider.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/core/providers/theme_provider.dart)

---

## 2. Analytics Dashboard

### Stat Cards (Animated Counters)

| Stat | Value | Icon Color |
|------|-------|-----------|
| Total PDFs | 47 | 🔴 Red |
| Total Summaries | 38 | 🟢 Green |
| Total Chats | 124 | 🔵 Blue |
| Avg Processing | 2.8s | 🟡 Yellow |

- Counting animation: `0 → value` over 1200ms with `easeOutCubic`
- Staggered entrance: 0ms, 100ms, 200ms, 300ms delays
- Row of 4 on desktop, 2×2 grid on mobile

### Charts (fl_chart)

| Chart | Type | Data |
|-------|------|------|
| Usage (7 days) | Line chart | Mon–Sun activity counts |
| PDF Categories | Bar chart | Research/Textbook/Report/Article/Other |
| Summary Types | Pie/Donut | Brief/Standard/Detailed |

### Recent Activities
- 5 mock activity items with staggered fade-in animation
- Timeline dot + title + action + time ago

[View → analytics_dashboard_screen.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart)

---

## 3. History Screen

### Features:
```
┌─ Search ──────────────────────────────┐
│ 🔍 Search history...                  │
├─ Filters ─── [All] [PDFs] [Summaries] [Chats] ─ ⇅ Sort ─┤
│                                       │
│ 📕 Machine Learning Report.pdf    1h  │
│    Uploaded for summarization  2.4 MB  │
│                                       │
│ 📄 Summary: ML Report           1h    │
│    450 words · AI-generated           │
│                                       │
│ 💬 Chat: ML Report Discussion    2h   │
│    12 messages                         │
│ ...14 items total                     │
└───────────────────────────────────────┘
```

| Feature | Implementation |
|---------|---------------|
| Search | Real-time text filtering by title/subtitle |
| Tabs | `_FilterChip` with hover effects, active green state |
| Sort | `PopupMenuButton` — Newest/Oldest first |
| Item tiles | Color-coded icons (red PDF, green summary, blue chat) |
| Animation | Staggered fadeIn + slideX per tile |
| Empty state | "No items found" with filter suggestion |

[View → history_screen.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/features/history/presentation/screens/history_screen.dart)

---

## 4. Profile Screen

### Layout:
```
         ┌──────┐
         │  N   │  ← Gradient avatar (initial letter)
         └──────┘
      Nguyễn Văn A
     123@sfst.com

 APPEARANCE
 ┌─ 🌙 Theme ─── [Dark Mode] ── 🔘 ─┐
 └───────────────────────────────────┘

 ACCOUNT
 ┌─ 👤 Edit Profile ──────────── > ─┐
 ├─ 🔒 Change Password ─────── > ─┤
 ├─ 🔔 Notifications ─────── > ──┤
 └──────────────────────────────────┘

 ABOUT
 ┌─ ℹ️ App Version ────── 1.0.0 ────┐
 ├─ 💻 Built with ── Flutter+Riverpod ┤
 └──────────────────────────────────┘

 [────── Logout ──────]
```

| Feature | Implementation |
|---------|---------------|
| Avatar | 96px gradient circle with glow shadow |
| Theme Toggle | `Switch` calling `themeProvider.toggleTheme()` |
| Settings tiles | Reusable `_buildSettingsTile` with icon/title/subtitle/trailing |
| Logout | OutlinedButton with red accent |

[View → profile_screen.dart](file:///e:/HUS/subject/Code/Data%20Mining/Project/code/App/ai_summarize_app_project/summarize_ai_app/lib/features/profile/presentation/screens/profile_screen.dart)

---

## 5. Router Update

```diff
- PlaceholderContentScreen(title: 'Dashboard', ...)
+ AnalyticsDashboardScreen()

- PlaceholderContentScreen(title: 'History', ...)
+ HistoryScreen()

- PlaceholderContentScreen(title: 'Profile', ...)
+ ProfileScreen()
```

```diff:app_router.dart
===
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell.dart';
import '../../features/pdf_summary/presentation/screens/pdf_summary_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Application router using GoRouter with StatefulShellRoute for dashboard.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  // Branch navigator keys
  static final _dashboardNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'dashboardNav');
  static final _summaryNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'summaryNav');
  static final _chatNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'chatNav');
  static final _historyNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'historyNav');
  static final _profileNavKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileNav');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Routes ────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(
                parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (_, animation, _, child) {
            final offset = Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      // ── Dashboard (StatefulShellRoute) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard Home
          StatefulShellBranch(
            navigatorKey: _dashboardNavKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AnalyticsDashboardScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: PDF Summary
          StatefulShellBranch(
            navigatorKey: _summaryNavKey,
            routes: [
              GoRoute(
                path: '/summary',
                name: 'summary',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PdfSummaryScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: AI Chat
          StatefulShellBranch(
            navigatorKey: _chatNavKey,
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AiChatScreen(),
                ),
              ),
            ],
          ),

          // Branch 3: History
          StatefulShellBranch(
            navigatorKey: _historyNavKey,
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HistoryScreen(),
                ),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
```

---

## 6. Main.dart Update

```diff
+ import 'core/providers/theme_provider.dart';

  Widget build(BuildContext context, WidgetRef ref) {
+   final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
-     themeMode: ThemeMode.dark,
+     themeMode: themeMode,
```

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
import 'core/providers/theme_provider.dart';

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
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

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

---

## ✅ Phase 5 Complete — All Screens Implemented!

| Tab | Screen | Status |
|-----|--------|--------|
| Dashboard | `AnalyticsDashboardScreen` | ✅ Stat cards + 3 charts + activities |
| Summary | `PdfSummaryScreen` | ✅ (Phase 4) |
| AI Chat | `AiChatScreen` | ✅ (Phase 4) |
| History | `HistoryScreen` | ✅ Tabs + search + sort + 14 items |
| Profile | `ProfileScreen` | ✅ Avatar + theme toggle + settings |

### 🎨 Theme Toggle
Dark ↔ Light mode via Profile > Appearance > Theme switch

> [!TIP]
> **Toàn bộ 5 Phase đã hoàn thành!** Ứng dụng AI PDF Summarizer đã có đầy đủ UI cho tất cả màn hình. Bước tiếp theo: tích hợp real API backend (FastAPI) thay thế mock services.
