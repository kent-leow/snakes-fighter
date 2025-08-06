import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/core/core.dart';
import '../lib/shared/shared.dart';

/// Example app demonstrating the responsive UI design system
class ResponsiveDesignSystemDemo extends ConsumerWidget {
  const ResponsiveDesignSystemDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Responsive Design System Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              // Toggle theme (would need provider setup in real app)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveValue<EdgeInsets>(
          mobile: const EdgeInsets.all(DesignTokens.spacing16),
          tablet: const EdgeInsets.all(DesignTokens.spacing24),
          desktop: const EdgeInsets.all(DesignTokens.spacing32),
        ).getValue(context),
        child: ResponsiveLayout(
          mobile: const _MobileLayout(),
          tablet: const _TabletLayout(),
          desktop: const _DesktopLayout(),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, 'Mobile Layout'),
        const SizedBox(height: DesignTokens.spacing24),
        _buildButtonSection(),
        const SizedBox(height: DesignTokens.spacing24),
        _buildFormSection(),
        const SizedBox(height: DesignTokens.spacing24),
        _buildCardSection(),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, 'Tablet Layout'),
        const SizedBox(height: DesignTokens.spacing32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildButtonSection(),
                  const SizedBox(height: DesignTokens.spacing24),
                  _buildFormSection(),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spacing24),
            Expanded(child: _buildCardSection()),
          ],
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, 'Desktop Layout'),
        const SizedBox(height: DesignTokens.spacing40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildButtonSection()),
            const SizedBox(width: DesignTokens.spacing32),
            Expanded(flex: 2, child: _buildFormSection()),
            const SizedBox(width: DesignTokens.spacing32),
            Expanded(flex: 3, child: _buildCardSection()),
          ],
        ),
      ],
    );
  }
}

Widget _buildHeader(BuildContext context, String title) {
  return AppCard(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          'Screen width: ${MediaQuery.of(context).size.width.toInt()}px',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    ),
  );
}

Widget _buildButtonSection() {
  return AppCard.outlined(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Buttons', style: DesignTokens.textTheme.titleLarge),
        const SizedBox(height: DesignTokens.spacing16),
        AppButton.primary(
          text: 'Primary Button',
          icon: const Icon(Icons.star),
          onPressed: () {},
        ),
        const SizedBox(height: DesignTokens.spacing8),
        AppButton.secondary(text: 'Secondary Button', onPressed: () {}),
        const SizedBox(height: DesignTokens.spacing8),
        AppButton.outline(text: 'Outline Button', onPressed: () {}),
        const SizedBox(height: DesignTokens.spacing8),
        AppButton.text(text: 'Text Button', onPressed: () {}),
        const SizedBox(height: DesignTokens.spacing16),
        Row(
          children: [
            const AppBadge(text: 'New'),
            const SizedBox(width: DesignTokens.spacing8),
            const AppBadge.success(text: 'Success'),
            const SizedBox(width: DesignTokens.spacing8),
            const AppBadge.error(text: 'Error'),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFormSection() {
  return AppCard.filled(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Form Components', style: DesignTokens.textTheme.titleLarge),
        const SizedBox(height: DesignTokens.spacing16),
        const AppTextField.email(),
        const SizedBox(height: DesignTokens.spacing16),
        const AppTextField.password(),
        const SizedBox(height: DesignTokens.spacing16),
        const AppTextField.search(hintText: 'Search for anything...'),
        const SizedBox(height: DesignTokens.spacing16),
        const AppTextArea(
          labelText: 'Message',
          hintText: 'Enter your message here...',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    ),
  );
}

Widget _buildCardSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Cards & Components', style: DesignTokens.textTheme.titleLarge),
      const SizedBox(height: DesignTokens.spacing16),
      const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elevated Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignTokens.spacing8),
            Text('This is an elevated card with shadow.'),
          ],
        ),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      const AppCard.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outlined Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: DesignTokens.spacing8),
            Text('This is an outlined card with border.'),
          ],
        ),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      const AppCard.filled(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filled Card', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: DesignTokens.spacing8),
            Text('This is a filled card with background color.'),
          ],
        ),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      const AppCard(
        child: Column(
          children: [
            AppLoadingIndicator.small(message: 'Loading...'),
            SizedBox(height: DesignTokens.spacing16),
            AppLoadingIndicator(message: 'Processing...'),
            SizedBox(height: DesignTokens.spacing16),
            AppLoadingIndicator.large(message: 'Please wait...'),
          ],
        ),
      ),
    ],
  );
}

void main() {
  runApp(const ProviderScope(child: ResponsiveDesignSystemDemo()));
}
