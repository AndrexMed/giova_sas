// lib/domain/entities/quotation.dart

import 'quotation_item.dart';

/// Clase de Entidad pura que representa una Cotización completa.
class Quotation {
  final String id;
  final String quotationNumber;
  final String clientId;
  // NOTA: Podríamos tener solo el clientId, pero guardamos el nombre/email
  // para tener una instantánea del cliente al momento de la cotización.
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? clientAddress;

  final DateTime issueDate;
  final DateTime validUntil;

  // Totales
  final double subtotal;
  final double taxPercentage;
  final double taxAmount;
  final double discountPercentage;
  final double discountAmount;
  final double total;

  final String status; // Ej: 'Draft', 'Sent', 'Accepted', 'Rejected'
  final String? notes;
  final String? termsConditions;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relación con los ítems (NO se almacena en la tabla 'quotations', solo en memoria)
  final List<QuotationItem> items;

  Quotation({
    required this.id,
    required this.quotationNumber,
    required this.clientId,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    required this.issueDate,
    required this.validUntil,
    required this.subtotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.discountPercentage,
    required this.discountAmount,
    required this.total,
    required this.status,
    this.notes,
    this.termsConditions,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  // copyWith method...
  Quotation copyWith({
    String? id,
    String? quotationNumber,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    DateTime? issueDate,
    DateTime? validUntil,
    double? subtotal,
    double? taxPercentage,
    double? taxAmount,
    double? discountPercentage,
    double? discountAmount,
    double? total,
    String? status,
    String? notes,
    String? termsConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuotationItem>? items,
  }) {
    return Quotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      issueDate: issueDate ?? this.issueDate,
      validUntil: validUntil ?? this.validUntil,
      subtotal: subtotal ?? this.subtotal,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      termsConditions: termsConditions ?? this.termsConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}
