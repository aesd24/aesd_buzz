# 📦 Bundle signé pour Google Play Store

Ce guide explique comment générer un **Android App Bundle (AAB)** signé pour publier l’app sur le Play Store.

---

## Prérequis : Java JDK (keytool)

Le script a besoin de **keytool**, fourni par un **JDK (Java)**. Si vous n’avez **pas Android Studio** :

1. Téléchargez un JDK gratuit : **Eclipse Temurin**  
   → https://adoptium.net/temurin/releases/  
2. Choisissez : **Windows x64**, **JDK 17 (LTS)**, installeur **.msi**  
3. À l’installation, cochez **« Set JAVA_HOME variable »** et **« Add to PATH »**  
4. **Fermez puis rouvrez** l’Invite de commandes (ou PowerShell), puis relancez le script

Après ça, `setup_keystore.bat` pourra trouver `keytool` tout seul.

---

## Option A : Script automatique (recommandé)

**Depuis l’Invite de commandes (cmd) :**
```cmd
cd c:\Users\DELL\Documents\GitHub\aesd_buzz\android
setup_keystore.bat
```

**Ou depuis PowerShell :**
```powershell
cd c:\Users\DELL\Documents\GitHub\aesd_buzz\android
.\setup_keystore.ps1
```
(Si besoin : `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` puis relancer.)

Le script vous demandera :
- le **mot de passe du keystore** (choisissez-en un et gardez-le en lieu sûr),
- le **mot de passe de la clé** (Entrée = même que le keystore).

Il crée `upload-keystore.jks` et `key.properties` dans le dossier `android/`. Ensuite, passez à la section **4. Générer le bundle**.

---

## Option B : Créer le keystore à la main (une seule fois)

Si vous n’avez pas encore de keystore de release, créez-le **une seule fois** et conservez-le en lieu sûr. En cas de perte, vous ne pourrez plus mettre à jour l’app sur le Play Store avec la même clé.

### Commande (PowerShell ou CMD)

À la racine du projet (ou dans un dossier de votre choix, hors dépôt) :

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- **upload-keystore.jks** : nom du fichier (vous pouvez changer).
- **upload** : alias de la clé (à reprendre dans `key.properties`).
- **validity 10000** : validité en jours (~27 ans).

`keytool` vous demandera :

- mot de passe du keystore ;
- mot de passe de la clé (souvent le même) ;
- nom, organisation, ville, etc. (pour le certificat).

### Placer le keystore

- Soit dans le dossier **android/** du projet (ex: `android/upload-keystore.jks`).
- Soit à la **racine du projet** (ex: `upload-keystore.jks`).  
Dans ce cas, dans `key.properties` vous utiliserez par exemple `storeFile=../upload-keystore.jks`.

Ne commitez jamais le fichier `.jks` (il est déjà dans `.gitignore`).

---

## 2. Fichier `key.properties`

Le build Android lit les infos de signature dans `android/key.properties`.

### Créer le fichier

1. Copier l’exemple :
   ```bash
   cd android
   copy key.properties.example key.properties
   ```
2. Ouvrir `android/key.properties` et remplacer par **vos** valeurs :

```properties
storePassword=VOTRE_MOT_DE_PASSE_KEYSTORE
keyPassword=VOTRE_MOT_DE_PASSE_CLE
keyAlias=upload
storeFile=../upload-keystore.jks
```

- **storeFile** :
  - Si le `.jks` est dans `android/` : `storeFile=upload-keystore.jks`
  - Si le `.jks` est à la racine du projet : `storeFile=../upload-keystore.jks`
- **keyAlias** : doit être le même que l’alias utilisé dans `keytool` (ex: `upload`).

Ne commitez jamais `key.properties` (déjà dans `.gitignore`).

---

## 3. Vérifier la config de signature

Le fichier `android/app/build.gradle.kts` est déjà configuré pour utiliser `key.properties` en **release** :

- `signingConfigs.release` lit `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.
- Le `buildType` **release** utilise cette config.

Aucune modification n’est nécessaire si `key.properties` et le keystore sont corrects.

---

## 4. Générer le bundle (AAB)

À la **racine du projet** (où se trouve `pubspec.yaml`) :

```bash
flutter clean
flutter pub get
flutter build appbundle
```

En cas d’erreur de signature, vérifiez :

- que `android/key.properties` existe et que les chemins/mots de passe/alias sont corrects ;
- que le fichier `.jks` existe bien au chemin indiqué par `storeFile`.

---

## 5. Récupérer le fichier AAB

Le bundle signé est généré ici :

```
build/app/outputs/bundle/release/app-release.aab
```

Ce fichier **app-release.aab** est celui à envoyer dans la Play Console (Production, ou un track de test).

---

## 6. Version et nom (optionnel)

- **Version** : dans `pubspec.yaml`, champ `version:` (ex: `1.0.0+1` → version 1.0.0, versionCode 1).
- **Nom / icône** : configurés dans le projet Flutter et dans `android/app/`.

---

## Récap des commandes

**Avec le script (Option A) :**
```powershell
cd android
.\setup_keystore.ps1
# puis à la racine du projet :
flutter clean
flutter pub get
flutter build appbundle
```

**Sans le script (Option B) :**
```bash
# 1. Créer le keystore (une fois)
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Créer key.properties (android/key.properties) à partir de key.properties.example

# 3. Build du bundle
flutter clean && flutter pub get && flutter build appbundle

# 4. Fichier à uploader
# build/app/outputs/bundle/release/app-release.aab
```

---

## Sécurité

- Ne commitez **jamais** `key.properties` ni les fichiers `.jks` / `.keystore`.
- Sauvegardez le keystore et les mots de passe dans un endroit sûr (coffre-fort, gestionnaire de mots de passe).
- Pour la Play Console, vous pouvez aussi utiliser le **Play App Signing** : Google garde une clé de signature et vous uploadez une clé d’upload (c’est cette clé d’upload que vous générez avec ce guide).
