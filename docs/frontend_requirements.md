# AI PDF Summarizer Frontend Requirements

## Overview

Thiết kế và xây dựng giao diện hoàn chỉnh cho ứng dụng đa nền tảng **“AI PDF Summarizer”** bằng Flutter, ưu tiên frontend/UI trước, chưa cần xử lý backend thật.
Toàn bộ dữ liệu AI/backend có thể dùng mock data hoặc fake API tạm thời để test giao diện và flow ứng dụng.

---

# Supported Platforms
Ứng dụng phải chạy được trên:

- Android
- iOS
- Windows
- macOS
- Linux
- Web/PWA

---

# Tech Stack

## Frontend

- Flutter
- Material 3
- Riverpod
- GoRouter
- Dio
- Responsive Framework

---

# Main Goals
Xây dựng trước:

- UI/UX hoàn chỉnh
- Responsive layout
- Navigation
- State management
- Mock API structure
- Screen flow
- Dashboard UI
- Authentication UI
- PDF summary UI
- AI chat UI

Chưa cần AI hoạt động thật.

---

# Design Style
Thiết kế hiện đại theo phong cách AI SaaS:

- Dark mode
- Glassmorphism
- Gradient xanh lá
- Minimal
- Professional
- Smooth animation
- Responsive desktop/mobile

Layout chính giống mẫu:

- Sidebar trái
- Main content giữa
- AI chat bên phải

---

# Project Architecture

Áp dụng Clean Architecture.

```plaintext

/lib

│

├── core/

│   ├── theme/

│   ├── constants/

│   ├── routes/

│   ├── widgets/

│   └── utils/

│

├── features/

│   ├── auth/

│   ├── dashboard/

│   ├── pdf\_summary/

│   ├── ai\_chat/

│   ├── history/

│   └── profile/

│

├── shared/

│

└── main.dart

```

# Yêu cầu Giao diện Ứng dụng

## 1. Splash Screen
- Animated logo
- Gradient background
- Loading animation
- Auto navigate

## 2. Login Screen
Thiết kế hiện đại kiểu AI SaaS.
**Bao gồm:**
- Email input
- Password input
- Remember me
- Login button
- Google login button
- Register button
- Forgot password

**UI:**
- Card glassmorphism
- Blur background
- Responsive

## 3. Register Screen

**Bao gồm:**
- Name
- Email
- Password
- Confirm password
- Register button

## 4. Main Dashboard Screen
- **Layout desktop:** `| Sidebar | Main Content | AI Chat |`

- **Layout mobile:** 
 - Drawer

 - ↓

 - Main content

 - ↓

 - Bottom AI Chat



## 5. Sidebar

**Bao gồm:**
- App logo
- “New Summary” button
- History section
- Search history
- Settings
- User profile
- Logout

## 6. PDF Upload Section

**Bao gồm:**
- Drag & drop area
- Upload button
- File preview
- File size
- Progress bar
- Remove file button

**Hỗ trợ:**
- Desktop drag-drop
- Mobile picker

## 7. Summary Section

**Hiển thị:**
- Summary title
- Markdown summary
- Scrollable content
- Copy button
- Download button

**Export:**
- `.txt`
- `.pdf`
- `.docx`



> *Ghi chú: Mock AI response trước.*



## 8. AI Chat Section
Thiết kế giống ChatGPT/Claude.

**Bao gồm:**
- Message bubbles
- User/AI avatars
- Markdown rendering
- Typing animation
- Auto scroll
- Chat input fixed bottom

**Hỗ trợ:**
- Multi-line input
- Send button
- Enter to send (desktop)

## 9. History Screen
**Hiển thị:**
- PDF history
- Search history
- Recent chats
- Last access time

**Có:**
- Filter
- Search
- Sort

## 10. Analytics Dashboard
Thiết kế dashboard BI hiện đại.

**Bao gồm:**
- Statistics cards
- Total PDFs
- Total summaries
- Total AI chats
- Average processing time

### Charts

Dùng: `fl_chart`

**Bao gồm:**
- Line chart
- Bar chart
- Pie chart


### Recent Activities
**Danh sách:**
- Recent uploads
- Recent summaries
- Recent chats

## 11. Profile Screen

**Bao gồm:**
- Avatar
- Name
- Email
- Theme switch
- Device list
- Logout

---

## Yêu cầu Hệ thống & Kỹ thuật



### Responsive Requirements

Ứng dụng phải responsive hoàn chỉnh:

- **Desktop:** 3-column layout, fixed sidebar, resizable content
- **Tablet:** Collapsible sidebar
- **Mobile:** Drawer navigation, bottom navigation, stacked layout

### State Management
Dùng Riverpod.
**Tạo các providers:**
- `authProvider`
- `chatProvider`
- `summaryProvider`
- `dashboardProvider`
- `historyProvider`

### Mock Backend
Tạo fake/mock services trước.


```dart

class MockSummaryService {

   Future<String> summarize() async {

     await Future.delayed(Duration(seconds: 2));

     return "Mock AI summary...";

   }

}

```


### Animation Requirements
Dùng animation mượt:
- Page transition
- Loading shimmer
- Fade animation
- Typing effect
- Hover effects (desktop)



### Theme Requirements

**Hỗ trợ:**

- Dark mode (Mặc định)
- Light mode (Optional)

**Màu chủ đạo:**
- Xanh lá nhạt
- Xanh neon
- Nền đen/xám đậm

### Packages Đề Xuất

- `flutter_riverpod`
- `go_router`
- `dio`
- `responsive_framework`
- `flutter_animate`
- `fl_chart`
- `file_picker`
- `syncfusion_flutter_pdfviewer`
- `flutter_markdown`
- `google_fonts`

---

# Kết Quả Mong Muốn

**Ứng dụng cuối cùng phải:**

- UI đẹp như AI SaaS hiện đại
- Chạy đa nền tảng
- Responsive hoàn chỉnh
- Có đầy đủ screen flow
- Có dashboard analytics
- Có AI chat UI
- Có PDF upload UI
- Có state management rõ ràng
- Sẵn sàng để kết nối backend thật sau này



> *Ghi chú: Backend integration sẽ thực hiện ở giai đoạn tiếp theo, nên code frontend phải dễ mở rộng và dễ tích hợp API.*

