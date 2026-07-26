# 🎯 Habit Tracker (Alışkanlık Takip Uygulaması)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FF6F00?style=for-the-badge&logo=hive&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

Kullanıcıların günlük alışkanlıklarını ve rutinlerini düzenlemelerine, takip etmelerine ve istatistikler ile motivasyonlarını korumalarına yardımcı olan, **Offline-First** mimariye sahip modern bir Flutter mobil uygulaması.

---

## ✨ Öne Çıkan Özellikler

- 📝 **Alışkanlık Yönetimi (CRUD):** Kolayca yeni alışkanlıklar ekleyin, hedef günleri/sıklıkları belirleyin, renk ve ikonlarla kişiselleştirin.
- ⚡ **Offline-First (Hive Veritabanı):** Tüm veriler cihazınızda yerel olarak güvenle saklanır. İnternet bağlantısına ihtiyaç duymadan anında yüklenir.
- 🔔 **Hassas Yerel Bildirimler (Exact Alarms):** `timezone` ve `flutter_local_notifications` entegrasyonu sayesinde uygulama **tamamen kapalı** veya **ekran kilitli** olsa bile bildirimleriniz zamanında düşer.
- 📊 **İstatistikler & Seri Takibi:** Alışkanlık tamamlama oranlarınızı ve devam eden serilerinizi (streak) görün.
- 🎨 **Modern & Akıcı Arayüz:** Material 3 standartlarına uygun, göz yormayan, dinamik renkli kart yapısı.

---

## 🛠️ Kullanılan Teknolojiler & Paketler

| Paket / Araç | Kullanım Amacı |
| :--- | :--- |
| **[Flutter](https://flutter.dev/)** | Çapraz platform mobil uygulama geliştirme framework'ü |
| **[Hive](https://pub.dev/packages/hive)** | Yüksek performanslı, NoSQL yerel veritabanı |
| **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** | Android & iOS yerel bildirim ve alarm yönetimi |
| **[timezone](https://pub.dev/packages/timezone)** | Yerel saat dilimi hesaplamaları ve zamanlanmış bildirimler |

---

## 📂 Proje Mimarisi

```text
lib/
├── models/          # Hive veri modelleri (Habit vb.)
├── screens/         # Uygulama ekranları (HomeScreen, StatsScreen vb.)
├── services/        # Bildirim ve zamanlama servisleri (NotificationService)
├── widgets/         # Tekrar kullanılabilir UI bileşenleri (HabitTile, Dialogs)
└── main.dart        # Uygulama giriş noktası ve servis başlatıcılar
```

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

### Gereksinimler
- **Flutter SDK:** `>=3.0.0`
- **Dart SDK:** `>=3.0.0`
- **Android Studio** veya **VS Code** (Flutter eklentileriyle)

### Adımlar

1. **Repoyu klonlayın:**
   ```bash
   git clone [https://github.com/kagan-kurubas/habit-tracker.git](https://github.com/kagan-kurubas/habit-tracker.git)
   cd habit-tracker
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

---

## ⚙️ Android İzinleri ve Arka Plan Bildirimleri

Uygulamanın Android 12+ ve 13+ cihazlarda ekran kilitliyken veya arka plandayken zamanlanmış bildirimleri sorunsuz tetikleyebilmesi için aşağıdaki izinler yapılandırılmıştır:

- `SCHEDULE_EXACT_ALARM` & `USE_EXACT_ALARM`: Tam saatli hatırlatıcı alarmları için.
- `POST_NOTIFICATIONS`: Android 13+ bildirim izinleri için.
- `RECEIVE_BOOT_COMPLETED`: Cihaz yeniden başlatıldığında alarmların korunması için.

> **Samsung / Xiaomi Kullanıcıları İçin Not:** Arka plan bildirimlerinin tam vaktinde çalışabilmesi için cihaz ayarlarından uygulamanın **"Alarmlar ve Hatırlatıcılar"** izninin açık olduğundan ve pil modunun **"Kısıtlamasız (Unrestricted)"** olarak ayarlandığından emin olun.

---

## 👤 Geliştirici

**Kağan Kurubaş**  
* Computer Engineer  
* GitHub: [@kagankurubas](https://github.com/kagankurubas)

---

## 📄 Lisans

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
