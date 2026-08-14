import 'package:flutter/material.dart';

class StyleGalleryScreen extends StatelessWidget {
  const StyleGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Gallery (Hydrotek Fresh)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0), // Using 28px padding as per design system
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(
              'Botanical Gradients & Ambient Shadows',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSpecialCard(colorScheme),
            const SizedBox(height: 32),
            Text(
              'Color Palette',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildColorSection('Primary', [
              _ColorSwatch(color: colorScheme.primary, name: 'Primary', onColor: colorScheme.onPrimary),
              _ColorSwatch(color: colorScheme.primaryContainer, name: 'Primary Container', onColor: colorScheme.onPrimaryContainer),
              _ColorSwatch(color: colorScheme.inversePrimary, name: 'Inverse Primary', onColor: colorScheme.onPrimaryContainer),
            ]),
            _buildColorSection('Secondary (Water/Hydration)', [
              _ColorSwatch(color: colorScheme.secondary, name: 'Secondary', onColor: colorScheme.onSecondary),
              _ColorSwatch(color: colorScheme.secondaryContainer, name: 'Secondary Container', onColor: colorScheme.onSecondaryContainer),
            ]),
             _buildColorSection('Tertiary', [
              _ColorSwatch(color: colorScheme.tertiary, name: 'Tertiary', onColor: colorScheme.onTertiary),
              _ColorSwatch(color: colorScheme.tertiaryContainer, name: 'Tertiary Container', onColor: colorScheme.onTertiaryContainer),
            ]),
             _buildColorSection('Surface Hierarchy', [
              _ColorSwatch(color: colorScheme.surface, name: 'Surface', onColor: colorScheme.onSurface),
              _ColorSwatch(color: colorScheme.surfaceContainerHighest, name: 'Surface Variant', onColor: colorScheme.onSurfaceVariant),
              _ColorSwatch(color: colorScheme.inverseSurface, name: 'Inverse Surface', onColor: colorScheme.onInverseSurface),
            ]),
            _buildColorSection('Error & Context', [
               _ColorSwatch(color: colorScheme.error, name: 'Error', onColor: colorScheme.onError),
               _ColorSwatch(color: colorScheme.errorContainer, name: 'Error Container', onColor: colorScheme.onErrorContainer),
               _ColorSwatch(color: colorScheme.outline, name: 'Outline', onColor: colorScheme.surface),
               _ColorSwatch(color: colorScheme.outlineVariant, name: 'Outline Variant', onColor: colorScheme.onSurface),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: const GradientRotation(2.35619), // ~135 degrees
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F166C44), // Green tinted shadow
            blurRadius: 30,
            offset: Offset(0, 10),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Metric "Lens"',
            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'This card uses the Botanical Gradient and Ambient Depth specified in the design markdown.',
            style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.8)),
          )
        ],
      )
    );
  }

  Widget _buildColorSection(String title, List<Widget> swatches) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: swatches,
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String name;
  final Color onColor;

  const _ColorSwatch({
    required this.color,
    required this.name,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: onColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
             style: TextStyle(
              color: onColor.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'monospace'
            ),
          ),
        ],
      ),
    );
  }
}
