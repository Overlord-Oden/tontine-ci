import '../entites/notification_app.dart';

/// Contrat du repository des notifications.
abstract class NotificationRepository {
  /// Crée une notification, la persiste, et déclenche aussi la
  /// notification native si possible.
  Future<NotificationApp> creer({
    required TypeNotification type,
    required String titre,
    required String message,
    Map<String, String> donnees = const {},
  });

  /// Liste toutes les notifications, de la plus récente à la plus ancienne.
  Future<List<NotificationApp>> lister();

  /// Marque une notification comme lue.
  Future<void> marquerLue(String idNotification);

  /// Marque toutes les notifications comme lues.
  Future<void> marquerToutesLues();

  /// Supprime une notification.
  Future<void> supprimer(String idNotification);

  /// Supprime toutes les notifications.
  Future<void> effacerTout();

  /// Nombre de notifications non lues.
  Future<int> compterNonLues();
}
