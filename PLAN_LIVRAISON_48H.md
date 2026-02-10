# 🚀 Plan d'Action 48h - Système de Dons AESD

**Contexte:** Application de dons pour églises et pasteurs  
**Deadline:** 48 heures  
**Fonctionnalités:** Fidèles → Dons → Églises/Pasteurs → Retraits

---

## 📊 COMPARAISON: Widget CinetPay vs API REST

### Option 1: Widget CinetPay (SDK Officiel)

#### ✅ Avantages
- **Rapidité d'implémentation:** 30 minutes au lieu de 3-4 heures
- **UI prête à l'emploi:** Interface de paiement fournie par CinetPay
- **Maintenance:** CinetPay gère les mises à jour
- **Moins de bugs:** Code testé par des milliers d'apps
- **Support:** Documentation et support officiel

#### ❌ Inconvénients
- **Personnalisation limitée:** UI imposée par CinetPay
- **Moins de contrôle:** Vous ne gérez pas le flux complet
- **Dépendance:** Si CinetPay change le SDK, vous devez suivre

#### 🎨 Présentation du Widget

```dart
// Le widget s'affiche comme une page modale
CinetPayCheckout(
  title: 'Don à [Nom Église]',
  configData: {
    'apikey': 'votre_clé',
    'site_id': 12345,
    'notify_url': 'https://votre-backend.com/webhook'
  },
  paymentData: {
    'transaction_id': 'DON_123456',
    'amount': 5000,
    'currency': 'XOF',
    'channels': 'MOBILE_MONEY', // Orange, MTN, Wave
    'description': 'Don à Église Baptiste'
  },
  waitResponse: (response) {
    // Paiement réussi
    if (response['status'] == 'ACCEPTED') {
      // Créditer le compte de l'église
    }
  },
  onError: (error) {
    // Gérer l'erreur
  }
);
```

**Apparence:** Page modale avec logo CinetPay, choix de paiement (Orange Money, MTN, Wave), formulaire de numéro de téléphone.

---

### Option 2: API REST (Votre Approche Actuelle)

#### ✅ Avantages
- **Contrôle total:** Vous gérez tout le flux
- **Personnalisation:** UI 100% à votre image
- **Flexibilité:** Vous pouvez ajouter des étapes custom
- **Indépendance:** Pas de dépendance au SDK

#### ❌ Inconvénients
- **Plus long à implémenter:** 3-4 heures minimum
- **WebView requis:** Vous devez gérer l'affichage de l'URL
- **Plus de code à maintenir:** Vous gérez tout
- **Risque de bugs:** Plus de code = plus de bugs potentiels

---

## 🎯 RECOMMANDATION POUR 48H

### ⚡ Solution RAPIDE (Recommandée pour votre deadline)

**Utilisez le Widget CinetPay pour les DONS** ✅

**Pourquoi ?**
1. ⏱️ **Gain de temps:** 3-4h économisées
2. 🐛 **Moins de risques:** Code testé et stable
3. 🎨 **UI professionnelle:** Interface de paiement propre
4. 📱 **Mobile-first:** Optimisé pour mobile

**Pour les RETRAITS:**
- Gardez votre approche actuelle (backend manuel)
- Les pasteurs font une demande de retrait
- Vous traitez manuellement (acceptable pour MVP)

---

## 📋 PLAN D'ACTION 48H

### Jour 1 (24h) - Backend & Dons

#### Matin (8h)
- [ ] **Backend: Endpoints dons** (4h)
  - `POST /api/donations/init` - Initier un don
  - `POST /api/donations/webhook` - Recevoir notification CinetPay
  - `GET /api/donations/history` - Historique des dons

#### Après-midi (8h)
- [ ] **Frontend: Intégration Widget CinetPay** (2h)
  - Ajouter package `cinetpay: ^1.0.8`
  - Créer page de don avec widget
  - Tester paiement sandbox
  
- [ ] **Backend: Base de données** (2h)
  - Table `donations` (montant, donateur, bénéficiaire, statut)
  - Table `church_wallets` (solde par église/pasteur)
  
- [ ] **Tests & Debug** (4h)
  - Tester flux complet de don
  - Vérifier webhook
  - Tester avec vraies clés CinetPay

### Jour 2 (24h) - Retraits & Finalisation

#### Matin (8h)
- [ ] **Backend: Système de retrait simple** (4h)
  - `POST /api/withdrawals/request` - Demande de retrait
  - `GET /api/withdrawals/pending` - Liste des demandes
  - `POST /api/withdrawals/approve` - Approuver (admin)
  
- [ ] **Frontend: Page de retrait** (2h)
  - Formulaire de demande
  - Affichage du solde
  - Historique des retraits
  
- [ ] **Admin: Panel simple** (2h)
  - Liste des demandes de retrait
  - Bouton "Traiter manuellement"

#### Après-midi (8h)
- [ ] **Tests finaux** (4h)
  - Scénario complet: Don → Crédit → Demande retrait
  - Tests sur plusieurs églises/pasteurs
  - Vérifier tous les montants
  
- [ ] **Déploiement** (2h)
  - Build APK release
  - Upload Google Play (Internal Testing)
  - Tester sur téléphone réel
  
- [ ] **Documentation** (2h)
  - Guide utilisateur
  - Guide admin pour traiter retraits

---

## 💻 CODE RAPIDE - Intégration Widget CinetPay

### 1. Ajouter le package

```yaml
# pubspec.yaml
dependencies:
  cinetpay: ^1.0.8
```

### 2. Page de don avec widget

```dart
// lib/pages/donations/make_donation_page.dart
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';

class MakeDonationPage extends StatelessWidget {
  final String recipientType; // 'church' ou 'pastor'
  final int recipientId;
  final String recipientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Don à $recipientName')),
      body: DonationForm(
        recipientType: recipientType,
        recipientId: recipientId,
        recipientName: recipientName,
      ),
    );
  }
}

class DonationForm extends StatefulWidget {
  final String recipientType;
  final int recipientId;
  final String recipientName;

  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  void _makeDonation() {
    final amount = int.tryParse(_amountController.text);
    
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Montant minimum: 100 XOF')),
      );
      return;
    }

    // Générer ID de transaction unique
    final transactionId = 'DON_${DateTime.now().millisecondsSinceEpoch}';

    // Lancer le widget CinetPay
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CinetPayCheckout(
          title: 'Don à ${widget.recipientName}',
          titleStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          configData: {
            'apikey': 'VOTRE_CLE_API', // À remplacer
            'site_id': 123456, // À remplacer
            'notify_url': 'https://votre-backend.com/api/donations/webhook',
          },
          paymentData: {
            'transaction_id': transactionId,
            'amount': amount,
            'currency': 'XOF',
            'channels': 'MOBILE_MONEY',
            'description': 'Don à ${widget.recipientName}',
            'metadata': {
              'recipient_type': widget.recipientType,
              'recipient_id': widget.recipientId,
              'message': _messageController.text,
            },
          },
          waitResponse: (response) {
            print('Réponse paiement: $response');
            
            if (response['status'] == 'ACCEPTED') {
              // Paiement réussi
              _showSuccessDialog(response);
            } else {
              // Paiement refusé
              _showErrorDialog('Paiement refusé');
            }
          },
          onError: (error) {
            print('Erreur: $error');
            _showErrorDialog(error['description'] ?? 'Erreur de paiement');
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(Map response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Don réussi !'),
        content: Text(
          'Votre don de ${response['amount']} XOF a été envoyé à ${widget.recipientName}.\n\n'
          'Merci pour votre générosité ! 🙏'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer dialog
              Navigator.of(context).pop(); // Retour page précédente
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('❌ Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Montant
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant (XOF)',
              hintText: 'Minimum 100 XOF',
              prefixIcon: Icon(Icons.money),
            ),
          ),
          SizedBox(height: 20),
          
          // Message optionnel
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message (optionnel)',
              hintText: 'Que Dieu vous bénisse...',
              prefixIcon: Icon(Icons.message),
            ),
          ),
          SizedBox(height: 30),
          
          // Bouton de don
          ElevatedButton(
            onPressed: _makeDonation,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.green,
            ),
            child: Text(
              'Faire un don',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. Backend Webhook (Laravel exemple)

```php
// routes/api.php
Route::post('/donations/webhook', [DonationController::class, 'webhook']);

// app/Http/Controllers/DonationController.php
public function webhook(Request $request)
{
    // Vérifier signature CinetPay
    $signature = hash('sha256', 
        $request->cpm_site_id . 
        $request->cpm_trans_id . 
        $request->cpm_amount . 
        $request->cpm_currency . 
        env('CINETPAY_SECRET_KEY')
    );

    if ($signature !== $request->signature) {
        return response()->json(['error' => 'Invalid signature'], 400);
    }

    // Paiement réussi
    if ($request->cpm_result === '00') {
        $metadata = json_decode($request->metadata, true);
        
        DB::transaction(function() use ($request, $metadata) {
            // Enregistrer le don
            Donation::create([
                'transaction_id' => $request->cpm_trans_id,
                'amount' => $request->cpm_amount,
                'recipient_type' => $metadata['recipient_type'],
                'recipient_id' => $metadata['recipient_id'],
                'message' => $metadata['message'] ?? null,
                'status' => 'completed',
            ]);
            
            // Créditer le wallet du bénéficiaire
            if ($metadata['recipient_type'] === 'church') {
                $wallet = ChurchWallet::where('church_id', $metadata['recipient_id'])->first();
            } else {
                $wallet = PastorWallet::where('pastor_id', $metadata['recipient_id'])->first();
            }
            
            $wallet->increment('balance', $request->cpm_amount);
        });
    }

    return response()->json(['status' => 'ok']);
}
```

---

## ⚠️ POINTS CRITIQUES 48H

### À FAIRE ABSOLUMENT
1. ✅ **Tester avec clés sandbox** avant production
2. ✅ **Webhook HTTPS obligatoire** (ngrok pour tests locaux)
3. ✅ **Vérifier signature webhook** (sécurité)
4. ✅ **Logs détaillés** pour debug rapide
5. ✅ **Montant minimum 100 XOF** (limite CinetPay)

### PEUT ATTENDRE (Post-livraison)
- ❌ Retraits automatiques (faire manuellement pour MVP)
- ❌ Notifications push
- ❌ Statistiques avancées
- ❌ Export Excel

---

## 🎯 RÉSUMÉ RECOMMANDATION

**Pour livrer en 48h :**

1. **DONS:** Widget CinetPay ✅
   - Rapide (30 min)
   - Fiable
   - UI professionnelle

2. **RETRAITS:** Manuel ✅
   - Demande via app
   - Traitement admin manuel
   - Améliorer plus tard

3. **FOCUS:** Flux de don fonctionnel
   - Fidèle peut donner
   - Église/Pasteur voit le solde
   - Demande de retrait possible

**Temps estimé:** 16-20h de dev (reste 28h pour tests/debug)

**Vous POUVEZ livrer à temps !** 🚀
