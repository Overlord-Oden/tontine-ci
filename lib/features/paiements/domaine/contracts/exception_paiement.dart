import '../../../../core/erreurs/exceptions.dart';

/// Exception levée par les opérateurs Mobile Money en cas d'échec.
class ExceptionPaiement extends ExceptionApp {
  const ExceptionPaiement(super.message);
}
