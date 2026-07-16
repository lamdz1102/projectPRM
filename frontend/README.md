# PIGGY BANK APP – TÀI LIỆU PHÂN TÍCH SOURCE, SCREEN FLOW VÀ KỊCH BẢN TRÌNH BÀY

## 1. Tổng quan

Piggy Bank App là ứng dụng Flutter hỗ trợ người dùng tạo và quản lý nhiều mục tiêu tiết kiệm độc lập dưới hình thức các “Piggy”. Mỗi Piggy đại diện cho một mục tiêu cụ thể như mua laptop, đóng học phí, đi du lịch hoặc mua điện thoại.

Ứng dụng không chỉ ghi nhận số tiền đã tiết kiệm mà còn bổ sung các cơ chế hỗ trợ thay đổi hành vi: kế hoạch tiết kiệm tự động, mô phỏng tương lai, heo đất ảo, nhiệm vụ hằng ngày, thông báo theo ngữ cảnh và khoảng chờ trước khi đập heo sớm.

Source hiện tại gồm 37 file Dart trong `lib`, khoảng 7.389 dòng code, được chia thành 8 model, 13 screen, 8 service và 7 widget.

## 2. Giá trị chính của ứng dụng

- Quản lý nhiều mục tiêu tiết kiệm riêng biệt.
- Biến mục tiêu tài chính thành kế hoạch hành động theo ngày, tuần và tháng.
- Tự điều chỉnh số tiền cần tiết kiệm khi người dùng bỏ lỡ một ngày.
- Game hóa việc tiết kiệm bằng cấp độ, trạng thái cảm xúc, streak và huy hiệu.
- Cho phép thử trước tác động của một khoản tiền mà không thay đổi dữ liệu thật.
- Tạo nhiệm vụ hằng ngày để duy trì thói quen.
- Nhắc đúng thời điểm dựa trên tiến độ và deadline.
- Giảm quyết định bốc đồng bằng thời gian bình tĩnh trước khi đập heo.
- Ghi nhận lỗi production bằng Firebase Crashlytics.

## 3. Screen flow tổng quát

```text
main.dart
  ├─ Khởi tạo Firebase
  ├─ Gắn Crashlytics error handlers
  ├─ Khởi tạo local notification
  └─ PiggyBankApp
       ↓
SplashScreen (5 giây)
       ↓
OnboardingScreen
       ↓
LoginScreen
       ↓
PiggyDashboardScreen
       ├─ CreatePiggyScreen
       ├─ PiggyDetailScreen
       │    ├─ PiggyPetScreen
       │    ├─ SavingPlanScreen
       │    ├─ FutureSimulatorScreen
       │    ├─ SavingMissionsScreen
       │    ├─ PiggyHistoryScreen
       │    └─ BreakProtectionScreen
       ├─ Recent Activities Bottom Sheet
       ├─ Notification Settings Dialog
       └─ CrashDemoScreen
```

## 4. Flow nghiệp vụ chính

### 4.1 Tạo Piggy

```text
Dashboard → Tạo mới → Nhập thông tin → Xem trước kế hoạch
→ Xác nhận → Dashboard gọi POST /api/piggies
→ Backend trả Piggy → thêm vào danh sách
→ kiểm tra notification và lên lịch nhắc deadline
```

### 4.2 Bỏ tiền

```text
Detail → Bỏ tiền vào → Chọn nhanh hoặc nhập số tiền → ghi chú
→ POST /{id}/deposit → backend trả Piggy mới
→ so sánh cấp độ cũ/mới → nếu lên cấp thì hiện animation
→ trả Piggy mới về Dashboard → cập nhật danh sách
→ tải lại hoạt động → kiểm tra mốc 50%, 80%, 100%
```

### 4.3 Mô phỏng tương lai

```text
Detail → Mô phỏng → kéo slider chọn khoản tiền giả định
→ tạo bản sao Piggy trong bộ nhớ → tính lại kế hoạch và cấp độ
→ hiển thị trước/sau → Bỏ đúng số tiền này
→ quay lại Detail → mở form deposit với số tiền được điền sẵn
```

### 4.4 Đập heo

```text
Detail → Tùy chọn Piggy → Đập heo
  ├─ Nếu đang ACTIVE: mở BreakProtectionScreen
  │    → chọn lý do → chờ 1 phút demo
  │    → xác nhận → POST /{id}/break
  └─ Nếu COMPLETED hoặc LOCKED: xác nhận trực tiếp
       → POST /{id}/break
→ animation đập heo → trả Piggy mới về Dashboard
```

### 4.5 Xóa Piggy

```text
Dashboard hoặc Detail → Xác nhận xóa
→ DELETE /{id}
→ xóa khỏi danh sách
→ hủy notification và xóa các cờ chống gửi trùng
```

## 5. Mô tả chi tiết từng màn hình

### 5.1 SplashScreen

File: `lib/screens/splash_screen.dart`

- Hiển thị logo savings, tên Piggy Bank và slogan.
- Dừng 5 giây rồi `pushReplacement` sang Onboarding.
- Hiện chưa ghi nhớ việc người dùng đã xem onboarding, nên mỗi lần mở app đều đi qua flow này.

### 5.2 OnboardingScreen

File: `lib/screens/onboarding_screen.dart`

- Giới thiệu khả năng tạo nhiều Piggy, đặt mục tiêu, deadline và theo dõi tiến độ.
- Nút Đăng nhập mở LoginScreen.
- Nút Đăng ký hiện chưa có xử lý.

### 5.3 LoginScreen

File: `lib/screens/login_screen.dart`

- Có input email/số điện thoại, mật khẩu, ẩn/hiện mật khẩu, quên mật khẩu và đăng ký.
- Nút đăng nhập hiện chuyển thẳng sang Dashboard.
- Chưa gọi API, chưa kiểm tra tài khoản, chưa có JWT/access token/refresh token.

### 5.4 PiggyDashboardScreen

File: `lib/screens/piggy_dashboard_screen.dart`

- Là màn hình trung tâm.
- Gọi GET `/api/piggies` để tải danh sách.
- Tính tổng tiền của các Piggy chưa bị đập.
- Hiển thị số Piggy đang được theo dõi.
- Mỗi Piggy card có avatar, tên, trạng thái, cấp heo ảo, số tiền, progress, ngày còn lại và gợi ý tiết kiệm/ngày.
- Có tạo mới, xóa nhanh, mở Detail.
- AppBar có Crash Demo, hoạt động gần đây và cài đặt notification.
- Tên người dùng “Lam” hiện được hard-code.

### 5.5 CreatePiggyScreen

File: `lib/screens/create_piggy_screen.dart`

Input:
- Avatar.
- Tên Piggy.
- Số tiền mục tiêu.
- Ngày bắt đầu.
- Ngày kết thúc.
- Ghi chú/lý do tạo mục tiêu.

Validation:
- Không bỏ trống trường bắt buộc.
- Số tiền lớn hơn 0.
- Ngày kết thúc không trước ngày bắt đầu.

Điểm nổi bật:
- Khi đủ mục tiêu và ngày, màn hình hiển thị trước `SavingPlanCard`.
- Người dùng thấy số tiền/ngày, tuần, tháng trước khi tạo.

### 5.6 PiggyDetailScreen

File: `lib/screens/piggy_detail_screen.dart`

Bố cục rút gọn:
- Header avatar, tên, trạng thái.
- Card tổng quan tiền hiện tại/mục tiêu, progress, số tiền thiếu và thời gian.
- Card tóm tắt Heo đất ảo.
- Card tóm tắt Kế hoạch tiết kiệm.
- Công cụ: Mô phỏng, Nhiệm vụ, Lịch sử.
- Nút Bỏ tiền vào.
- Nút Tùy chọn/Xử lý Piggy.

Quy tắc:
- Chỉ cho deposit khi Piggy chưa broken, chưa locked và chưa completed.
- Piggy inactive chỉ còn lịch sử và các tùy chọn xử lý.

### 5.7 PiggyPetScreen

File: `lib/screens/piggy_pet_screen.dart`

- Dùng `PiggyPetCard` để hiển thị trạng thái đầy đủ.
- Tải lịch sử deposit từ backend.
- Tính cấp độ, mood, thông điệp, streak, kỷ lục và huy hiệu.

### 5.8 SavingPlanScreen

File: `lib/screens/saving_plan_screen.dart`

- Hiển thị kế hoạch đầy đủ bằng `SavingPlanCard`.
- Có trạng thái, số tiền cần tiết kiệm theo ngày/tuần/tháng, số tiền thiếu, thời gian còn lại, số tiền đáng lẽ đạt hôm nay và ngày dự kiến hoàn thành.

### 5.9 FutureSimulatorScreen

File: `lib/screens/future_simulator_screen.dart`

- Cho người dùng kéo slider từ 0 đến số tiền còn thiếu.
- So sánh tiến độ, tiền/ngày, ngày dự kiến hoàn thành và cấp độ trước/sau.
- Không thay đổi dữ liệu thật khi chỉ kéo slider.
- Nút “Bỏ đúng số tiền này” trả số tiền về Detail để mở form deposit.

### 5.10 SavingMissionsScreen

File: `lib/screens/saving_missions_screen.dart`

- Tải deposit của Piggy.
- Tạo 3 nhiệm vụ theo ngày.
- Hiển thị tiến độ nhiệm vụ, tổng XP và chuỗi ngày hoạt động.
- Có pull-to-refresh và màn lỗi có nút thử lại.

Nhiệm vụ:
1. Ngày không chi tiêu – 30 XP – tự xác nhận.
2. Cho Piggy ăn – 50 XP – tự động kiểm tra tổng deposit trong ngày.
3. Nhìn lại mục tiêu – 20 XP – tự xác nhận.

### 5.11 PiggyHistoryScreen

File: `lib/screens/piggy_history_screen.dart`

- Gọi GET `/{id}/deposits`.
- Hiển thị số tiền, ngày và ghi chú của mỗi deposit.
- Có loading, error, empty state và pull-to-refresh khi có danh sách.

### 5.12 BreakProtectionScreen

File: `lib/screens/break_protection_screen.dart`

- Hiển thị hậu quả của việc đập sớm.
- Hiển thị lại ghi chú/lý do tạo Piggy.
- Cho chọn lý do đập.
- Lưu yêu cầu và thời điểm mở khóa bằng SharedPreferences.
- Đồng hồ tiếp tục chạy khi người dùng rời màn hình.
- Chế độ demo chờ 1 phút; thực tế có thể đổi thành 24 giờ.

### 5.13 CrashDemoScreen

File: `lib/screens/crash_demo_screen.dart`

- Ghi custom log và custom key.
- Tạo lỗi non-fatal bằng `int.parse` sai, app vẫn chạy.
- Tạo fatal crash bằng `FirebaseCrashlytics.instance.crash()`.
- Dùng để demo sự khác nhau giữa log, non-fatal và fatal.

## 6. Data models

### Piggy

- id, name, avatar.
- targetAmount, currentAmount.
- startDate, endDate.
- note.
- isBroken, status.
- Getter progress, daysLeft, isLocked, isCompleted, displayStatus.

### PiggyDeposit

- id, piggyId, amount, date, note.

### ActivityLog

- type, piggyName, amount, time, message.

### SavingPlan

- remainingAmount.
- totalPlanDays, elapsedDays, remainingDays.
- originalDailyTarget.
- requiredPerDay, requiredPerWeek, requiredPerMonth.
- expectedAmountToday, differenceFromPlan.
- averageSavedPerDay, estimatedCompletionDate.
- status.

### PiggyPetState

- level, stageName, stageEmoji, levelProgress.
- mood, moodEmoji, moodLabel, message.
- currentStreak, longestStreak, daysSinceLastDeposit.
- achievements.

### SavingMission

- id theo Piggy + ngày + loại nhiệm vụ.
- dateKey, icon, title, description, xpReward, type, targetAmount, isCompleted.

### FutureSimulationResult

- Khoản tiền mô phỏng.
- Progress cũ/mới.
- Kế hoạch cũ/mới.
- Level cũ/mới.
- Số ngày dự kiến tiết kiệm được.

### BreakProtectionRequest

- piggyId, reason, requestedAt, availableAt.

## 7. Services và vai trò

### PiggyApiService

- Giao tiếp REST API.
- Base URL hiện tại: `http://10.0.2.2:8080/api/piggies`.
- Android Emulator dùng 10.0.2.2; web/Windows cần localhost; điện thoại thật cần IP LAN.

### SavingPlanService

- Thuật toán kế hoạch thích ứng.
- Không lưu kế hoạch; luôn tính lại từ Piggy và ngày hiện tại.

### PiggyPetService

- Tính level, tiến độ lên cấp, mood, streak, kỷ lục và huy hiệu.

### FutureSimulationService

- Tạo Piggy giả trong bộ nhớ và so sánh trước/sau.

### SavingMissionService

- Tạo nhiệm vụ theo ngày.
- Kiểm tra deposit tự động.
- Lưu completion, XP và active days trong SharedPreferences.

### BreakProtectionService

- Lưu/đọc/xóa yêu cầu chờ trước khi đập heo.

### NotificationService

- Khởi tạo local notification.
- Xin quyền.
- Timezone Asia/Ho_Chi_Minh.
- Show, schedule, repeat, cancel.
- Payload mở đúng Piggy.

### NotificationRuleService

- Định nghĩa quy tắc nghiệp vụ cho notification.
- Chống gửi trùng bằng SharedPreferences.

## 8. Thuật toán kế hoạch tiết kiệm

Các ngày được tính theo ngày lịch và bao gồm cả ngày bắt đầu, ngày kết thúc.

```text
remainingAmount = max(0, targetAmount - currentAmount)
requiredPerDay = remainingAmount / remainingDays
requiredPerWeek = min(remainingAmount, requiredPerDay × 7)
requiredPerMonth = min(remainingAmount, requiredPerDay × 30)
expectedAmountToday = targetAmount × elapsedDays / totalPlanDays
averageSavedPerDay = currentAmount / elapsedDays
```

Ngày dự kiến hoàn thành:

```text
estimatedRemainingDays = ceil(remainingAmount / averageSavedPerDay)
estimatedCompletionDate = today + estimatedRemainingDays
```

Phân loại tiến độ dùng tolerance:

```text
tolerance = max(originalDailyTarget × 2, targetAmount × 5%)
```

- difference > tolerance: vượt kế hoạch.
- difference < -tolerance: chậm tiến độ.
- nằm trong tolerance: đúng tiến độ.

Ví dụ test trong source:
- Mục tiêu 1.000.000đ.
- Đã có 200.000đ.
- Kế hoạch 1/1 đến 10/1.
- Hôm nay 5/1.
- Còn 800.000đ, còn 6 ngày tính cả hôm nay và 10/1.
- Cần khoảng 133.333đ/ngày.
- Trạng thái chậm tiến độ.

## 9. Heo đất ảo

### Level

- Level 1: dưới 10% – Trứng Piggy.
- Level 2: 10% đến dưới 30% – Piggy con.
- Level 3: 30% đến dưới 60% – Piggy trưởng thành.
- Level 4: 60% đến dưới 100% – Piggy hoàng gia.
- Level 5: 100% – Piggy huyền thoại.

### Mood – thứ tự ưu tiên

1. Broken: đã kết thúc.
2. Completed: ăn mừng.
3. Chưa từng deposit: đang chờ/đói.
4. Streak từ 7 ngày: cực kỳ hào hứng.
5. Không deposit từ 7 ngày: buồn.
6. Không deposit từ 3 ngày: buồn ngủ.
7. Chậm tiến độ/quá hạn: lo lắng.
8. Streak từ 3 ngày: vui vẻ.
9. Mặc định: vui vẻ.

### Huy hiệu

- Khởi đầu tốt: deposit đầu tiên.
- Kiên trì 3 ngày.
- Kiên trì 7 ngày.
- Nửa chặng đường: 50%.
- Gần cán đích: 80%.
- Chinh phục mục tiêu: 100%.
- Về đích sớm: hoàn thành trước hoặc đúng hạn.

Nhiều deposit trong cùng một ngày chỉ tính là một ngày streak.

## 10. Notification theo ngữ cảnh

Các quy tắc hiện có:

- Hoàn thành 100%.
- Quá hạn nhưng chưa hoàn thành.
- Sau ít nhất một ngày vẫn chưa bắt đầu deposit.
- Còn tối đa 3 ngày và dưới 50%: cảnh báo chậm gần deadline.
- Còn tối đa 3 ngày và đã từ 50%: nhắc sắp đến hạn.
- Đã qua hơn nửa thời gian nhưng dưới 50%: chậm tiến độ.
- Đạt 80%.
- Đạt 50%.
- Nhắc tiết kiệm hằng ngày lúc 20:00.
- Lịch nhắc 3 ngày trước deadline lúc 09:00.

Notification Piggy có payload:

```json
{"type":"piggy_detail","piggyId":1}
```

Khi bấm notification, Dashboard tìm Piggy theo ID và mở đúng Detail. Nếu app được mở từ trạng thái tắt, ID được giữ tạm rồi xử lý sau khi Dashboard tải xong.

## 11. API frontend đang yêu cầu

| Method | Endpoint | Công dụng |
|---|---|---|
| GET | `/api/piggies` | Danh sách Piggy |
| POST | `/api/piggies` | Tạo Piggy |
| POST | `/api/piggies/{id}/deposit` | Bỏ tiền |
| GET | `/api/piggies/{id}/deposits` | Lịch sử deposit |
| POST | `/api/piggies/{id}/break` | Đập Piggy |
| DELETE | `/api/piggies/{id}` | Xóa Piggy |
| GET | `/api/piggies/activities/recent` | Hoạt động gần nhất |

## 12. Data storage

### Backend/API

Frontend kỳ vọng backend lưu:
- Piggy.
- Deposit.
- Recent activities.

### SharedPreferences

Lưu cục bộ:
- Bật/tắt notification.
- Cờ notification đã gửi.
- Mission đã hoàn thành.
- Tổng XP.
- Active days để tính streak nhiệm vụ.
- Break protection request.

### Firebase Crashlytics

Lưu:
- Crash.
- Non-fatal errors.
- Stack trace.
- Custom keys.
- Custom logs.

## 13. Trạng thái Piggy

- ACTIVE: đang tiết kiệm.
- LOCKED: đã hết thời gian/không nhận thêm deposit.
- COMPLETED: đã đạt mục tiêu.
- BROKEN: đã đập và kết thúc.

Lưu ý: frontend dựa vào status backend trả về. Việc chuyển ACTIVE sang LOCKED hoặc COMPLETED cần backend xử lý đúng.

## 14. Điểm khác biệt với app banking thông thường

- Không tập trung vào chuyển tiền/thanh toán mà tập trung vào hành vi tiết kiệm theo mục tiêu.
- Kế hoạch tự thích ứng thay vì chỉ có progress bar.
- Heo ảo phản ứng theo hành vi thực tế.
- Mô phỏng what-if trước khi deposit.
- Nhiệm vụ hằng ngày và XP.
- Notification dựa trên ngữ cảnh, không chỉ nhắc cố định.
- Khoảng chờ chống quyết định bốc đồng.
- Crash monitoring được tích hợp làm tính năng kỹ thuật có thể demo.

## 15. Kịch bản demo 10–15 phút

### 0:00–1:00 – Mở đầu

“Piggy Bank là ứng dụng quản lý mục tiêu tiết kiệm cá nhân. Điểm khác biệt của app là không chỉ ghi nhận tiền, mà còn lập kế hoạch tự động, game hóa thói quen, dự đoán tương lai và giảm quyết định tài chính bốc đồng.”

### 1:00–2:00 – Flow khởi động

- Splash.
- Onboarding.
- Login.
- Nói rõ login hiện là giao diện demo nếu giảng viên hỏi.

### 2:00–3:30 – Dashboard

- Tổng tiền.
- Danh sách Piggy.
- Trạng thái, progress, level, gợi ý/ngày.
- Activity, notification settings, Crash Demo.

### 3:30–5:00 – Tạo Piggy

- Chọn avatar.
- Nhập mục tiêu và ngày.
- Nhấn mạnh preview kế hoạch tự động.
- Tạo và quay lại Dashboard.

### 5:00–7:00 – Detail và deposit

- Mở Detail rút gọn.
- Giải thích summary cards.
- Bỏ tiền bằng quick amount.
- Sau deposit, app cập nhật progress và có thể hiện animation tiến hóa.

### 7:00–8:30 – Kế hoạch và mô phỏng

- Mở Saving Plan.
- Giải thích adaptive daily amount.
- Mở Future Simulator.
- Kéo slider và so sánh trước/sau.

### 8:30–10:00 – Heo ảo và nhiệm vụ

- Mở Piggy Pet.
- Giải thích level, mood, streak, badge.
- Mở Missions.
- Demo nhiệm vụ manual và deposit tự động.

### 10:00–11:30 – Notification

- Bật/tắt notification.
- Trình bày rule 50%, 80%, deadline, overdue và daily reminder.
- Giải thích tap notification mở đúng Piggy.

### 11:30–13:00 – Break protection

- Chọn Đập heo.
- Xem hậu quả và lời nhắn mục tiêu.
- Chọn lý do, chạy timer 1 phút demo.
- Giải thích dữ liệu timer vẫn được lưu khi rời app.

### 13:00–14:30 – Crashlytics

- Custom log.
- Non-fatal.
- Fatal crash.
- Mở Firebase Console để xem report nếu có kết nối.

### 14:30–15:00 – Kết luận

“Ứng dụng kết hợp quản lý mục tiêu, thuật toán kế hoạch, game hóa, notification theo ngữ cảnh và crash monitoring. Hướng phát triển tiếp theo là hoàn thiện authentication, đồng bộ XP/missions lên backend và hỗ trợ nhiều thiết bị.”

## 16. Slide đề xuất

1. Bài toán và mục tiêu.
2. Đối tượng sử dụng.
3. Điểm khác biệt.
4. Screen flow.
5. Kiến trúc source.
6. Data model và REST API.
7. Tính năng CRUD Piggy.
8. Kế hoạch tiết kiệm tự động.
9. Heo đất ảo và nhiệm vụ.
10. Future Simulator và Break Protection.
11. Notification theo ngữ cảnh.
12. Firebase Crashlytics.
13. Demo.
14. Hạn chế và hướng phát triển.
15. Kết luận.

## 17. Các hạn chế cần trình bày trung thực

- Login/Register/Forgot Password chưa có nghiệp vụ thật.
- Tên người dùng Dashboard đang hard-code.
- Backend folder trong ZIP đang trống; frontend cần backend ngoài chạy ở port 8080.
- Base URL hard-code cho Android Emulator.
- Trong ZIP hiện thiếu `lib/firebase_options.dart` dù `main.dart` đang import; nếu máy local có file thì không ảnh hưởng, nếu chưa có cần chạy `flutterfire configure`.
- Mission, XP và Break Protection lưu cục bộ, chưa đồng bộ đa thiết bị.
- Context notification activity chưa lưu backend.
- Test hiện có chủ yếu cho SavingPlanService và app load; chưa đủ coverage cho các tính năng mới.
- `PiggyDetailScreen` vẫn còn dài, có thể tiếp tục tách phần deposit/break/options.
- Dashboard còn danh sách deposit hard-code và truyền vào Detail nhưng Detail hiện không sử dụng.
- `saving_mission_card.dart` hiện không được dùng sau khi chuyển Missions sang màn hình riêng.
- Android app label vẫn là `frontend`.

## 18. Câu hỏi phản biện thường gặp

### Vì sao kế hoạch không lưu backend?

Vì kế hoạch là dữ liệu dẫn xuất từ số tiền hiện tại, mục tiêu và thời gian. Tính lại giúp luôn phản ánh ngày hiện tại và giảm nguy cơ dữ liệu kế hoạch bị lệch.

### Vì sao dùng SharedPreferences?

Dùng cho dữ liệu nhỏ, local-first, không nhạy cảm như flags notification, XP demo và timer. Với production, các dữ liệu cần đồng bộ sẽ chuyển lên backend.

### Vì sao cần Future Simulator?

Nó giúp người dùng thấy tác động của một quyết định trước khi thực hiện, biến con số deposit thành thay đổi cụ thể về tiến độ, áp lực/ngày và ngày hoàn thành.

### Vì sao cần Break Protection?

Đây là ứng dụng của tài chính hành vi: thêm ma sát có chủ đích để giảm quyết định bốc đồng và nhắc lại lý do ban đầu của mục tiêu.

### Try-catch khác Crashlytics thế nào?

Try-catch xử lý lỗi tại chỗ; Crashlytics thu thập lỗi từ thiết bị người dùng, stack trace và ngữ cảnh để developer phân tích tập trung.

### Notification có phải push notification không?

Hiện tại là local notification được schedule trên thiết bị, không phải FCM push từ server.

## 19. Checklist trước khi demo

- Backend chạy port 8080.
- Android Emulator được chọn.
- `baseUrl` là 10.0.2.2.
- Firebase options tồn tại.
- Internet và notification permission hoạt động.
- Có ít nhất một Piggy ACTIVE còn hạn.
- Có một Piggy gần 50%/80% để demo milestone.
- Break cooldown đang là 1 phút.
- Firebase Console mở sẵn nếu demo Crashlytics.
- Chạy `flutter analyze` và `flutter test`.