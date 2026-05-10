import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service centralisé pour les notifications natives système (Android, iOS).
///
/// Encapsule l'API `flutter_local_notifications` pour exposer
/// une interface simple : `initialiser()` au démarrage de l'app,
/// puis `afficher(titre, message)` à chaque événement notifiable.
class ServiceNotificationsNatives {
  ServiceNotificationsNatives._interne();
  static final ServiceNotificationsNatives _instance =
      ServiceNotificationsNatives._interne();
  factory ServiceNotificationsNatives() => _instance;

  static const String _idCanal = 'tontineapp_canal_principal';
  static const String _nomCanal = 'TontineApp';
  static const String _descriptionCanal =
      'Notifications de l\'application TontineApp (cotisations, tours, paiements)';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialise = false;

  /// Initialise le service. À appeler une seule fois au démarrage.
  ///
  /// Demande aussi l'autorisation Android 13+ (Tiramisu) si nécessaire.
  Future<void> initialiser() async {
    if (_initialise) return;

    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: initAndroid,
        iOS: initIOS,
      ),
    );

    // Demande la permission sur Android 13+
    final implAndroid = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await implAndroid?.requestNotificationsPermission();

    _initialise = true;
  }

  /// Affiche une notification native système.
  ///
  /// `payload` est une string optionnelle qui sera passée au handler
  /// si l'utilisateur tape sur la notification (utile pour la deep link).
  Future<void> afficher({
    required String titre,
    required String message,
    String? payload,
  }) async {
    if (!_initialise) await initialiser();

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const detailsAndroid = AndroidNotificationDetails(
      _idCanal,
      _nomCanal,
      channelDescription: _descriptionCanal,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'TontineApp',
      icon: '@mipmap/ic_launcher',
    );

    const detailsIOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    try {
      await _plugin.show(
        id,
        titre,
        message,
        const NotificationDetails(android: detailsAndroid, iOS: detailsIOS),
        payload: payload,
      );
    } catch (e) {
      // En mode debug, on log mais on ne casse pas l'app si la notif échoue.
      if (kDebugMode) {
        debugPrint('Erreur notification native : $e');
      }
    }
  }

  /// Annule toutes les notifications affichées.
  Future<void> annulerToutes() async {
    await _plugin.cancelAll();
  }
}
