import 'package:aesd/appstaticdata/routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NotificationModel {
  late int id;
  late String title;
  late String content;
  late DateTime date;
  late bool readed;
  late String type;
  late int? servantId;  // ID du serviteur qui a déclenché la notification
  late int? postId;     // ID du post si applicable

  NotificationModel.fromJson(json) {
    id = json['id'];
    title = json['title'] ?? 'Notification';
    content = json['content'] ?? '';
    // Parse date correctly
    var dateData = json['date'] ?? json['created_at'];
    if (dateData != null) {
      date = dateData is String 
          ? DateTime.parse(dateData) 
          : (dateData is DateTime ? dateData : DateTime.now());
    } else {
      date = DateTime.now();
    }
    
    // Handle read/unread status safely
    if (json['readed'] != null) {
      readed = json['readed'] == 1 || json['readed'] == true;
    } else if (json['read_at'] != null) {
      readed = true; // Laravel convention
    } else {
      readed = false;
    }

    type = json['notificationType'] ?? json['type'] ?? 'general';
    servantId = json['servant_id'];
    postId = json['post_id'];
  }

  // Get icon based on notification type
  IconData _getIconForType() {
    switch (type) {
      case 'post':
        return FontAwesomeIcons.paperclip;
      case 'event':
        return FontAwesomeIcons.solidCalendar;
      case 'ceremony':
        return FontAwesomeIcons.solidBuilding;
      case 'quiz':
        return FontAwesomeIcons.solidCircleQuestion;
      case 'forum':
        return FontAwesomeIcons.solidComments;
      case 'membership':
      case 'membership_request':
        return FontAwesomeIcons.userPlus;
      default:
        return FontAwesomeIcons.solidBell;
    }
  }

  // Get color based on notification type
  Color _getColorForType() {
    switch (type) {
      case 'post':
        return Colors.blue.shade400;
      case 'event':
        return Colors.purple.shade400;
      case 'ceremony':
        return Colors.amber.shade400;
      case 'quiz':
        return Colors.indigo.shade400;
      case 'forum':
        return Colors.teal.shade400;
      case 'membership':
      case 'membership_request':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  // Modern card widget for notification list
  Widget buildModernCard(BuildContext context, {VoidCallback? onTap}) {
    final color = _getColorForType();
    return GestureDetector(
      onTap: onTap ?? () => navigateToDetail(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: !readed 
              ? Border.all(color: color, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(readed ? 0.05 : 0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FaIcon(
                  _getIconForType(),
                  color: color,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!readed)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format date in French
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    } else if (difference.inMinutes < 60) {
      return "Il y a ${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      return "Il y a ${difference.inHours}h";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays}j";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }

  // Legacy tile widget (kept for backward compatibility)
  getTile(context) => Card(
        elevation: 0,
        color: readed ? Colors.grey.shade100 : Colors.green.shade200,
        shape: !readed
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade700, width: 2))
            : null,
        child: ListTile(
          onTap: () => navigateToDetail(context),
          leading: CircleAvatar(
              backgroundColor: readed ? Colors.grey.shade400 : Colors.white,
              child: const FaIcon(FontAwesomeIcons.solidBell)),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text("${date.day}/${date.month}/${date.year}"),
        ),
      );

  // Navigate to detail page based on notification type
  void navigateToDetail(BuildContext context) {
    switch (type) {
      case 'post':
        Get.toNamed(Routes.postDetail, arguments: {'postId': postId ?? id});
        break;
      case 'event':
        Get.toNamed(Routes.eventDetail, arguments: {'eventId': postId ?? id});
        break;
      case 'ceremony':
        Get.toNamed(Routes.ceremonyDetail, arguments: {'ceremonyId': postId ?? id});
        break;
      case 'quiz':
        Get.toNamed(Routes.postDetail, arguments: {'postId': postId ?? id});
        break;
      case 'forum':
        Get.toNamed(Routes.subject, arguments: {'subjectId': postId ?? id});
        break;
      case 'membership':
      case 'membership_request':
        // Rediriger vers la liste des demandes
        Get.toNamed(Routes.membershipRequests);
        break;
      default:
        Get.snackbar('Notification', content);
        break;
    }
  }
}
