import 'package:flutter/material.dart';

import '../services/pdf_compression_level.dart';

Future<PdfCompressionLevel?> showPdfCompressionLevelDialog(
  BuildContext context, {
  required String saveLocation,
}) => showDialog<PdfCompressionLevel>(
  context: context,
  builder: (dialogContext) {
    var selected = PdfCompressionLevel.recommended;
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Compression level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Compressed copies will be saved in $saveLocation.'),
            const SizedBox(height: 8),
            RadioGroup<PdfCompressionLevel>(
              groupValue: selected,
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() => selected = value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Option(
                    level: PdfCompressionLevel.extreme,
                    title: 'Extreme',
                    description: 'Strong compression with readable detail',
                    onSelected: (value) =>
                        setDialogState(() => selected = value),
                  ),
                  _Option(
                    level: PdfCompressionLevel.recommended,
                    title: 'Recommended',
                    description: 'Aims for up to 50% smaller files',
                    onSelected: (value) =>
                        setDialogState(() => selected = value),
                  ),
                  _Option(
                    level: PdfCompressionLevel.less,
                    title: 'Less compression',
                    description: 'Aims for up to 33% smaller files',
                    onSelected: (value) =>
                        setDialogState(() => selected = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, selected),
            child: const Text('Compress'),
          ),
        ],
      ),
    );
  },
);

class _Option extends StatelessWidget {
  const _Option({
    required this.level,
    required this.title,
    required this.description,
    required this.onSelected,
  });

  final PdfCompressionLevel level;
  final String title;
  final String description;
  final ValueChanged<PdfCompressionLevel> onSelected;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Radio<PdfCompressionLevel>(value: level),
    title: Text(title),
    subtitle: Text(description),
    onTap: () => onSelected(level),
  );
}
