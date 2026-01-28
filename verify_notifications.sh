#!/bin/bash
# 📋 VÉRIFICATION NOTIFICATION SYSTEM
# Exécute des vérifications sur le système de notifications

echo "🔍 Vérification du Système de Notifications AESD"
echo "=================================================="
echo ""

# 1. Vérifier la présence de NotificationProvider dans main.dart
echo "✓ Fichier main.dart:"
grep -n "NotificationProvider" lib/main.dart 2>/dev/null | head -5
echo ""

# 2. Vérifier les imports Firebase
echo "✓ Imports Firebase:"
grep -n "firebase_messaging" lib/main.dart 2>/dev/null | head -2
echo ""

# 3. Vérifier les listeners
echo "✓ Listeners Firebase:"
grep -n "onMessage\|onMessageOpenedApp\|getInitialMessage" lib/main.dart 2>/dev/null | head -5
echo ""

# 4. Vérifier le cache anti-doublon
echo "✓ Anti-doublon cache:"
grep -n "_notificationIds" lib/main.dart 2>/dev/null | head -3
echo ""

# 5. Vérifier les champs servantId et postId
echo "✓ Champs NotificationModel:"
grep -n "servantId\|postId" lib/models/notification.dart 2>/dev/null | head -5
echo ""

# 6. Vérifier les routes correctes
echo "✓ Routes (should use Routes.postDetail, not /post-detail):"
grep -n "Routes.postDetail\|Routes.eventDetail" lib/models/notification.dart 2>/dev/null | head -5
echo ""

echo "=================================================="
echo "✅ Vérification terminée!"
