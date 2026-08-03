<p align="center">
  <img
    src="assets/icon/app_icon.png"
    width="140"
    alt="Habitto App Icon"
  >
</p>

<h1 align="center">HABITTO</h1>

<p align="center">
  <a href="#english">English</a> | <a href="#türkçe">Türkçe</a>
</p>

---

<h2 id="english">English</h2>

<p align="center">
  <strong>Build routines. Keep your momentum. See your progress.</strong>
</p>

<p align="center">
  A modern, customizable, and local-first habit tracker built with Flutter.
</p>

<p align="center">
  <img
    src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"
    alt="Flutter"
  >
  <img
    src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"
    alt="Dart"
  >
  <a href="https://github.com/kagankurubas/habitto/actions/workflows/flutter-ci.yml">
    <img
      src="https://img.shields.io/github/actions/workflow/status/kagankurubas/habitto/flutter-ci.yml?branch=main&style=for-the-badge&label=CI"
      alt="Flutter CI"
    >
  </a>
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <img
      src="https://img.shields.io/github/v/release/kagankurubas/habitto?style=for-the-badge&label=Release"
      alt="Latest Release"
    >
  </a>
</p>

<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <img
      src="https://img.shields.io/badge/Download-Android_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white"
      alt="Download Habitto for Android"
    >
  </a>
</p>

---

### What's New in v1.1.0 🚀
- **Multi-Language Support**: Habitto now speaks both English and Turkish!
- **Enhanced Badge System**: New achievements added with beautiful animated pop-ups when unlocked.
- **Reliable Notifications**: Timezone-aware local notifications for accurate reminders anywhere in the world.
- **Improved UI/UX**: Smarter insight cards and cleaner statistical visualizations.

---

### About

**Habitto** is a customizable habit and routine tracker designed to make consistency visible, motivating, and rewarding.

Users can create routines, organize them into categories, receive reminders, track streaks, review detailed statistics, unlock achievements, and back up their data without creating an account or depending on a remote server.

Habitto stores its data locally using Hive, providing a fast, offline-first, and privacy-focused experience.

### Demo

<p align="center">
  <img
    src="assets/readme/enImages/demo.gif"
    alt="Habitto application demo"
    width="320"
  >
</p>

### Download

The latest Android version of Habitto is available through GitHub Releases.

<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <strong>Download the latest Habitto release for Android</strong>
  </a>
</p>

#### Android Installation

1. Open the latest release page.
2. Download the Habitto APK from the **Assets** section.
3. Open the downloaded APK on your Android device.
4. Allow installation from your browser or file manager if Android requests permission.
5. Install and open Habitto.
6. Grant notification permission to receive habit reminders.

> Habitto is currently distributed directly through GitHub and is not yet available on Google Play.

### Application Preview

#### Personalized Home Experience

<p align="center">
  Habitto offers multiple visual themes while preserving a clean,
  focused, and consistent habit-tracking experience.
</p>

<table align="center">
  <tr>
    <td align="center">
      <img
        src="assets/readme/enImages/home1.jpg"
        alt="Habitto home screen theme preview one"
        width="220"
      >
      <br>
      <strong>Theme Preview I</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/enImages/home2.jpg"
        alt="Habitto home screen theme preview two"
        width="220"
      >
      <br>
      <strong>Theme Preview II</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/enImages/home3.jpg"
        alt="Habitto home screen theme preview three"
        width="220"
      >
      <br>
      <strong>Theme Preview III</strong>
    </td>
  </tr>
</table>

#### Habit Management and Progress

<table align="center">
  <tr>
    <td align="center">
      <img
        src="assets/readme/enImages/create_habit.jpg"
        alt="Habitto create habit screen"
        width="300"
      >
      <br>
      <strong>Create Habits</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/enImages/achievements.jpg"
        alt="Habitto achievements screen"
        width="300"
      >
      <br>
      <strong>Unlock Achievements</strong>
    </td>
  </tr>
</table>

#### Statistics and Insights

<p align="center">
  Track your progress over time with detailed charts and intelligent performance metrics.
</p>

<table align="center">
  <tr>
    <td align="center">
      <img
        src="assets/readme/enImages/Stat1.jpg"
        alt="Habitto statistics view one"
        width="300"
      >
      <br>
      <strong>Performance Dashboard</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/enImages/Stat2.jpg"
        alt="Habitto statistics view two"
        width="300"
      >
      <br>
      <strong>Weekly Insights</strong>
    </td>
  </tr>
</table>

### Features

#### Habit Management

- Create, edit, complete, and delete habits
- Assign custom colors and icons
- Organize habits using customizable categories
- Filter the home screen by category
- View recent completion progress directly from the habit list
- Track daily targets and completed routines

#### Flexible Scheduling

Habitto supports multiple routine frequencies:

- Every day
- Weekdays
- Weekends
- Every `X` days
- Selected days of the week

#### Progress Tracking

- Current habit streaks
- Total completed days
- 30-day completion rate
- Calendar-based completion history
- GitHub-style activity heatmap
- Daily target and completion indicators

#### Statistics and Insights

- Overall performance metrics
- Weekly performance chart
- Category distribution
- Best and weakest day insights
- Shareable progress cards
- Achievement and badge system

#### Reminders

- Configurable local notifications
- Custom reminder times for individual habits
- Motivational notification messages
- Notification navigation directly to the related habit
- Notifications while the application is open, in the background, or closed

#### Personalization

- Multiple application themes
- Habit-specific colors
- Custom category colors and icons
- Optional completion sound
- Optional haptic feedback
- **Bilingual Interface** (English and Turkish)

#### Backup and Restore

- Export habit and category data as JSON
- Restore data from a previous JSON backup
- Cross-platform file handling
- No account or cloud service required

### Tech Stack

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
| Easy Localization | Multi-language translation support |
| GitHub Actions | Automated analysis, testing, and build validation |

### Roadmap

- [x] Add application screenshots
- [x] Add application demo GIF
- [x] Add initial unit tests
- [ ] Expand unit and widget test coverage
- [x] Add GitHub Actions for analysis, tests, and build validation
- [x] Publish downloadable Android releases
- [x] Add additional language support (Turkish added in v1.1.0)
- [ ] Improve accessibility support
- [ ] Explore optional encrypted backup support

---
<h2 id="türkçe">Türkçe</h2>

<p align="center">
  <strong>Alışkanlıklar inşa et. İvmeyi koru. Gelişimini gör.</strong>
</p>

<p align="center">
  Flutter ile geliştirilmiş, modern, özelleştirilebilir ve yerel veritabanı odaklı bir alışkanlık takip uygulaması.
</p>

<p align="center">
  <img
    src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"
    alt="Flutter"
  >
  <img
    src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"
    alt="Dart"
  >
  <a href="https://github.com/kagankurubas/habitto/actions/workflows/flutter-ci.yml">
    <img
      src="https://img.shields.io/github/actions/workflow/status/kagankurubas/habitto/flutter-ci.yml?branch=main&style=for-the-badge&label=CI"
      alt="Flutter CI"
    >
  </a>
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <img
      src="https://img.shields.io/github/v/release/kagankurubas/habitto?style=for-the-badge&label=Release"
      alt="Latest Release"
    >
  </a>
</p>

<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <img
      src="https://img.shields.io/badge/Indir-Android_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white"
      alt="Habitto Android için İndir"
    >
  </a>
</p>

---

### v1.1.0 ile Gelen Yenilikler 🚀
- **Çoklu Dil Desteği**: Habitto artık hem İngilizce hem de Türkçe konuşuyor!
- **Gelişmiş Rozet Sistemi**: Yeni başarımlar eklendi ve başarılar kilitlendiğinde açılan harika animasyonlu ekranlar tasarlandı.
- **Güvenilir Bildirimler**: Dünyanın neresinde olursanız olun hatırlatıcıların tam zamanında çalışması için saat dilimine duyarlı bildirim altyapısı kuruldu.
- **Geliştirilmiş Arayüz (UI/UX)**: Daha akıllı öngörü kartları (insight cards) ve temiz istatistik görünümleri.

---

### Hakkında

**Habitto**, istikrarı görünür, motive edici ve ödüllendirici hale getirmek için tasarlanmış, özelleştirilebilir bir alışkanlık ve rutin takip uygulamasıdır.

Kullanıcılar yeni rutinler oluşturabilir, bunları kategorilere ayırabilir, hatırlatıcılar alabilir, serilerini (streak) takip edebilir, detaylı istatistikleri inceleyebilir, başarımlar (rozetler) kazanabilir ve tüm verilerini bir hesap oluşturmadan veya uzak sunucuya bağlı kalmadan yedekleyebilir.

Habitto verilerini yerel olarak Hive kullanarak saklar; hızlı, çevrimdışı öncelikli (offline-first) ve gizlilik odaklı bir deneyim sunar.

### Demo

<p align="center">
  <img
    src="assets/readme/trImages/demo.gif"
    alt="Habitto uygulama demosu"
    width="320"
  >
</p>

### İndirme Bağlantısı

Habitto'nun en güncel Android sürümü GitHub Releases üzerinden edinilebilir.

<p align="center">
  <a href="https://github.com/kagankurubas/habitto/releases/latest">
    <strong>Android için son Habitto sürümünü indir</strong>
  </a>
</p>

#### Android Kurulumu

1. En güncel yayın (release) sayfasına gidin.
2. **Assets** bölümünden Habitto APK dosyasını indirin.
3. İndirilen APK'yı Android cihazınızda açın.
4. Android izin isterse tarayıcınızdan veya dosya yöneticisinden kuruluma izin verin.
5. Habitto'yu yükleyin ve açın.
6. Alışkanlık hatırlatıcılarını alabilmek için bildirim izni verin.

> Habitto şu anda doğrudan GitHub üzerinden dağıtılmaktadır ve henüz Google Play'de bulunmamaktadır.

### Uygulama Önizlemesi

#### Kişiselleştirilmiş Ana Sayfa Deneyimi

<p align="center">
  Habitto, temiz, odaklı ve tutarlı bir alışkanlık takip deneyimi sunarken birden fazla görsel tema seçeneği de barındırır.
</p>

<table align="center">
  <tr>
    <td align="center">
      <img
        src="assets/readme/trImages/home1.jpg"
        alt="Habitto ana ekran tema 1"
        width="220"
      >
      <br>
      <strong>Tema Önizleme I</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/trImages/home2.jpg"
        alt="Habitto ana ekran tema 2"
        width="220"
      >
      <br>
      <strong>Tema Önizleme II</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/trImages/home3.jpg"
        alt="Habitto ana ekran tema 3"
        width="220"
      >
      <br>
      <strong>Tema Önizleme III</strong>
    </td>
  </tr>
</table>

#### Alışkanlık Yönetimi ve İlerleme

<table align="center">
  <tr>
    <td align="center">
      <img
        src="assets/readme/trImages/create_habit.jpg"
        alt="Habitto alışkanlık oluşturma"
        width="220"
      >
      <br>
      <strong>Alışkanlık Oluştur</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/trImages/statistics.jpg"
        alt="Habitto istatistikler"
        width="220"
      >
      <br>
      <strong>Gelişimi Takip Et</strong>
    </td>
    <td align="center">
      <img
        src="assets/readme/trImages/achievements.jpg"
        alt="Habitto başarımlar"
        width="220"
      >
      <br>
      <strong>Başarımların Kilidini Aç</strong>
    </td>
  </tr>
</table>

#### Tema Özelleştirme

<p align="center">
  <img
    src="assets/readme/trImages/themes.jpg"
    alt="Habitto tema özelleştirme ekranı"
    width="240"
  >
</p>

<p align="center">
  Alışkanlıkları anlaşılır ve yönetilebilir tutarken, uygulamayı kişiselleştirmek için birden fazla görsel tema ve görünüm seçeneği arasından seçim yapın.
</p>

### Özellikler

#### Alışkanlık Yönetimi

- Alışkanlık oluşturma, düzenleme, tamamlama ve silme
- Özel renkler ve ikonlar atama
- Özelleştirilebilir kategorilerle alışkanlıkları düzenleme
- Ana ekranı kategorilere göre filtreleme
- Alışkanlık listesinden son tamamlanma geçmişini anında görebilme
- Günlük hedefleri ve tamamlanan rutinleri takip etme

#### Esnek Zamanlama

Habitto farklı rutin sıklıklarını destekler:

- Her gün
- Hafta içi
- Hafta sonu
- Her `X` günde bir
- Haftanın seçili günleri

#### Gelişim Takibi

- Mevcut alışkanlık serileri (streak)
- Toplam tamamlanma sayısı
- 30 günlük tamamlanma oranı
- Takvim tabanlı tamamlanma geçmişi
- GitHub tarzı aktivite ısı haritası
- Günlük hedef ve tamamlanma göstergeleri

#### İstatistikler ve Öngörüler

- Genel performans metrikleri
- Haftalık performans grafiği
- Kategori dağılımı
- En iyi ve en zayıf gün analizleri
- Paylaşılabilir ilerleme kartları
- Başarım ve rozet sistemi

#### Hatırlatıcılar

- Yapılandırılabilir yerel bildirimler
- Her alışkanlık için özel hatırlatıcı saatleri
- Motive edici bildirim mesajları
- Bildirime tıklandığında doğrudan ilgili alışkanlığa gitme
- Uygulama açıkken, arka plandayken veya kapalıyken bildirim alma

#### Kişiselleştirme

- Birden çok uygulama teması
- Alışkanlığa özel renkler
- Özel kategori renkleri ve ikonları
- İsteğe bağlı tamamlama sesi
- İsteğe bağlı titreşim geribildirimi
- **Çift Dil Arayüzü** (İngilizce ve Türkçe)

#### Yedekleme ve Geri Yükleme

- Alışkanlık ve kategori verilerini JSON olarak dışa aktarma
- Önceki bir JSON yedeğinden verileri geri yükleme
- Çapraz platform dosya yönetimi
- Hesap veya bulut servisi gerektirmez

### Teknoloji Yığını

| Teknoloji | Kullanım Amacı |
| --- | --- |
| Flutter | Çapraz platform kullanıcı arayüzü geliştirme |
| Dart | Uygulama dili |
| Hive | Hızlı yerel veri depolama |
| Table Calendar | Takvim tabanlı alışkanlık geçmişi |
| Flutter Heatmap Calendar | Aktivite ısı haritası |
| FL Chart | İstatistikler ve performans grafikleri |
| Flutter Local Notifications | Zamanlanmış alışkanlık hatırlatıcıları |
| Timezone | Saat dilimine duyarlı bildirim planlama |
| Share Plus | Yedekleme ve istatistik paylaşımı |
| File Picker | JSON yedek dosya seçimi |
| AudioPlayers | Tamamlama ses efektleri |
| Path Provider | Platforma özel depolama yolları |
| Easy Localization | Çoklu dil çeviri desteği |
| GitHub Actions | Otomatik analiz, test ve derleme onayı |

### Yol Haritası

- [x] Uygulama ekran görüntülerini ekle
- [x] Uygulama demo GIF'ini ekle
- [x] Temel birim (unit) testlerini ekle
- [ ] Birim ve bileşen (widget) test kapsamını genişlet
- [x] Analiz, testler ve yapı onayı için GitHub Actions ekle
- [x] İndirilebilir Android sürümleri yayınla
- [x] Ek dil desteği ekle (v1.1.0 ile Türkçe eklendi)
- [ ] Erişilebilirlik (accessibility) desteğini geliştir
- [ ] İsteğe bağlı şifrelenmiş yedekleme desteğini araştır

---

## License / Lisans

This project is licensed under the [MIT License](LICENSE).

## Author / Geliştirici

Developed by **Nuri Kağan Kurubaş**.

<p>
  <a href="https://github.com/kagankurubas">
    <img
      src="https://img.shields.io/badge/GitHub-kagankurubas-181717?style=for-the-badge&logo=github"
      alt="GitHub Profile"
    >
  </a>
  <a href="https://kagankurubas.github.io">
    <img
      src="https://img.shields.io/badge/Portfolio-Visit-6C63FF?style=for-the-badge"
      alt="Portfolio Website"
    >
  </a>
</p>

---

<p align="center">
  Built with Flutter and a focus on consistency, privacy, and measurable progress. <br>
  <i>Tutarlılık, gizlilik ve ölçülebilir ilerleme odaklı Flutter ile geliştirildi.</i>
</p>
