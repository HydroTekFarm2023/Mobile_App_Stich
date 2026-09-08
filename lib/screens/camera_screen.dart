import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _scanResult;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) {
      return;
    }

    final imageBytes = await image.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImageBytes = imageBytes;
      _scanResult = null;
    });
  }

  void _handleDetection(BarcodeCapture capture) {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value == _scanResult || !mounted) {
      return;
    }

    setState(() => _scanResult = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a plant label or upload an image from your gallery.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 24),
            _buildScanner(context),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _scannerController.start,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_scanResult != null) ...[
              const SizedBox(height: 20),
              _buildResult(context, 'Scanned result', _scanResult!),
            ],
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 20),
              _buildUploadedImage(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 300,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.35), width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Text(
              'Point your camera at a code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, String title, String value) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      leading: const Icon(Icons.check_circle_outline),
      title: Text(title),
      subtitle: Text(value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildUploadedImage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Uploaded image', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _selectedImageBytes!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Text('Image selected'),
            ),
          ),
        ),
      ],
    );
  }
}
