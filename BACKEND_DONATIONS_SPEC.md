# 📋 Spécification Backend - Système de Dons CinetPay

**Pour:** Développeur Backend  
**Projet:** AESD - Système de dons aux églises et pasteurs  
**Technologie:** Laravel (adaptable à tout framework)  
**Deadline:** 6 heures

---

## 🎯 Vue d'Ensemble

Le système permet aux fidèles de faire des dons aux églises et pasteurs via CinetPay (Orange Money, MTN, Wave). Les bénéficiaires peuvent ensuite demander des retraits.

### Flux de Paiement

```
Fidèle → App Mobile → Backend (init) → CinetPay Widget → Paiement
                                                              ↓
Backend ← Webhook CinetPay ← Confirmation paiement
   ↓
Crédit Wallet Église/Pasteur
```

---

## 🗄️ Base de Données

### 1. Table `donations`

Stocke toutes les transactions de don.

```sql
CREATE TABLE donations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    amount INT NOT NULL COMMENT 'Montant en XOF',
    donor_id BIGINT UNSIGNED NOT NULL COMMENT 'ID utilisateur donateur',
    recipient_type ENUM('church', 'pastor') NOT NULL,
    recipient_id BIGINT UNSIGNED NOT NULL COMMENT 'ID église ou pasteur',
    message TEXT NULL COMMENT 'Message optionnel du donateur',
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    payment_method VARCHAR(50) NULL COMMENT 'orange_money, mtn, wave',
    payment_date DATETIME NULL,
    cinetpay_payment_token VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_donor (donor_id),
    INDEX idx_recipient (recipient_type, recipient_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_status (status),
    
    FOREIGN KEY (donor_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 2. Table `church_wallets`

Soldes des églises.

```sql
CREATE TABLE church_wallets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    church_id BIGINT UNSIGNED UNIQUE NOT NULL,
    balance INT DEFAULT 0 COMMENT 'Solde actuel en XOF',
    total_received INT DEFAULT 0 COMMENT 'Total reçu depuis création',
    total_withdrawn INT DEFAULT 0 COMMENT 'Total retiré',
    last_donation_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (church_id) REFERENCES churches(id) ON DELETE CASCADE,
    CHECK (balance >= 0)
);
```

### 3. Table `pastor_wallets`

Soldes des pasteurs/serviteurs.

```sql
CREATE TABLE pastor_wallets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pastor_id BIGINT UNSIGNED UNIQUE NOT NULL,
    balance INT DEFAULT 0 COMMENT 'Solde actuel en XOF',
    total_received INT DEFAULT 0 COMMENT 'Total reçu depuis création',
    total_withdrawn INT DEFAULT 0 COMMENT 'Total retiré',
    last_donation_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (pastor_id) REFERENCES servants(id) ON DELETE CASCADE,
    CHECK (balance >= 0)
);
```

### 4. Table `withdrawal_requests`

Demandes de retrait.

```sql
CREATE TABLE withdrawal_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wallet_type ENUM('church', 'pastor') NOT NULL,
    wallet_id BIGINT UNSIGNED NOT NULL COMMENT 'ID du wallet',
    user_id BIGINT UNSIGNED NOT NULL COMMENT 'Utilisateur qui demande',
    amount INT NOT NULL COMMENT 'Montant demandé en XOF',
    phone_number VARCHAR(20) NOT NULL COMMENT 'Numéro pour recevoir',
    status ENUM('pending', 'approved', 'rejected', 'completed') DEFAULT 'pending',
    admin_notes TEXT NULL,
    admin_id BIGINT UNSIGNED NULL COMMENT 'Admin qui a traité',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    
    INDEX idx_wallet (wallet_type, wallet_id),
    INDEX idx_status (status),
    INDEX idx_user (user_id),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (amount >= 1000)
);
```

---

## 🔌 Endpoints API

### 1. POST `/api/donations/init`

**Description:** Initialiser une transaction de don (appelé avant d'ouvrir le widget CinetPay)

**Auth:** Requis (Bearer Token)

**Body:**
```json
{
  "recipient_id": 123,
  "recipient_type": "church",
  "amount": 5000,
  "message": "Que Dieu vous bénisse"
}
```

**Validation:**
- `recipient_id`: required, integer, exists
- `recipient_type`: required, in:church,pastor
- `amount`: required, integer, min:100
- `message`: nullable, string, max:500

**Réponse Success (201):**
```json
{
  "success": true,
  "transaction_id": "DON_1707531234_456",
  "donation_id": 789
}
```

**Code Laravel:**

```php
public function init(Request $request)
{
    $validated = $request->validate([
        'recipient_id' => 'required|integer',
        'recipient_type' => 'required|in:church,pastor',
        'amount' => 'required|integer|min:100',
        'message' => 'nullable|string|max:500',
    ]);

    // Vérifier que le bénéficiaire existe
    if ($validated['recipient_type'] === 'church') {
        $recipient = Church::findOrFail($validated['recipient_id']);
    } else {
        $recipient = Servant::findOrFail($validated['recipient_id']);
    }

    // Générer un ID de transaction unique
    $transactionId = 'DON_' . time() . '_' . $request->user()->id;

    // Créer l'enregistrement de don (status: pending)
    $donation = Donation::create([
        'transaction_id' => $transactionId,
        'amount' => $validated['amount'],
        'donor_id' => $request->user()->id,
        'recipient_type' => $validated['recipient_type'],
        'recipient_id' => $validated['recipient_id'],
        'message' => $validated['message'],
        'status' => 'pending',
    ]);

    return response()->json([
        'success' => true,
        'transaction_id' => $transactionId,
        'donation_id' => $donation->id,
    ], 201);
}
```

---

### 2. POST `/api/donations/webhook` ⚠️ CRITIQUE

**Description:** Webhook CinetPay pour notification de paiement

**Auth:** Aucune (vérification par signature)

**Body (envoyé par CinetPay):**
```json
{
  "cpm_site_id": "123456",
  "cpm_trans_id": "DON_1707531234_456",
  "cpm_amount": "5000",
  "cpm_currency": "XOF",
  "cpm_result": "00",
  "payment_method": "ORANGE_MONEY",
  "signature": "abc123...",
  "metadata": "{\"recipient_type\":\"church\",\"recipient_id\":\"123\"}"
}
```

**Codes résultat CinetPay:**
- `00` = Paiement réussi ✅
- Autre = Paiement échoué ❌

**Réponse:**
```json
{
  "status": "ok"
}
```

**Code Laravel:**

```php
public function webhook(Request $request)
{
    Log::info('CinetPay Webhook received', $request->all());

    // 1. VÉRIFIER LA SIGNATURE (SÉCURITÉ CRITIQUE)
    $signature = hash('sha256', 
        $request->cpm_site_id . 
        $request->cpm_trans_id . 
        $request->cpm_amount . 
        $request->cpm_currency . 
        env('CINETPAY_SECRET_KEY')
    );

    if ($signature !== $request->signature) {
        Log::error('Invalid CinetPay signature', [
            'expected' => $signature,
            'received' => $request->signature
        ]);
        return response()->json(['error' => 'Invalid signature'], 400);
    }

    // 2. RÉCUPÉRER LE DON
    $donation = Donation::where('transaction_id', $request->cpm_trans_id)->first();

    if (!$donation) {
        Log::error('Donation not found', ['transaction_id' => $request->cpm_trans_id]);
        return response()->json(['error' => 'Donation not found'], 404);
    }

    // 3. ÉVITER LES DOUBLONS (idempotence)
    if ($donation->status === 'completed') {
        Log::info('Donation already processed', ['donation_id' => $donation->id]);
        return response()->json(['status' => 'ok']);
    }

    // 4. TRAITER LE PAIEMENT
    if ($request->cpm_result === '00') {
        // PAIEMENT RÉUSSI
        DB::transaction(function() use ($donation, $request) {
            // Mettre à jour le don
            $donation->update([
                'status' => 'completed',
                'payment_method' => $request->payment_method ?? 'mobile_money',
                'payment_date' => now(),
                'cinetpay_payment_token' => $request->payment_token ?? null,
            ]);

            // Créditer le wallet du bénéficiaire
            if ($donation->recipient_type === 'church') {
                $wallet = ChurchWallet::firstOrCreate(
                    ['church_id' => $donation->recipient_id],
                    ['balance' => 0, 'total_received' => 0, 'total_withdrawn' => 0]
                );
            } else {
                $wallet = PastorWallet::firstOrCreate(
                    ['pastor_id' => $donation->recipient_id],
                    ['balance' => 0, 'total_received' => 0, 'total_withdrawn' => 0]
                );
            }

            $wallet->increment('balance', $donation->amount);
            $wallet->increment('total_received', $donation->amount);
            $wallet->update(['last_donation_at' => now()]);

            Log::info('Donation completed successfully', [
                'donation_id' => $donation->id,
                'amount' => $donation->amount,
                'new_balance' => $wallet->balance,
            ]);

            // TODO: Envoyer notification au bénéficiaire
        });
    } else {
        // PAIEMENT ÉCHOUÉ
        $donation->update(['status' => 'failed']);
        Log::warning('Donation failed', [
            'donation_id' => $donation->id,
            'result_code' => $request->cpm_result
        ]);
    }

    return response()->json(['status' => 'ok']);
}
```

---

### 3. GET `/api/donations/history`

**Description:** Historique des dons effectués par l'utilisateur connecté

**Auth:** Requis

**Query Params:**
- `page` (optional): Numéro de page
- `per_page` (optional): Éléments par page (défaut: 20)

**Réponse:**
```json
{
  "success": true,
  "data": [
    {
      "id": 789,
      "transaction_id": "DON_1707531234_456",
      "amount": 5000,
      "donor_id": 456,
      "recipient_type": "church",
      "recipient_id": 123,
      "recipient_name": "Église Baptiste de Cocody",
      "recipient_photo": "https://...",
      "message": "Que Dieu vous bénisse",
      "status": "completed",
      "created_at": "2026-02-10T03:00:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total": 45,
    "per_page": 20
  }
}
```

**Code Laravel:**

```php
public function myHistory(Request $request)
{
    $perPage = $request->get('per_page', 20);
    
    $donations = Donation::where('donor_id', $request->user()->id)
        ->orderBy('created_at', 'desc')
        ->paginate($perPage);

    $data = $donations->map(function($donation) {
        // Récupérer info bénéficiaire
        if ($donation->recipient_type === 'church') {
            $recipient = Church::find($donation->recipient_id);
        } else {
            $recipient = Servant::with('user')->find($donation->recipient_id);
        }

        return [
            'id' => $donation->id,
            'transaction_id' => $donation->transaction_id,
            'amount' => $donation->amount,
            'donor_id' => $donation->donor_id,
            'recipient_type' => $donation->recipient_type,
            'recipient_id' => $donation->recipient_id,
            'recipient_name' => $donation->recipient_type === 'church' 
                ? ($recipient->name ?? 'Inconnu')
                : ($recipient->user->name ?? 'Inconnu'),
            'recipient_photo' => $donation->recipient_type === 'church'
                ? ($recipient->logo ?? null)
                : ($recipient->user->photo ?? null),
            'message' => $donation->message,
            'status' => $donation->status,
            'created_at' => $donation->created_at->toIso8601String(),
        ];
    });

    return response()->json([
        'success' => true,
        'data' => $data,
        'pagination' => [
            'current_page' => $donations->currentPage(),
            'total' => $donations->total(),
            'per_page' => $donations->perPage(),
        ],
    ]);
}
```

---

### 4. GET `/api/donations/received`

**Description:** Dons reçus par une église ou un pasteur

**Auth:** Requis

**Query Params:**
- `recipient_id`: required
- `recipient_type`: required (church|pastor)

**Réponse:**
```json
{
  "success": true,
  "total_amount": 125000,
  "donations_count": 25,
  "data": [...]
}
```

**Code Laravel:**

```php
public function received(Request $request)
{
    $validated = $request->validate([
        'recipient_id' => 'required|integer',
        'recipient_type' => 'required|in:church,pastor',
    ]);

    // Vérifier que l'utilisateur a accès à ces données
    // TODO: Ajouter vérification permissions

    $donations = Donation::where('recipient_id', $validated['recipient_id'])
        ->where('recipient_type', $validated['recipient_type'])
        ->where('status', 'completed')
        ->orderBy('created_at', 'desc')
        ->get();

    $total = $donations->sum('amount');

    return response()->json([
        'success' => true,
        'total_amount' => $total,
        'donations_count' => $donations->count(),
        'data' => $donations,
    ]);
}
```

---

### 5. GET `/api/wallets/balance`

**Description:** Récupérer le solde d'un wallet

**Auth:** Requis

**Query Params:**
- `recipient_id`: required
- `recipient_type`: required (church|pastor)

**Réponse:**
```json
{
  "success": true,
  "balance": 125000,
  "total_received": 250000,
  "total_withdrawn": 125000,
  "last_donation_at": "2026-02-10T03:00:00Z"
}
```

**Code Laravel:**

```php
public function balance(Request $request)
{
    $validated = $request->validate([
        'recipient_id' => 'required|integer',
        'recipient_type' => 'required|in:church,pastor',
    ]);

    if ($validated['recipient_type'] === 'church') {
        $wallet = ChurchWallet::where('church_id', $validated['recipient_id'])->first();
    } else {
        $wallet = PastorWallet::where('pastor_id', $validated['recipient_id'])->first();
    }

    if (!$wallet) {
        return response()->json([
            'success' => true,
            'balance' => 0,
            'total_received' => 0,
            'total_withdrawn' => 0,
            'last_donation_at' => null,
        ]);
    }

    return response()->json([
        'success' => true,
        'balance' => $wallet->balance,
        'total_received' => $wallet->total_received,
        'total_withdrawn' => $wallet->total_withdrawn,
        'last_donation_at' => $wallet->last_donation_at,
    ]);
}
```

---

### 6. POST `/api/withdrawals/request`

**Description:** Demander un retrait

**Auth:** Requis

**Body:**
```json
{
  "wallet_type": "church",
  "wallet_id": 123,
  "amount": 50000,
  "phone_number": "0707070707"
}
```

**Validation:**
- `amount`: min:1000, max:balance

**Réponse:**
```json
{
  "success": true,
  "request_id": 456,
  "message": "Demande de retrait enregistrée"
}
```

**Code Laravel:**

```php
public function request(Request $request)
{
    $validated = $request->validate([
        'wallet_type' => 'required|in:church,pastor',
        'wallet_id' => 'required|integer',
        'amount' => 'required|integer|min:1000',
        'phone_number' => 'required|string|regex:/^[0-9]{10}$/',
    ]);

    // Récupérer le wallet
    if ($validated['wallet_type'] === 'church') {
        $wallet = ChurchWallet::findOrFail($validated['wallet_id']);
    } else {
        $wallet = PastorWallet::findOrFail($validated['wallet_id']);
    }

    // Vérifier le solde
    if ($validated['amount'] > $wallet->balance) {
        return response()->json([
            'success' => false,
            'error' => 'Solde insuffisant'
        ], 400);
    }

    // Créer la demande
    $withdrawal = WithdrawalRequest::create([
        'wallet_type' => $validated['wallet_type'],
        'wallet_id' => $validated['wallet_id'],
        'user_id' => $request->user()->id,
        'amount' => $validated['amount'],
        'phone_number' => $validated['phone_number'],
        'status' => 'pending',
    ]);

    return response()->json([
        'success' => true,
        'request_id' => $withdrawal->id,
        'message' => 'Demande de retrait enregistrée. Traitement sous 24-48h.',
    ], 201);
}
```

---

### 7. GET `/api/withdrawals/pending`

**Description:** Liste des demandes en attente (admin)

**Auth:** Requis (admin)

**Réponse:**
```json
{
  "success": true,
  "data": [...]
}
```

---

### 8. POST `/api/withdrawals/approve/{id}`

**Description:** Approuver/traiter une demande (admin)

**Auth:** Requis (admin)

**Body:**
```json
{
  "status": "completed",
  "admin_notes": "Virement effectué le 10/02/2026"
}
```

---

## 🔐 Sécurité

### 1. Vérification Signature Webhook

**CRITIQUE:** Toujours vérifier la signature CinetPay

```php
$signature = hash('sha256', 
    $request->cpm_site_id . 
    $request->cpm_trans_id . 
    $request->cpm_amount . 
    $request->cpm_currency . 
    env('CINETPAY_SECRET_KEY')
);

if ($signature !== $request->signature) {
    abort(400, 'Invalid signature');
}
```

### 2. Idempotence

Vérifier si la transaction a déjà été traitée :

```php
if ($donation->status === 'completed') {
    return response()->json(['status' => 'ok']);
}
```

### 3. Transaction Database

Utiliser des transactions pour garantir la cohérence :

```php
DB::transaction(function() use ($donation, $wallet) {
    $donation->update(['status' => 'completed']);
    $wallet->increment('balance', $donation->amount);
});
```

---

## 🧪 Tests

### Test Webhook (Postman/cURL)

```bash
curl -X POST https://your-backend.com/api/donations/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "cpm_site_id": "123456",
    "cpm_trans_id": "DON_1707531234_456",
    "cpm_amount": "5000",
    "cpm_currency": "XOF",
    "cpm_result": "00",
    "payment_method": "ORANGE_MONEY",
    "signature": "CALCULER_SIGNATURE_ICI"
  }'
```

### Calcul Signature Test

```php
$signature = hash('sha256', 
    '123456' .           // site_id
    'DON_1707531234_456' . // trans_id
    '5000' .             // amount
    'XOF' .              // currency
    'YOUR_SECRET_KEY'    // secret key
);
```

---

## 📝 Variables d'Environnement

Ajouter dans `.env` :

```env
CINETPAY_API_KEY=your_api_key
CINETPAY_SITE_ID=123456
CINETPAY_SECRET_KEY=your_secret_key
CINETPAY_NOTIFY_URL=https://your-backend.com/api/donations/webhook
```

---

## 🚀 Routes Laravel

```php
// routes/api.php

// Donations
Route::post('/donations/init', [DonationController::class, 'init'])
    ->middleware('auth:sanctum');
    
Route::post('/donations/webhook', [DonationController::class, 'webhook']);

Route::get('/donations/history', [DonationController::class, 'myHistory'])
    ->middleware('auth:sanctum');
    
Route::get('/donations/received', [DonationController::class, 'received'])
    ->middleware('auth:sanctum');

// Wallets
Route::get('/wallets/balance', [WalletController::class, 'balance'])
    ->middleware('auth:sanctum');

// Withdrawals
Route::post('/withdrawals/request', [WithdrawalController::class, 'request'])
    ->middleware('auth:sanctum');
    
Route::get('/withdrawals/pending', [WithdrawalController::class, 'pending'])
    ->middleware('auth:sanctum');
    
Route::post('/withdrawals/approve/{id}', [WithdrawalController::class, 'approve'])
    ->middleware('auth:sanctum');
```

---

## ✅ Checklist Backend

- [ ] Créer migrations (4 tables)
- [ ] Créer modèles Eloquent
- [ ] Implémenter DonationController
- [ ] Implémenter WalletController
- [ ] Implémenter WithdrawalController
- [ ] Configurer routes API
- [ ] Tester webhook avec ngrok
- [ ] Vérifier logs
- [ ] Déployer en production
- [ ] Configurer URL webhook sur CinetPay dashboard

---

## 🆘 Support

**Documentation CinetPay:**
- https://docs.cinetpay.com/api/1.0-fr/

**Webhook ngrok (dev local):**
```bash
ngrok http 8000
# Utiliser l'URL https://xxx.ngrok.io/api/donations/webhook
```

**Logs à surveiller:**
- Webhook reçus
- Signatures invalides
- Transactions en double
- Erreurs de crédit wallet
