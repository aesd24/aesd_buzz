import 'dart:io';
import 'package:aesd/appstaticdata/staticdata.dart';
import 'package:aesd/components/buttons.dart';
import 'package:aesd/components/icon.dart';
import 'package:aesd/components/not_found.dart';
import 'package:aesd/components/placeholders.dart';
import 'package:aesd/components/structure.dart';
import 'package:aesd/provider/notification.dart';
import 'package:aesd/services/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  bool _isLoading = false;

  Future<void> _loadNotifications() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      await Provider.of<NotificationProvider>(context, listen: false).refresh();
    } on HttpException catch (e) {
      // Ne pas afficher d'erreur si l'endpoint n'existe pas encore (404)
      if (e.message.contains('404') || e.message.contains('Not Found')) {
        print('Endpoint notifications non disponible: ${e.message}');
      } else if (mounted) {
        MessageService.showErrorMessage(e.message);
      }
    } on DioException catch (e) {
      // Ne pas afficher d'erreur si c'est un 404 (endpoint non implémenté)
      if (e.response?.statusCode == 404) {
        print('Endpoint notifications non disponible');
      } else if (mounted) {
        MessageService.showErrorMessage(
          "Erreur réseau. Vérifiez votre connexion internet",
        );
      }
    } catch (e) {
      // Erreur silencieuse si l'endpoint n'existe pas
      print('Erreur lors du chargement des notifications: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .markAsRead(id);
    } on HttpException catch (e) {
      MessageService.showWarningMessage(e.message);
    } catch (_) {
      MessageService.showErrorMessage("Erreur lors du marquage");
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false)
          .markAllAsRead();
      MessageService.showSuccessMessage("Toutes les notifications ont été marquées comme lues");
    } on HttpException catch (e) {
      MessageService.showErrorMessage(e.message);
    } catch (e) {
      MessageService.showErrorMessage("Erreur lors du marquage");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final hasUnread = provider.unreadCount > 0;
              if (!hasUnread) return SizedBox.shrink();
              
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    cusFaIcon(
                      FontAwesomeIcons.checkDouble,
                      color: notifire.getMainColor,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: notifire.getMainColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            provider.unreadCount > 99 ? '99+' : '${provider.unreadCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _markAllAsRead,
                tooltip: "Marquer tout comme lu",
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _isLoading && Provider.of<NotificationProvider>(context, listen: false).notifications.isEmpty
              ? ListShimmerPlaceholder()
              : Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    // Afficher l'erreur si aucune notification et pas en chargement
                    if (provider.notifications.isEmpty && !_isLoading) {
                      return Center(
                        child: SingleChildScrollView(
                          child: RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 100),
                                notFoundTile(
                                  text: "Aucune notification",
                                  icon: FontAwesomeIcons.solidBell,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: notifire.getMainColor,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = provider.notifications[index];
                          return notification.buildModernCard(
                            context,
                            onTap: () {
                              if (!notification.readed) {
                                _markAsRead(notification.id);
                              }
                              notification.navigateToDetail(context);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
          if (_isLoading) loadingBar(),
        ],
      ),
    );
  }
}

