/// Clase base para representar cualquier error de la aplicación (Dominio/Datos).
/// Usada en el tipo de retorno Either<Failure, T> para el manejo de errores funcional.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Representa un error general de la capa de datos (ej. Base de datos caída, conexión SQFLite rota).
class DataFailure extends Failure {
  const DataFailure(String message) : super(message);
}

/// Representa un error cuando una entidad no es encontrada (ej. al buscar por ID).
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Representa un error de validación o de negocio (ej. campo obligatorio vacío).
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
