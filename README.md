<p align="center">
  <img src="assets/icon/app_icon.png" width="140" alt="HABITTO App Icon">
</p>

<h1 align="center">HABITTO</h1>

<p align="center">
  <strong>Build routines. Keep your momentum. See your progress.</strong>
</p>

<p align="center">
  A modern, customizable, and local-first habit tracker built with Flutter.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Hive-FFCA28?style=for-the-badge&logoColor=black" alt="Hive">
  <img src="https://img.shields.io/github/license/kagankurubas/habitto?style=for-the-badge" alt="License">
</p>

---
<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/download/v1.0.0/Habitto-v1.0.0.apk">
    <img
      src="https://img.shields.io/badge/Download-Android_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white"
      alt="Download Habitto APK"
    >
  </a>
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <img
      src="https://img.shields.io/github/v/release/kagankurubas/habitto?style=for-the-badge"
      alt="Latest Release"
    >
  </a>
</p>

---
## About

**HABITTO** is a customizable habit and routine tracker designed to make consistency visible, motivating, and rewarding.

Users can create routines, organize them into categories, receive reminders, track streaks, review detailed statistics, unlock achievements, and back up their data without creating an account or depending on a remote server.

The application stores its data locally using Hive, providing a fast, offline-first, and privacy-friendly experience.

## Demo

<p align="center">
  <img src="assets/readme/demo.gif" alt="HABITTO application demo" width="320">
</p>

## Download

The latest Android release is available through GitHub Releases.

<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/download/v1.0.0/Habitto-v1.0.0.apk">
    <strong>Download Habitto v1.0.0 for Android</strong>
  </a>
</p>

### Installation

1. Download the APK file.
2. Open `Habitto-v1.0.0.apk` on your Android device.
3. Allow installation from your browser or file manager if Android requests permission.
4. Install Habitto.
5. Grant notification permission to receive habit reminders.

> Habitto is currently distributed directly through GitHub and is not yet
> available on Google Play.

## Application Preview

### Personalized Home Experience

<p align="center">
  HABITTO offers multiple visual themes while preserving a clean, focused, and consistent habit-tracking experience.
</p>

<table align="center">
  <tr>
    <td align="center">
      <img src="assets/readme/home1.jpg" alt="HABITTO home screen theme preview one" width="220"><br>
      <strong>Theme Preview I</strong>
    </td>
    <td align="center">
      <img src="assets/readme/home2.jpg" alt="HABITTO home screen theme preview two" width="220"><br>
      <strong>Theme Preview II</strong>
    </td>
    <td align="center">
      <img src="assets/readme/home3.jpg" alt="HABITTO home screen theme preview three" width="220"><br>
      <strong>Theme Preview III</strong>
    </td>
  </tr>
</table>

### Habit Management and Progress

<table align="center">
  <tr>
    <td align="center">
      <img src="assets/readme/create_habit.jpg" alt="HABITTO create habit screen" width="220"><br>
      <strong>Create Habits</strong>
    </td>
    <td align="center">
      <img src="assets/readme/statistics.jpg" alt="HABITTO statistics screen" width="220"><br>
      <strong>Track Progress</strong>
    </td>
    <td align="center">
      <img src="assets/readme/achievements.jpg" alt="HABITTO achievements screen" width="220"><br>
      <strong>Unlock Achievements</strong>
    </td>
  </tr>
</table>

### Theme Customization

<p align="center">
  <img src="assets/readme/themes.jpg" alt="HABITTO theme customization screen" width="240">
</p>

<p align="center">
  Choose from multiple visual themes and appearance options to personalize the application while keeping habits clear and easy to manage.
</p>

## Features

### Habit Management

- Create, edit, complete, and delete habits
- Assign custom colors and icons
- Organize habits using customizable categories
- Filter the home screen by category
- View recent completion progress directly from the habit list
- Track daily targets and completed routines

### Flexible Scheduling

HABITTO supports multiple routine frequencies:

- Every day
- Weekdays
- Weekends
- Every `X` days
- Selected days of the week

### Progress Tracking

- Current habit streaks
- Total completed days
- 30-day completion rate
- Calendar-based completion history
- GitHub-style activity heatmap
- Daily target and completion indicators

### Statistics and Insights

- Overall performance metrics
- Weekly performance chart
- Category distribution
- Best and weakest day insights
- Shareable progress cards
- Achievement and badge system

### Reminders

- Configurable local notifications
- Custom reminder times for individual habits
- Motivational notification messages
- Notification navigation directly to the related habit

### Personalization

- Multiple application themes
- Habit-specific colors
- Custom category colors and icons
- Optional completion sound
- Optional haptic feedback

### Backup and Restore

- Export habit and category data as JSON
- Restore data from a previous JSON backup
- Cross-platform file handling
- No account or cloud service required

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter | Cross-platform user interface development |
| Dart | Application language |
| Hive | Fast local data storage |
| Table Calendar | Calendar-based habit history |
| Flutter Heatmap Calendar | Activity heatmap |
| FL Chart | Statistics and performance charts |
| Flutter Local Notifications | Scheduled habit reminders |
| Timezone | Timezone-aware notification scheduling |
| Share Plus | Backup and statistics sharing |
| File Picker | JSON backup file selection |
| AudioPlayers | Completion sound effects |
| Path Provider | Platform-specific storage paths |

## Project Structure

```text
lib/
├── models/
│   ├── habit.dart
│   ├── category_model.dart
│   └── badge_model.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── habit_detail_screen.dart
│   ├── stats_screen.dart
│   └── settings_screen.dart
│
├── services/
│   ├── backup_service.dart
│   ├── motivation_service.dart
│   ├── notification_service.dart
│   ├── share_service.dart
│   ├── stats_service.dart
│   └── theme_service.dart
│
├── widgets/
│   ├── stats/
│   ├── add_edit_habit_dialog.dart
│   ├── category_filter_bar.dart
│   ├── habit_tile.dart
│   └── badge_unlocked_dialog.dart
│
├── app_themes.dart
└── main.dart
```

## Getting Started

### Requirements

Before running the project, make sure the following tools are installed:

- Flutter SDK
- Dart SDK `3.12.2` or newer
- Android Studio, Visual Studio Code, or another Flutter-compatible IDE
- An Android emulator, iOS simulator, web browser, Windows device, or physical mobile device

### Installation

Clone the repository:

```bash
git clone https://github.com/kagankurubas/habitto.git
cd habitto
```

Install the dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

### Select a Target Device

List available devices:

```bash
flutter devices
```

Run the application on a specific device:

```bash
flutter run -d <device-id>
```

Examples:

```bash
flutter run -d chrome
flutter run -d windows
```

## Code Generation

HABITTO uses generated Hive adapters.

When a Hive model is changed, regenerate the adapter files with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated adapter files are already included in the repository, so this command is not required for a normal installation.

## Building

### Android APK

```bash
flutter build apk --release
```

The generated APK can be found under:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### Web

```bash
flutter build web
```

### Windows

```bash
flutter build windows
```

Platform-specific features such as notifications, file selection, sharing, and local storage may behave differently depending on the selected platform.

## Data and Privacy

HABITTO is designed as a local-first application.

- Habit data is stored locally using Hive
- No user account is required
- No analytics or tracking service is included
- No personal habit data is uploaded automatically
- Users can manually export their data as a JSON backup
- The application can be used without a permanent internet connection

Deleting the application or clearing its local storage may remove existing data unless a backup has been created.

## Roadmap

- [x] Add application screenshots
- [x] Add application demo GIF
- [ ] Expand automated unit and widget tests
- [ ] Add GitHub Actions for analysis and build validation
- [x] Publish downloadable Android releases
- [ ] Add additional language support
- [ ] Improve accessibility support
- [ ] Explore optional encrypted backup support

## Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Fork the repository.
2. Create a new branch:

```bash
git checkout -b feature/my-feature
```

3. Commit your changes:

```bash
git commit -m "Add my feature"
```

4. Push the branch:

```bash
git push origin feature/my-feature
```

5. Open a pull request.

Please keep changes focused and run the following commands before submitting:

```bash
flutter analyze
flutter test
```

## License

This project is licensed under the [MIT License](LICENSE).

## Author

Developed by **Nuri Kağan Kurubaş**.

<p>
  <a href="https://github.com/kagankurubas">
    <img src="https://img.shields.io/badge/GitHub-kagankurubas-181717?style=for-the-badge&logo=github" alt="GitHub Profile">
  </a>
  <a href="https://kagankurubas.github.io">
    <img src="https://img.shields.io/badge/Portfolio-Visit-6C63FF?style=for-the-badge" alt="Portfolio Website">
  </a>
</p>

---

<p align="center">
  Built with Flutter and a focus on consistency, privacy, and measurable progress.
</p>
