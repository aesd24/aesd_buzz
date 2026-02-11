# 🔑 Guide de Configuration CinetPay

**Objectif:** Récupérer vos clés CinetPay et les configurer dans l'application

---

## 📋 Étape 1: Accéder au Dashboard CinetPay

1. Allez sur **https://dashboard.cinetpay.com**
2. Connectez-vous avec vos identifiants CinetPay
3. Vous arrivez sur le tableau de bord

---

## 🔍 Étape 2: Récupérer le SITE_ID

### Navigation
1. Dans le menu de gauche, cliquez sur **"Paramètres"** ou **"Settings"**
2. Puis cliquez sur **"Sites"**

### Localisation
Vous verrez une liste de vos sites avec :
- **Nom du site** (ex: "Mon Application AESD")
- **Site ID** (ex: `5866` ou `300658`)
- **Statut** (Actif/Inactif)

### Copier le Site ID
```
Site ID: 5866
```
**⚠️ C'est un NOMBRE (pas de guillemets)**

---

## 🔑 Étape 3: Récupérer l'API_KEY

### Navigation
1. Dans le menu de gauche, cliquez sur **"Paramètres"** ou **"Settings"**
2. Puis cliquez sur **"API"**

### Localisation
Vous verrez :
- **API Key Production** (pour les vrais paiements)
- **API Key Sandbox** (pour les tests)

### Copier l'API Key
```
API Key Production: 12912847348723487234
API Key Sandbox: 98765432109876543210
```
**⚠️ C'est une CHAÎNE DE CARACTÈRES (avec guillemets dans le code)**

---

## 🧪 Mode Sandbox vs Production

### Mode Sandbox (Tests)
- **Utilité:** Tester sans argent réel
- **Paiements:** Fictifs (pas de vraie transaction)
- **Clés:** Utilisez les clés SANDBOX

### Mode Production (Réel)
- **Utilité:** Vrais paiements
- **Paiements:** Argent réel débité
- **Clés:** Utilisez les clés PRODUCTION

**Recommandation:** Commencez par SANDBOX pour tester !

---

## 📝 Étape 4: Configurer dans l'Application

### Fichier à Modifier
`lib/pages/donations/make_donation_page.dart`

### Lignes 33-35

**AVANT (valeurs de test):**
```dart
static const String CINETPAY_API_KEY = 'YOUR_API_KEY';
static const int CINETPAY_SITE_ID = 123456;
static const String CINETPAY_NOTIFY_URL = 'https://your-backend.com/api/donations/webhook';
```

**APRÈS (vos vraies clés):**

#### Pour SANDBOX (tests):
```dart
static const String CINETPAY_API_KEY = '98765432109876543210'; // Votre clé SANDBOX
static const int CINETPAY_SITE_ID = 5866; // Votre Site ID
static const String CINETPAY_NOTIFY_URL = 'https://monapi.eglisesetserviteursdedieu.com/api/donations/webhook';
```

#### Pour PRODUCTION (réel):
```dart
static const String CINETPAY_API_KEY = '12912847348723487234'; // Votre clé PRODUCTION
static const int CINETPAY_SITE_ID = 5866; // Votre Site ID
static const String CINETPAY_NOTIFY_URL = 'https://monapi.eglisesetserviteursdedieu.com/api/donations/webhook';
```

---

## ⚙️ Étape 5: Configurer le Webhook

### Dans le Dashboard CinetPay

1. Allez dans **"Paramètres"** → **"Webhook"**
2. Ajoutez l'URL de votre webhook :
   ```
   https://monapi.eglisesetserviteursdedieu.com/api/donations/webhook
   ```
3. Activez le webhook
4. Sauvegardez

### ⚠️ Important
- Le webhook **DOIT** être en **HTTPS** (pas HTTP)
- Le serveur backend doit être **en ligne** et accessible
- L'endpoint `/api/donations/webhook` doit être **implémenté**

---

## 🧪 Étape 6: Tester en Mode Sandbox

### 1. Utilisez les clés SANDBOX
```dart
static const String CINETPAY_API_KEY = 'VOTRE_CLE_SANDBOX';
static const int CINETPAY_SITE_ID = VOTRE_SITE_ID;
```

### 2. Lancez l'application
```bash
flutter run -d emulator-5554
```

### 3. Testez un don
- Montant: 500 XOF (par exemple)
- Le widget CinetPay s'ouvre
- Choisissez un mode de paiement
- **En sandbox:** Utilisez les numéros de test fournis par CinetPay

### 4. Numéros de Test CinetPay (Sandbox)

**Orange Money:**
- Numéro: `0707070707`
- Code OTP: `1234`

**MTN Money:**
- Numéro: `0505050505`
- Code OTP: `1234`

**Wave:**
- Numéro: `0606060606`
- Code OTP: `1234`

---

## ✅ Étape 7: Passer en Production

### Quand ?
- Après avoir testé en sandbox
- Quand le backend est prêt et en ligne
- Quand vous êtes prêt à recevoir de vrais paiements

### Comment ?
1. Remplacez `CINETPAY_API_KEY` par la clé **PRODUCTION**
2. Gardez le même `CINETPAY_SITE_ID`
3. Vérifiez que le webhook est configuré
4. Rebuild l'app en mode release :
   ```bash
   flutter build apk --release
   ```

---

## 🔒 Sécurité

### ⚠️ NE JAMAIS
- Partager vos clés API publiquement
- Commiter vos clés dans Git
- Utiliser les clés PRODUCTION pour tester

### ✅ TOUJOURS
- Utiliser SANDBOX pour les tests
- Garder vos clés secrètes
- Vérifier la signature du webhook côté backend

---

## 🐛 Résolution de Problèmes

### Erreur: "No Service with site_id...found"
**Cause:** Site ID incorrect ou inexistant  
**Solution:** Vérifiez votre Site ID dans le dashboard

### Erreur: "Invalid API Key"
**Cause:** API Key incorrecte  
**Solution:** Vérifiez votre API Key dans le dashboard

### Erreur: "Webhook failed"
**Cause:** Serveur backend hors ligne ou URL incorrecte  
**Solution:** 
- Vérifiez que le serveur est en ligne
- Vérifiez l'URL du webhook
- Testez l'endpoint avec Postman

### Le widget ne s'ouvre pas
**Cause:** Problème de configuration  
**Solution:**
- Vérifiez les logs de l'app
- Vérifiez que le montant >= 100 XOF
- Vérifiez que le backend a retourné un transaction_id

---

## 📞 Support CinetPay

**Email:** support@cinetpay.com  
**Téléphone:** +225 XX XX XX XX XX  
**Documentation:** https://docs.cinetpay.com  
**Dashboard:** https://dashboard.cinetpay.com

---

## ✅ Checklist Finale

Avant de déployer en production :

- [ ] Clés SANDBOX testées et fonctionnelles
- [ ] Backend implémenté et testé
- [ ] Webhook configuré et vérifié
- [ ] Signature webhook vérifiée côté backend
- [ ] Tests de paiement réussis en sandbox
- [ ] Clés PRODUCTION configurées
- [ ] Build release créé
- [ ] Tests finaux en production

---

## 🎯 Résumé Rapide

1. **Dashboard CinetPay** → Paramètres → Sites → Copier **Site ID**
2. **Dashboard CinetPay** → Paramètres → API → Copier **API Key**
3. **Modifier** `make_donation_page.dart` lignes 33-35
4. **Tester** en mode SANDBOX
5. **Passer** en PRODUCTION quand prêt

**Temps estimé:** 10 minutes ⏱️
