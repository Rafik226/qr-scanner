# QR Code Scanner App

Une application mobile moderne et intuitive pour scanner et gérer les codes QR, développée avec Flutter.

## 📱 Fonctionnalités

- **Interface élégante** avec animations fluides et design Material You
- **Scan précis et rapide** de tous types de codes QR
- **Détection automatique** du type de contenu (URL, email, texte, contact, etc.)
- **Ouverture directe des liens** dans le navigateur
- **Mode sombre/clair** adaptatif
- **Contrôle de flash** et changement de caméra
- **Visualisation détaillée** du contenu scanné
- **Partage facile** du contenu scanné

## 🛠️ Technologies utilisées

- **Flutter** - Framework UI multiplateforme
- **Dart** - Langage de programmation
- **Provider** - Gestion d'état
- **Mobile Scanner** - API de scan de codes QR
- **URL Launcher** - Ouverture des URLs externes

## 📸 Captures d'écran

*[Des captures d'écran de l'application seraient affichées ici]*

## 🚀 Installation

1. Clonez ce dépôt
   ```bash
   git clone https://github.com/Rafik226/qr-code-scanner.git
   ```

2. Installez les dépendances
   ```bash
   flutter pub get
   ```

3. Exécutez l'application
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Android

Assurez-vous que votre fichier `AndroidManifest.xml` contient les permissions nécessaires:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="http" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https" />
    </intent>
</queries>

<uses-permission android:name="android.permission.CAMERA" />
```

### iOS

Assurez-vous que votre fichier `Info.plist` contient:

```xml
<key>NSCameraUsageDescription</key>
<string>Cette application nécessite l'accès à la caméra pour scanner les codes QR.</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>http</string>
  <string>https</string>
</array>
```

## 📝 À propos du projet

Ce projet a été développé dans le cadre de ma Licence 3 en Informatique pour mettre en pratique mes connaissances en développement mobile. Il implémente une architecture propre et évolutive avec séparation des préoccupations.

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📧 Contact

Rafik - [Rafik226](https://github.com/Rafik226)