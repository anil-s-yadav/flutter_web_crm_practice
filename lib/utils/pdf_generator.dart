import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client_model.dart';
import '../models/contract_model.dart';
import '../models/candidate_model.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> generateAndPrintContract(
    ContractModel contract,
    ClientModel client,
    CandidateModel? candidate,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SERVICE AGREEMENT',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Contract ID: ${contract.id}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${dateFormat.format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'This Service Agreement is made between:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Client: ${client.fullName}'),
              pw.Text('Phone: ${client.phone}'),
              pw.Text('Address: ${client.address}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'And the Agency regarding the placement of:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Candidate: ${candidate?.fullName ?? 'N/A'}'),
              pw.Text('Category: ${candidate?.category ?? 'N/A'}'),
              pw.Text('Contract Start Date: ${dateFormat.format(contract.placementDate)}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Terms and Conditions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Bullet(text: 'Total Service Fee: ${contract.serviceFee}'),
              pw.Bullet(text: 'Guarantee Valid Until: ${dateFormat.format(contract.guaranteeEndDate)}'),
              pw.Bullet(text: 'Contract Ends On: ${dateFormat.format(contract.contractExpiryDate)}'),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('Client Signature'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('Agency Representative'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Contract_${contract.id}.pdf',
    );
  }
}
