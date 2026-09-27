import 'dart:convert';
import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _scanResult;
  String? _diagnosisResult;
  String? _uploadStatus;
  String? _uploadedImageKey;
  bool _isUploading = false;

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
      _selectedImageFile = image;
      _selectedImageBytes = imageBytes;
      _scanResult = null;
      _diagnosisResult = null;
      _uploadStatus = null;
      _uploadedImageKey = null;
    });
  }

  Future<void> _uploadAndDiagnoseCurrentImage() async {
    final image = _selectedImageFile;
    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading image to S3...';
      _diagnosisResult = null;
    });

    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      // Guest storage is scoped to the public prefix by Amplify's S3 policy.
      final username = _safeS3Name(currentUser.username);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'public/${username}_$timestamp${path.extension(image.name).toLowerCase()}';
      await Amplify.Storage.uploadFile(
        path: StoragePath.fromString(fileName),
        localFile: AWSFile.fromPath(image.path),
        options: StorageUploadFileOptions(
          metadata: {
            'userid': currentUser.userId,
            'userId': currentUser.userId,
            'username': currentUser.username,
          },
        ),
      ).result;

      await Amplify.Storage.getProperties(
        path: StoragePath.fromString(fileName),
      ).result;

      if (mounted) {
        setState(() {
          _uploadedImageKey = fileName;
          _uploadStatus = 'Image uploaded and verified in S3: $fileName';
        });
      }

      final diagnosis = await _waitForDiagnosis(fileName);

      if (!mounted) {
        return;
      }

      setState(() {
        _uploadStatus = diagnosis == null
            ? 'Upload successful. S3 key: $_uploadedImageKey'
            : 'Diagnosis fetched successfully for $_uploadedImageKey';
        _diagnosisResult = diagnosis ??
            'The image was uploaded, but the diagnosis service did not return a result within 30 seconds.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _uploadStatus = _uploadedImageKey == null
            ? 'Upload failed: $error'
            : 'Image uploaded to S3. Diagnosis lookup failed: $error';
        _diagnosisResult = _uploadedImageKey == null
            ? null
            : 'The image is stored at $_uploadedImageKey, but the diagnosis service returned an error.';
      });
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _safeS3Name(String value) {
    final sanitized = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return sanitized.isEmpty ? 'user' : sanitized;
  }

  Future<String?> _waitForDiagnosis(String imageKey) async {
    for (var attempt = 0; attempt < 6; attempt++) {
      if (mounted) {
        setState(() {
          _uploadStatus = 'Fetching diagnosis... (${attempt + 1} of 6)';
        });
      }

      final diagnosis = await _fetchLatestDiagnosis(imageKey);
      if (diagnosis != null) {
        return diagnosis;
      }

      if (attempt < 5) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    }

    return null;
  }

  Future<String?> _fetchLatestDiagnosis(String imageKey) async {
    const document = '''
      query ListDiagnoses {
        listDiagnoses(limit: 1000) {
          items {
            id
            image_key
            disease_detected
            fungal_status
            health_status
            recommendations
            timestamp
          }
        }
      }
    ''';

    final response = await Amplify.API
        .query(
          request: GraphQLRequest<String>(
            document: document,
            authorizationMode: APIAuthorizationType.userPools,
          ),
        )
        .response;

    if (response.errors.isNotEmpty) {
      throw Exception(
        response.errors.map((error) => error.message).join('; '),
      );
    }

    if (response.data == null) {
      throw Exception('Diagnosis API returned an empty response.');
    }

    final decoded = jsonDecode(response.data!);
    final items =
        decoded['listDiagnoses']?['items'] as List<dynamic>? ?? const [];

    for (final item in items.reversed) {
      final map = item as Map<String, dynamic>;
      if (_isMatchingImageKey(map['image_key'], imageKey)) {
        final disease = map['disease_detected'] ?? 'Diagnosis available';
        final fungalStatus = map['fungal_status'];
        final healthStatus = map['health_status'] ?? 'Status unavailable';
        final recommendations = (map['recommendations'] as List<dynamic>?)
            ?.map((recommendation) => recommendation.toString())
            .join('\n');
        final details = recommendations == null || recommendations.isEmpty
            ? ''
            : '\n$recommendations';
        final status =
            fungalStatus != null && fungalStatus.toString().isNotEmpty
                ? '$fungalStatus / $healthStatus'
                : healthStatus;
        return '$disease ($status)$details';
      }
    }

    return null;
  }

  bool _isMatchingImageKey(Object? storedKey, String uploadedKey) {
    if (storedKey == null) {
      return false;
    }

    final stored = Uri.decodeComponent(storedKey.toString());
    final uploaded = Uri.decodeComponent(uploadedKey);
    final storedName = path.basename(stored);
    final uploadedName = path.basename(uploaded);

    return stored == uploaded ||
        storedName == uploadedName ||
        stored.endsWith('/$uploadedName') ||
        uploaded.endsWith('/$storedName');
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
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.camera_alt_outlined),
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
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isUploading ? null : _uploadAndDiagnoseCurrentImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isUploading
                    ? 'Fetching diagnosis...'
                    : 'Upload & diagnose'),
              ),
            ],
            if (_scanResult != null) ...[
              const SizedBox(height: 20),
              _buildResult(context, 'Scanned result', _scanResult!),
            ],
            if (_uploadStatus != null) ...[
              const SizedBox(height: 20),
              _buildResult(context, 'Upload status', _uploadStatus!),
            ],
            if (_diagnosisResult != null) ...[
              const SizedBox(height: 20),
              _buildResult(context, 'Diagnosis', _diagnosisResult!),
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

  Future<void> _openScanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScannerPage(onDetect: _handleDetection),
      ),
    );
  }

  Widget _buildResult(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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

class ScannerPage extends StatefulWidget {
  const ScannerPage({required this.onDetect, super.key});

  final ValueChanged<BarcodeCapture> onDetect;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasDetected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_hasDetected || capture.barcodes.firstOrNull?.rawValue == null) {
      return;
    }

    _hasDetected = true;
    widget.onDetect(capture);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan plant'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close scanner',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          Center(
            child: Container(
              width: 280,
              height: 190,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
