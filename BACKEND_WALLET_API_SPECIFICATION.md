# 📄 Spécifications Backend - Système de Paiement Wallet (CinetPay)

**Document de référence pour l'implémentation backend**  
**Date:** 06 Février 2026  
**Version:** 1.0

---

## 📋 Vue d'ensemble

Ce document spécifie les endpoints backend nécessaires pour intégrer le système de paiement CinetPay dans le wallet de l'application AESD Buzz.

### Technologies
- **Provider de paiement:** CinetPay
- **Méthodes de paiement:** Orange Money, MTN Money, Wave
- **Devise:** XOF (Franc CFA)
- **Framework backend:** Laravel/PHP (recommandé)

---

## 🔐 Configuration CinetPay

### Variables d'Environnement (.env)
```env
CINETPAY_API_KEY=your_api_key_here
CINETPAY_SITE_ID=your_site_id_here
CINETPAY_SECRET_KEY=your_secret_key_here
CINETPAY_NOTIFY_URL=https://your-domain.com/api/wallet/cinetpay/notify
CINETPAY_RETURN_URL=https://your-domain.com/wallet/payment/return
```

### URLs CinetPay
- **Production:** `https://api-checkout.cinetpay.com/v2`
- **Sandbox:** `https://api-checkout.cinetpay.com/v2` (avec clés de test)

---

## 📡 ENDPOINTS À IMPLÉMENTER

### 1️⃣ GET /api/wallet/balance

**Description:** Récupérer le solde du wallet de l'utilisateur connecté

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "balance": 8786,
    "currency": "XOF",
    "user_id": 6,
    "last_updated": "2026-02-06T18:00:00Z"
  }
}
```

**Implémentation:**
```php
// Récupérer le solde depuis la table wallets
$wallet = Wallet::where('user_id', auth()->id())->first();

// Si le wallet n'existe pas, le créer
if (!$wallet) {
    $wallet = Wallet::create([
        'user_id' => auth()->id(),
        'balance' => 0,
        'currency' => 'XOF'
    ]);
}

return response()->json([
    'success' => true,
    'data' => [
        'balance' => $wallet->balance,
        'currency' => $wallet->currency,
        'user_id' => $wallet->user_id,
        'last_updated' => $wallet->updated_at
    ]
]);
```

---

### 2️⃣ POST /api/wallet/deposit/init

**Description:** Initialiser un dépôt via CinetPay

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Requête:**
```json
{
  "amount": 5000,
  "payment_method": "orange_money",
  "return_url": "aesd://wallet/deposit/success",
  "cancel_url": "aesd://wallet/deposit/cancel"
}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "transaction_id": "AESD_DEP_1707241200000",
    "payment_url": "https://checkout.cinetpay.com/payment/xxxxx",
    "payment_token": "xxxxx",
    "amount": 5000,
    "currency": "XOF",
    "status": "pending",
    "expires_at": "2026-02-06T19:00:00Z"
  }
}
```

**Validation:**
- `amount` >= 100 XOF (minimum CinetPay)
- `payment_method` dans ['orange_money', 'mtn_money', 'wave']

**Mapping des méthodes de paiement:**
```php
$channels = [
    'orange_money' => 'ORANGE_MONEY_CI',
    'mtn_money' => 'MTN_MONEY_CI',
    'wave' => 'WAVE_CI'
];
```

**Implémentation:**
```php
// 1. Valider les données
$validated = $request->validate([
    'amount' => 'required|numeric|min:100',
    'payment_method' => 'required|in:orange_money,mtn_money,wave',
    'return_url' => 'nullable|string',
    'cancel_url' => 'nullable|string'
]);

// 2. Générer un ID de transaction unique
$transactionId = 'AESD_DEP_' . time() . '_' . auth()->id();

// 3. Enregistrer la transaction en base
$transaction = WalletTransaction::create([
    'user_id' => auth()->id(),
    'transaction_id' => $transactionId,
    'type' => 'deposit',
    'amount' => $validated['amount'],
    'payment_method' => $validated['payment_method'],
    'status' => 'pending'
]);

// 4. Appeler l'API CinetPay
$cinetpayData = [
    'apikey' => env('CINETPAY_API_KEY'),
    'site_id' => env('CINETPAY_SITE_ID'),
    'transaction_id' => $transactionId,
    'amount' => $validated['amount'],
    'currency' => 'XOF',
    'description' => 'Recharge wallet AESD Buzz',
    'notify_url' => env('CINETPAY_NOTIFY_URL'),
    'return_url' => $validated['return_url'] ?? env('CINETPAY_RETURN_URL'),
    'channels' => $channels[$validated['payment_method']],
    'metadata' => [
        'user_id' => auth()->id(),
        'type' => 'wallet_deposit'
    ]
];

$response = Http::post('https://api-checkout.cinetpay.com/v2/payment', $cinetpayData);

// 5. Retourner l'URL de paiement
return response()->json([
    'success' => true,
    'data' => [
        'transaction_id' => $transactionId,
        'payment_url' => $response->json()['data']['payment_url'],
        'payment_token' => $response->json()['data']['payment_token'],
        'amount' => $validated['amount'],
        'currency' => 'XOF',
        'status' => 'pending',
        'expires_at' => now()->addHour()
    ]
]);
```

---

### 3️⃣ POST /api/wallet/cinetpay/notify

**Description:** Webhook de notification CinetPay (appelé automatiquement par CinetPay)

**⚠️ IMPORTANT:** Ce endpoint doit être accessible publiquement (pas d'authentification)

**Requête (envoyée par CinetPay):**
```json
{
  "cpm_site_id": "your_site_id",
  "cpm_trans_id": "AESD_DEP_1707241200000",
  "cpm_amount": "5000",
  "cpm_currency": "XOF",
  "cpm_payid": "1234567890",
  "payment_method": "ORANGE_MONEY_CI",
  "cel_phone_num": "0777123456",
  "signature": "xxxxx",
  "cpm_result": "00"
}
```

**Réponse:**
```http
HTTP/1.1 200 OK
```

**Implémentation:**
```php
// 1. Vérifier la signature
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

// 2. Vérifier le statut du paiement
if ($request->cpm_result === '00') {
    // Paiement réussi
    
    // 3. Récupérer la transaction
    $transaction = WalletTransaction::where('transaction_id', $request->cpm_trans_id)->first();
    
    if (!$transaction || $transaction->status === 'completed') {
        // Éviter le double traitement
        return response()->json(['status' => 'already_processed'], 200);
    }
    
    DB::transaction(function() use ($transaction, $request) {
        // 4. Mettre à jour la transaction
        $transaction->update([
            'status' => 'completed',
            'payment_id' => $request->cpm_payid,
            'completed_at' => now()
        ]);
        
        // 5. Créditer le wallet
        $wallet = Wallet::where('user_id', $transaction->user_id)->first();
        $oldBalance = $wallet->balance;
        $wallet->increment('balance', $transaction->amount);
        
        // 6. Enregistrer l'historique
        WalletHistory::create([
            'wallet_id' => $wallet->id,
            'type' => 'credit',
            'amount' => $transaction->amount,
            'balance_before' => $oldBalance,
            'balance_after' => $wallet->balance,
            'description' => 'Dépôt via ' . $transaction->payment_method
        ]);
    });
    
    // 7. Envoyer une notification push à l'utilisateur
    // TODO: Implémenter notification push
    
} else {
    // Paiement échoué
    WalletTransaction::where('transaction_id', $request->cpm_trans_id)
        ->update(['status' => 'failed']);
}

return response()->json(['status' => 'ok'], 200);
```

---

### 4️⃣ POST /api/wallet/deposit/verify

**Description:** Vérifier le statut d'un dépôt

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Requête:**
```json
{
  "transaction_id": "AESD_DEP_1707241200000"
}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "transaction_id": "AESD_DEP_1707241200000",
    "status": "completed",
    "amount": 5000,
    "payment_method": "orange_money",
    "payment_date": "2026-02-06T18:30:15Z",
    "new_balance": 13786
  }
}
```

**Implémentation:**
```php
$transaction = WalletTransaction::where('transaction_id', $request->transaction_id)
    ->where('user_id', auth()->id())
    ->first();

if (!$transaction) {
    return response()->json(['error' => 'Transaction not found'], 404);
}

// Si toujours en attente, vérifier auprès de CinetPay
if ($transaction->status === 'pending') {
    $response = Http::post('https://api-checkout.cinetpay.com/v2/payment/check', [
        'apikey' => env('CINETPAY_API_KEY'),
        'site_id' => env('CINETPAY_SITE_ID'),
        'transaction_id' => $request->transaction_id
    ]);
    
    if ($response->json()['code'] === '00') {
        // Mettre à jour si confirmé
        // (Normalement déjà fait par le webhook)
    }
}

$wallet = Wallet::where('user_id', auth()->id())->first();

return response()->json([
    'success' => true,
    'data' => [
        'transaction_id' => $transaction->transaction_id,
        'status' => $transaction->status,
        'amount' => $transaction->amount,
        'payment_method' => $transaction->payment_method,
        'payment_date' => $transaction->completed_at,
        'new_balance' => $wallet->balance
    ]
]);
```

---

### 5️⃣ POST /api/wallet/withdraw/init

**Description:** Initialiser un retrait

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Requête:**
```json
{
  "amount": 3000,
  "payment_method": "orange_money",
  "phone_number": "0777123456"
}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "transaction_id": "AESD_WDR_1707241300000",
    "amount": 3000,
    "fees": 150,
    "total_deducted": 3150,
    "status": "processing",
    "estimated_completion": "2026-02-06T19:00:00Z"
  }
}
```

**Validation:**
- Montant minimum: 500 XOF
- Vérifier le solde suffisant
- Format du numéro de téléphone

**Implémentation:**
```php
// 1. Valider
$validated = $request->validate([
    'amount' => 'required|numeric|min:500',
    'payment_method' => 'required|in:orange_money,mtn_money,wave',
    'phone_number' => 'required|string'
]);

// 2. Calculer les frais (5% avec minimum 100 XOF)
$fees = max(100, $validated['amount'] * 0.05);
$totalDeducted = $validated['amount'] + $fees;

// 3. Vérifier le solde
$wallet = Wallet::where('user_id', auth()->id())->first();
if ($wallet->balance < $totalDeducted) {
    return response()->json(['error' => 'Solde insuffisant'], 400);
}

// 4. Créer la transaction
$transactionId = 'AESD_WDR_' . time() . '_' . auth()->id();

DB::transaction(function() use ($validated, $fees, $totalDeducted, $transactionId, $wallet) {
    // Créer la transaction
    WalletTransaction::create([
        'user_id' => auth()->id(),
        'transaction_id' => $transactionId,
        'type' => 'withdraw',
        'amount' => $validated['amount'],
        'fees' => $fees,
        'payment_method' => $validated['payment_method'],
        'phone_number' => $validated['phone_number'],
        'status' => 'processing'
    ]);
    
    // Débiter immédiatement
    $wallet->decrement('balance', $totalDeducted);
});

// 5. TODO: Initier le transfert via API du provider
// CinetPay ne gère pas les retraits directs
// Options: API Orange Money, MTN MoMo, Wave, ou traitement manuel

return response()->json([
    'success' => true,
    'data' => [
        'transaction_id' => $transactionId,
        'amount' => $validated['amount'],
        'fees' => $fees,
        'total_deducted' => $totalDeducted,
        'status' => 'processing',
        'estimated_completion' => now()->addHours(2)
    ]
]);
```

---

### 6️⃣ POST /api/wallet/send

**Description:** Envoyer de l'argent à un autre utilisateur

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

**Requête:**
```json
{
  "recipient_id": 12,
  "amount": 1000,
  "message": "Merci pour ton aide"
}
```

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "transaction_id": "AESD_SEND_1707241400000",
    "sender_id": 6,
    "recipient_id": 12,
    "amount": 1000,
    "sender_new_balance": 12786,
    "status": "completed",
    "created_at": "2026-02-06T18:45:00Z"
  }
}
```

**Validation:**
- Vérifier que le destinataire existe
- sender_id ≠ recipient_id
- Montant minimum: 100 XOF
- Solde suffisant

**Implémentation:**
```php
// 1. Valider
$validated = $request->validate([
    'recipient_id' => 'required|exists:users,id',
    'amount' => 'required|numeric|min:100',
    'message' => 'nullable|string|max:255'
]);

// 2. Vérifier que ce n'est pas le même utilisateur
if ($validated['recipient_id'] == auth()->id()) {
    return response()->json(['error' => 'Cannot send to yourself'], 400);
}

// 3. Vérifier le solde
$senderWallet = Wallet::where('user_id', auth()->id())->first();
if ($senderWallet->balance < $validated['amount']) {
    return response()->json(['error' => 'Solde insuffisant'], 400);
}

// 4. Transaction SQL
$transactionId = 'AESD_SEND_' . time() . '_' . auth()->id();

DB::transaction(function() use ($validated, $transactionId, $senderWallet) {
    // Débiter l'expéditeur
    $senderWallet->decrement('balance', $validated['amount']);
    
    // Créditer le destinataire
    $recipientWallet = Wallet::firstOrCreate(
        ['user_id' => $validated['recipient_id']],
        ['balance' => 0, 'currency' => 'XOF']
    );
    $recipientWallet->increment('balance', $validated['amount']);
    
    // Créer la transaction
    WalletTransaction::create([
        'sender_id' => auth()->id(),
        'recipient_id' => $validated['recipient_id'],
        'transaction_id' => $transactionId,
        'type' => 'transfer',
        'amount' => $validated['amount'],
        'message' => $validated['message'] ?? null,
        'status' => 'completed'
    ]);
});

// 5. Notifications push
// TODO: Notifier les deux utilisateurs

return response()->json([
    'success' => true,
    'data' => [
        'transaction_id' => $transactionId,
        'sender_id' => auth()->id(),
        'recipient_id' => $validated['recipient_id'],
        'amount' => $validated['amount'],
        'sender_new_balance' => $senderWallet->balance,
        'status' => 'completed',
        'created_at' => now()
    ]
]);
```

---

### 7️⃣ GET /api/wallet/transactions

**Description:** Récupérer l'historique des transactions

**Headers:**
```http
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optionnel): Numéro de page (défaut: 1)
- `per_page` (optionnel): Éléments par page (défaut: 20, max: 100)
- `type` (optionnel): Filtrer par type (deposit, withdraw, transfer)
- `status` (optionnel): Filtrer par statut (pending, completed, failed)

**Réponse Succès (200):**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": 123,
        "transaction_id": "AESD_DEP_1707241200000",
        "type": "deposit",
        "amount": 5000,
        "fees": 0,
        "status": "completed",
        "payment_method": "orange_money",
        "description": "Recharge wallet",
        "created_at": "2026-02-06T18:30:00Z",
        "completed_at": "2026-02-06T18:30:15Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 45,
      "last_page": 3
    }
  }
}
```

**Implémentation:**
```php
$query = WalletTransaction::where(function($q) {
    $q->where('user_id', auth()->id())
      ->orWhere('sender_id', auth()->id())
      ->orWhere('recipient_id', auth()->id());
});

// Filtres
if ($request->has('type')) {
    $query->where('type', $request->type);
}
if ($request->has('status')) {
    $query->where('status', $request->status);
}

// Pagination
$perPage = min($request->per_page ?? 20, 100);
$transactions = $query->orderBy('created_at', 'desc')
    ->paginate($perPage);

return response()->json([
    'success' => true,
    'data' => [
        'transactions' => $transactions->items(),
        'pagination' => [
            'current_page' => $transactions->currentPage(),
            'per_page' => $transactions->perPage(),
            'total' => $transactions->total(),
            'last_page' => $transactions->lastPage()
        ]
    ]
]);
```

---

## 🗄️ STRUCTURE DE BASE DE DONNÉES

### Table: wallets
```sql
CREATE TABLE wallets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  balance DECIMAL(15, 2) DEFAULT 0.00,
  currency VARCHAR(3) DEFAULT 'XOF',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

### Table: wallet_transactions
```sql
CREATE TABLE wallet_transactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  transaction_id VARCHAR(100) NOT NULL UNIQUE,
  user_id BIGINT UNSIGNED NULL,
  sender_id BIGINT UNSIGNED NULL,
  recipient_id BIGINT UNSIGNED NULL,
  type ENUM('deposit', 'withdraw', 'transfer') NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  fees DECIMAL(15, 2) DEFAULT 0.00,
  payment_method VARCHAR(50) NULL,
  payment_id VARCHAR(100) NULL,
  phone_number VARCHAR(20) NULL,
  status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
  message TEXT NULL,
  metadata JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_transaction_id (transaction_id),
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_type (type),
  INDEX idx_created_at (created_at)
);
```

### Table: wallet_history (optionnel)
```sql
CREATE TABLE wallet_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  wallet_id BIGINT UNSIGNED NOT NULL,
  type ENUM('credit', 'debit') NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  balance_before DECIMAL(15, 2) NOT NULL,
  balance_after DECIMAL(15, 2) NOT NULL,
  description TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
  INDEX idx_wallet_id (wallet_id)
);
```

---

## 🔒 SÉCURITÉ

### 1. Validation des Webhooks
```php
// Vérifier la signature CinetPay
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
```php
// Éviter le double traitement
if ($transaction->status === 'completed') {
    return response()->json(['status' => 'already_processed'], 200);
}
```

### 3. Transactions SQL
```php
// Utiliser des transactions pour garantir la cohérence
DB::transaction(function() {
    // Opérations critiques
});
```

### 4. Rate Limiting
```php
// Dans routes/api.php
Route::middleware(['auth:sanctum', 'throttle:10,1'])->group(function() {
    Route::post('/wallet/deposit/init', [WalletController::class, 'initDeposit']);
});
```

**Limites recommandées:**
- `POST /api/wallet/deposit/init`: 10 requêtes/minute
- `POST /api/wallet/withdraw/init`: 5 requêtes/minute
- `POST /api/wallet/send`: 20 requêtes/minute
- `GET /api/wallet/balance`: 60 requêtes/minute

---

## 📊 CODES D'ERREUR

| Code | Message | Description |
|------|---------|-------------|
| 400 | INVALID_AMOUNT | Montant invalide ou insuffisant |
| 400 | INVALID_PAYMENT_METHOD | Méthode de paiement non supportée |
| 400 | INSUFFICIENT_BALANCE | Solde insuffisant |
| 404 | TRANSACTION_NOT_FOUND | Transaction introuvable |
| 404 | RECIPIENT_NOT_FOUND | Destinataire introuvable |
| 409 | DUPLICATE_TRANSACTION | Transaction déjà traitée |
| 429 | RATE_LIMIT_EXCEEDED | Trop de requêtes |
| 500 | PAYMENT_PROVIDER_ERROR | Erreur du provider de paiement |
| 500 | DATABASE_ERROR | Erreur base de données |

---

## 🧪 TESTS

### Clés de Test CinetPay
```env
CINETPAY_API_KEY=test_api_key
CINETPAY_SITE_ID=test_site_id
CINETPAY_SECRET_KEY=test_secret_key
```

### Numéros de Test
- **Orange Money:** `0777000000` (succès), `0777000001` (échec)
- **MTN Money:** `0656000000` (succès), `0656000001` (échec)
- **Wave:** `0707000000` (succès), `0707000001` (échec)

### Tester le Webhook Localement
```bash
# Utiliser ngrok pour exposer votre serveur local
ngrok http 8000

# Configurer l'URL webhook dans le dashboard CinetPay
https://xxxx.ngrok.io/api/wallet/cinetpay/notify
```

---

## 📝 NOTES D'IMPLÉMENTATION

### ⚠️ Retraits
CinetPay ne gère pas les retraits automatiques. Options:
1. **Traitement manuel** par l'admin
2. **API directe des providers:**
   - Orange Money API
   - MTN Mobile Money API
   - Wave API
3. **Service tiers:**
   - Flutterwave Transfer API
   - Paystack Transfer API

### 📌 Webhooks
- Configurer l'URL de notification dans le dashboard CinetPay
- L'URL doit être accessible publiquement (HTTPS recommandé)
- Tester avec ngrok en développement

### 📊 Logs
Enregistrer tous les appels API CinetPay pour débogage:
```php
Log::info('CinetPay API Call', [
    'endpoint' => $endpoint,
    'request' => $requestData,
    'response' => $response->json()
]);
```

### 🔔 Monitoring
Mettre en place des alertes pour:
- Transactions échouées
- Soldes négatifs (ne devrait jamais arriver)
- Webhooks non traités
- Erreurs API CinetPay

---

## ✅ CHECKLIST D'IMPLÉMENTATION

### Configuration
- [ ] Ajouter les clés CinetPay dans `.env`
- [ ] Configurer l'URL webhook dans le dashboard CinetPay
- [ ] Tester en mode sandbox

### Base de Données
- [ ] Créer la migration pour `wallets`
- [ ] Créer la migration pour `wallet_transactions`
- [ ] Créer la migration pour `wallet_history` (optionnel)
- [ ] Exécuter les migrations

### Endpoints
- [ ] Implémenter `GET /api/wallet/balance`
- [ ] Implémenter `POST /api/wallet/deposit/init`
- [ ] Implémenter `POST /api/wallet/cinetpay/notify`
- [ ] Implémenter `POST /api/wallet/deposit/verify`
- [ ] Implémenter `POST /api/wallet/withdraw/init`
- [ ] Implémenter `POST /api/wallet/send`
- [ ] Implémenter `GET /api/wallet/transactions`

### Sécurité
- [ ] Validation des signatures webhook
- [ ] Rate limiting sur tous les endpoints
- [ ] Transactions SQL pour opérations critiques
- [ ] Logs détaillés

### Tests
- [ ] Tester dépôt avec clés sandbox
- [ ] Tester webhook localement (ngrok)
- [ ] Tester retrait (manuel ou API)
- [ ] Tester envoi entre utilisateurs
- [ ] Tester tous les cas d'erreur

---

**Document généré le:** 06 Février 2026  
**Contact:** Équipe de développement AESD Buzz
