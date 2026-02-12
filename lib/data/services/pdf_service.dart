import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../domain/entities/quotation.dart';
import '../../domain/entities/company_config.dart';

class PdfService {
  Future<Uint8List> generateQuotationPdf({
    required Quotation quotation,
    required CompanyConfig config,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(config, quotation, dateFormat),
        footer: (context) => _buildFooter(context, config),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildClientInfo(quotation),
          pw.SizedBox(height: 20),
          _buildItemsTable(quotation, currencyFormat),
          pw.SizedBox(height: 16),
          _buildTotals(quotation, currencyFormat),
          if (quotation.notes != null && quotation.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSection('Notas', quotation.notes!),
          ],
          if (quotation.termsConditions != null &&
              quotation.termsConditions!.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection(
                'Terminos y Condiciones', quotation.termsConditions!),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    CompanyConfig config,
    Quotation quotation,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Company info
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  config.companyName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo,
                  ),
                ),
                if (config.address != null && config.address!.isNotEmpty)
                  pw.Text(config.address!, style: const pw.TextStyle(fontSize: 9)),
                if (config.phone != null && config.phone!.isNotEmpty)
                  pw.Text('Tel: ${config.phone}',
                      style: const pw.TextStyle(fontSize: 9)),
                if (config.email != null && config.email!.isNotEmpty)
                  pw.Text(config.email!,
                      style: const pw.TextStyle(fontSize: 9)),
                if (config.taxId != null && config.taxId!.isNotEmpty)
                  pw.Text('NIT: ${config.taxId}',
                      style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
            // Quotation info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.indigo, width: 1.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'COTIZACION',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('#${quotation.quotationNumber}',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Fecha: ${dateFormat.format(quotation.issueDate)}',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                      'Vigencia: ${dateFormat.format(quotation.validUntil)}',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: _statusPdfColor(quotation.status),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      quotation.status,
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.indigo, thickness: 2),
      ],
    );
  }

  pw.Widget _buildClientInfo(Quotation quotation) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Cliente',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(quotation.clientName,
              style: const pw.TextStyle(fontSize: 11)),
          if (quotation.clientEmail != null &&
              quotation.clientEmail!.isNotEmpty)
            pw.Text(quotation.clientEmail!,
                style: const pw.TextStyle(fontSize: 9)),
          if (quotation.clientPhone != null &&
              quotation.clientPhone!.isNotEmpty)
            pw.Text('Tel: ${quotation.clientPhone}',
                style: const pw.TextStyle(fontSize: 9)),
          if (quotation.clientAddress != null &&
              quotation.clientAddress!.isNotEmpty)
            pw.Text(quotation.clientAddress!,
                style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(
      Quotation quotation, NumberFormat currencyFormat) {
    final headers = ['#', 'Descripcion', 'Unidad', 'Cant.', 'P. Unitario', 'Subtotal'];

    final data = quotation.items.map((item) {
      return [
        item.position.toString(),
        item.description,
        item.unit,
        item.quantity % 1 == 0
            ? item.quantity.toInt().toString()
            : item.quantity.toString(),
        currencyFormat.format(item.unitPrice),
        currencyFormat.format(item.quantity * item.unitPrice),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(55),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(80),
      },
      cellAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotals(Quotation quotation, NumberFormat currencyFormat) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _totalPdfRow('Subtotal', currencyFormat.format(quotation.subtotal)),
            if (quotation.discountPercentage > 0) ...[
              _totalPdfRow(
                'Descuento (${quotation.discountPercentage}%)',
                '-${currencyFormat.format(quotation.discountAmount)}',
              ),
              _totalPdfRow(
                'Subtotal con descuento',
                currencyFormat
                    .format(quotation.subtotal - quotation.discountAmount),
              ),
            ],
            _totalPdfRow(
              'IVA (${quotation.taxPercentage.toStringAsFixed(0)}%)',
              currencyFormat.format(quotation.taxAmount),
            ),
            pw.Divider(thickness: 1.5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text(
                  currencyFormat.format(quotation.total),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildSection(String title, String content) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(content, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, CompanyConfig config) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              config.companyName,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Pagina ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  PdfColor _statusPdfColor(String status) {
    switch (status) {
      case 'Borrador':
        return PdfColors.grey600;
      case 'Enviada':
        return PdfColors.blue;
      case 'Aceptada':
        return PdfColors.green;
      case 'Rechazada':
        return PdfColors.red;
      default:
        return PdfColors.grey600;
    }
  }
}
