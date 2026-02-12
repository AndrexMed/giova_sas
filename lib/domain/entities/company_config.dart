class CompanyConfig {
  final String id;
  final String companyName;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxId;
  final String? logoPath;
  final double defaultTaxPercentage;
  final String? defaultTermsConditions;
  final String currency;
  final DateTime updatedAt;

  CompanyConfig({
    required this.id,
    required this.companyName,
    this.email,
    this.phone,
    this.address,
    this.taxId,
    this.logoPath,
    required this.defaultTaxPercentage,
    this.defaultTermsConditions,
    required this.currency,
    required this.updatedAt,
  });

  CompanyConfig copyWith({
    String? id,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? taxId,
    String? logoPath,
    double? defaultTaxPercentage,
    String? defaultTermsConditions,
    String? currency,
    DateTime? updatedAt,
  }) {
    return CompanyConfig(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      logoPath: logoPath ?? this.logoPath,
      defaultTaxPercentage: defaultTaxPercentage ?? this.defaultTaxPercentage,
      defaultTermsConditions:
          defaultTermsConditions ?? this.defaultTermsConditions,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
