import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/screening_result.dart';
import '../theme/app_theme.dart';

class ReferralSlipScreen extends StatefulWidget {
  final ScreeningResult result;
  final String? patientName;

  const ReferralSlipScreen({
    super.key,
    required this.result,
    this.patientName,
  });

  @override
  State<ReferralSlipScreen> createState() => _ReferralSlipScreenState();
}

class _ReferralSlipScreenState extends State<ReferralSlipScreen> {
  bool _includePatientName = false;

  String get _displayPatientName =>
      _includePatientName && widget.patientName?.trim().isNotEmpty == true
          ? widget.patientName!.trim()
          : 'Withheld - consent not recorded';

  String get _screeningDate => _formatDate(widget.result.timestamp);

  String get _triage => widget.result.triage ?? 'Unknown';

  String get _recordTitle => switch (_triage.toLowerCase()) {
        'refer' => 'OPHTHALMOLOGY REFERRAL RECORD',
        'monitor' => 'MONITORING SCREENING RECORD',
        'normal' => 'NORMAL SCREENING RECORD',
        _ => 'SCREENING RECORD',
      };

  String get _nextStep => switch (_triage.toLowerCase()) {
        'refer' =>
          'Attach this record when referring to the City Health Office ophthalmology contact.',
        'monitor' =>
          'Keep this record with the patient\'s health records and follow the clinician\'s recommended return plan.',
        'normal' =>
          'Keep this record with the patient\'s health records. It does not replace a clinician\'s examination.',
        _ => 'Keep this record with the patient\'s health records.',
      };

  String get _shareText => '''CLARUS SCREENING RECORD

Patient: $_displayPatientName
Screening date: $_screeningDate
Triage: $_triage
Triage confidence: ${((widget.result.triageConfidence ?? widget.result.confidence) * 100).toStringAsFixed(1)}%
Severity: ${widget.result.severity ?? 'Not provided'}
Severity confidence: ${widget.result.severityConfidence == null ? 'Not provided' : '${(widget.result.severityConfidence! * 100).toStringAsFixed(1)}%'}
Encounter: ${widget.result.encounterId ?? 'Not available'}
Grad-CAM reference: ${widget.result.gradcamUrl ?? 'Not available'}

$_nextStep This screening supports care decisions and does not replace a clinician's diagnosis.''';

  String _formatDate(DateTime date) =>
      '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Future<void> _shareSlip() async {
    await Share.share(_shareText, subject: 'Clarus ophthalmology referral');
  }

  Future<void> _sharePdf() async {
    final bytes = await _buildPdf(PdfPageFormat.a4);
    final encounter = widget.result.encounterId ?? 'record';
    final file = XFile.fromData(
      bytes,
      name: 'clarus-${_triage.toLowerCase()}-$encounter.pdf',
      mimeType: 'application/pdf',
    );
    await Share.shareXFiles(
      [file],
      text: _shareText,
      subject: 'Clarus screening record',
    );
  }

  Future<void> _printSlip() async {
    await Printing.layoutPdf(onLayout: (format) => _buildPdf(format));
  }

  Future<void> _downloadPdf() async {
    final bytes = await _buildPdf(PdfPageFormat.a4);
    final encounter = widget.result.encounterId ?? 'record';
    final fileName = 'clarus-${_triage.toLowerCase()}-$encounter.pdf';
    final savedPath = defaultTargetPlatform == TargetPlatform.android
        ? await const MethodChannel('clarus/storage').invokeMethod<String>(
            'savePdfToDownloads',
            {'name': fileName, 'bytes': bytes},
          )
        : await FileSaver.instance.saveAs(
            name: fileName.replaceFirst('.pdf', ''),
            bytes: bytes,
            ext: 'pdf',
            mimeType: MimeType.pdf,
          );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          savedPath == null
              ? 'Download cancelled.'
              : 'PDF saved in the emulator Downloads folder.',
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CLARUS',
              style: const pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              _recordTitle,
              style: const pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),
            _pdfRow('Patient', _displayPatientName),
            _pdfRow('Screening date', _screeningDate),
            _pdfRow('Triage', _triage),
            _pdfRow(
              'Triage confidence',
              '${((widget.result.triageConfidence ?? widget.result.confidence) * 100).toStringAsFixed(1)}%',
            ),
            _pdfRow('Severity', widget.result.severity ?? 'Not provided'),
            _pdfRow(
              'Severity confidence',
              widget.result.severityConfidence == null
                  ? 'Not provided'
                  : '${(widget.result.severityConfidence! * 100).toStringAsFixed(1)}%',
            ),
            _pdfRow('Encounter', widget.result.encounterId ?? 'Not available'),
            _pdfRow(
              'Grad-CAM reference',
              widget.result.gradcamUrl ?? 'Not available',
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              _nextStep,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'This screening supports referral and does not replace a clinician\'s diagnosis.',
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 9),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 120,
              child: pw.Text(
                label,
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(child: pw.Text(value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screening record')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: ClarusColors.cardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLARUS',
                  style: ClarusType.mono(size: 13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _recordTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: ClarusColors.refer,
                      ),
                ),
                const Divider(height: 28),
                _detailRow('Patient', _displayPatientName),
                _detailRow('Screening date', _screeningDate),
                _detailRow(
                  'Triage',
                  _triage,
                ),
                _detailRow(
                  'Severity',
                  widget.result.severity ?? 'Not provided',
                ),
                _detailRow(
                  'Encounter',
                  widget.result.encounterId ?? 'Not available',
                ),
                _detailRow(
                  'Grad-CAM reference',
                  widget.result.gradcamUrl ?? 'Not available',
                ),
                const SizedBox(height: 12),
                Text(
                  _nextStep,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _includePatientName,
            onChanged: (value) =>
                setState(() => _includePatientName = value ?? false),
            title: const Text('Patient consented to include their name'),
            subtitle: const Text(
              'The name stays hidden from the slip until this is checked.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _printSlip,
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print screening record'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _sharePdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Share / export PDF'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _downloadPdf,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download PDF'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _shareSlip,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share referral details'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
