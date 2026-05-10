import '../../../../core/donnees/stockage_json.dart';
import '../../domaine/contracts/notification_repository.dart';
import '../../domaine/entites/notification_app.dart';
import '../services/service_notifications_natives.dart';

/// Implémentation persistante du [NotificationRepository].
///
/// - Persiste les notifications en JSON sur le disque
/// - Déclenche aussi une notification native système à chaque création
class NotificationRepositoryDemo implements NotificationRepository {
  NotificationRepositoryDemo._interne();
  static final NotificationRepositoryDemo _instance =
      NotificationRepositoryDemo._interne();
  factory NotificationRepositoryDemo() => _instance;

  static const String _nomCollection = 'notifications';
  static const int _maxNotifications = 200; // évite que ça enfle indéfiniment

  final StockageJson _stockage = StockageJson();
  final ServiceNotificationsNatives _serviceNatif =
      ServiceNotificationsNatives();

  List<NotificationApp> _notifications = [];
  bool _chargeDuDisque = false;

  Future<void> _chargerSiNecessaire() async {
    if (_chargeDuDisque) return;
    _chargeDuDisque = true;

    final brut = await _stockage.charger(_nomCollection);
    if (brut is List) {
      try {
        _notifications = brut
            .map((e) =>
                NotificationApp.depuisJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _notifications = [];
      }
    }
  }

  Future<void> _sauvegarder() async {
    // Tronque si on dépasse la limite (garde les plus récentes)
    if (_notifications.length > _maxNotifications) {
      _notifications.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      _notifications = _notifications.take(_maxNotifications).toList();
    }
    await _stockage.sauvegarder(
      _nomCollection,
      _notifications.map((n) => n.versJson()).toList(),
    );
  }

  @override
  Future<NotificationApp> creer({
    required TypeNotification type,
    required String titre,
    required String message,
    Map<String, String> donnees = const {},
  }) async {
    await _chargerSiNecessaire();

    final notif = NotificationApp(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      titre: titre,
      message: message,
      dateCreation: DateTime.now(),
      donnees: donnees,
    );

    _notifications.insert(0, notif);
    await _sauvegarder();

    // Déclenche aussi la notification native (best-effort, n'échoue pas)
    // ignore: unawaited_futures
    _serviceNatif.afficher(titre: titre, message: message);

    return notif;
  }

  @override
  Future<List<NotificationApp>> lister() async {
    await _chargerSiNecessaire();
    return _notifications.toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  @override
  Future<void> marquerLue(String idNotification) async {
    await _chargerSiNecessaire();
    final index = _notifications.indexWhere((n) => n.id == idNotification);
    if (index == -1) return;
    if (_notifications[index].lue) return;

    _notifications[index] = _notifications[index].copierAvec(lue: true);
    await _sauvegarder();
  }

  @override
  Future<void> marquerToutesLues() async {
    await _chargerSiNecessaire();
    bool modif = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].lue) {
        _notifications[i] = _notifications[i].copierAvec(lue: true);
        modif = true;
      }
    }
    if (modif) await _sauvegarder();
  }

  @override
  Future<void> supprimer(String idNotification) async {
    await _chargerSiNecessaire();
    _notifications.removeWhere((n) => n.id == idNotification);
    await _sauvegarder();
  }

  @override
  Future<void> effacerTout() async {
    _notifications.clear();
    await _sauvegarder();
  }

  @override
  Future<int> compterNonLues() async {
    await _chargerSiNecessaire();
    return _notifications.where((n) => !n.lue).length;
  }
}
