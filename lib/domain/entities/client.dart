class Client {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? company;
  final String? identification;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.company,
    this.identification,
    required this.createdAt,
  });

  /// Método para copiar la entidad, útil para inmutabilidad (por ejemplo, al actualizar un campo).
  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? company,
    String? identification,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      company: company ?? this.company,
      identification: identification ?? this.identification,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
