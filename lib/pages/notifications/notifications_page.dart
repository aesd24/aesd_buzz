import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/models/notification_model.dart';
import 'package:aesd/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _notificationService = NotificationService();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _notificationService.getNotifications();
      final notificationsList = (response['notifications'] as List?)
          ?.map((n) => NotificationModel.fromJson(n))
          .toList() ?? [];
      
      setState(() {
        _notifications = notificationsList;
        _unreadCount = response['unread_count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    final success = await _notificationService.markAsRead(notification.id);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            readAt: DateTime.now(),
            createdAt: notification.createdAt,
          );
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success) {
      setState(() {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          readAt: n.readAt ?? DateTime.now(),
          createdAt: n.createdAt,
        )).toList();
        _unreadCount = 0;
      });
    }
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'post':
        icon = FontAwesomeIcons.newspaper;
        color = Colors.blue;
        break;
      case 'membership_request':
        icon = FontAwesomeIcons.userPlus;
        color = Colors.orange;
        break;
      case 'donation':
        icon = FontAwesomeIcons.handHoldingHeart;
        color = Colors.green;
        break;
      case 'event':
        icon = FontAwesomeIcons.calendarDays;
        color = Colors.purple;
        break;
      default:
        icon = FontAwesomeIcons.bell;
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: FaIcon(icon, color: color, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: FaIcon(FontAwesomeIcons.checkDouble, size: 16),
              label: Text('Tout marquer lu'),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: notFoundTile(
                    text: 'Aucune notification',
                    icon: FontAwesomeIcons.bell,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? notifire.getContainer
            : appMainColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: notification.isRead
              ? notifire.getMaingey.withOpacity(0.2)
              : appMainColor.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: () => _markAsRead(notification),
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              timeago.format(notification.createdAt, locale: 'fr'),
              style: TextStyle(
                fontSize: 11,
                color: notifire.getMaingey,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: appMainColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
