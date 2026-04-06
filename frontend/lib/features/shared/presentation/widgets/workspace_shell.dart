import 'dart:ui';

import 'package:bunchin_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WorkspaceScaffold extends StatelessWidget {
  const WorkspaceScaffold({
    super.key,
    required this.sidebar,
    required this.contentBuilder,
    this.wideBreakpoint = 1080,
    this.sidebarWidth = 360,
  });

  final Widget sidebar;
  final Widget Function(BuildContext context, bool isWide) contentBuilder;
  final double wideBreakpoint;
  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.84),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -120,
              right: -40,
              child: _AmbientGlow(
                color: AppTheme.accent.withValues(alpha: 0.22),
                size: 280,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: _AmbientGlow(
                color: colorScheme.secondary.withValues(alpha: 0.14),
                size: 260,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= wideBreakpoint;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.74),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: isWide
                            ? _buildWideLayout(context, constraints)
                            : _buildNarrowLayout(context, constraints),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: sidebarWidth,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: sidebar,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: contentBuilder(context, true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          children: <Widget>[sidebar, contentBuilder(context, false)],
        ),
      ),
    );
  }
}

class WorkspaceSidebar extends StatelessWidget {
  const WorkspaceSidebar({
    super.key,
    required this.title,
    required this.description,
    required this.summaryChildren,
    required this.highlightChips,
    this.brandLabel = 'BUNCHIN',
  });

  final String title;
  final String description;
  final List<Widget> summaryChildren;
  final List<Widget> highlightChips;
  final String brandLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppTheme.accent.withValues(alpha: 0.96),
            const Color(0xFFE28E00),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              brandLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              height: 1.55,
            ),
          ),
          if (summaryChildren.isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            for (
              var index = 0;
              index < summaryChildren.length;
              index++
            ) ...<Widget>[
              if (index > 0) const SizedBox(height: 16),
              summaryChildren[index],
            ],
          ],
          if (highlightChips.isNotEmpty) ...<Widget>[
            const SizedBox(height: 32),
            Wrap(spacing: 12, runSpacing: 12, children: highlightChips),
          ],
        ],
      ),
    );
  }
}

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    super.key,
    required this.title,
    required this.description,
    this.maxContentWidth = 560,
    this.actions = const <Widget>[],
  });

  final String title;
  final String description;
  final double maxContentWidth;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Wrap(spacing: 12, runSpacing: 12, children: actions),
      ],
    );
  }
}

class WorkspaceSectionCard extends StatelessWidget {
  const WorkspaceSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.56),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class WorkspaceMetricCard extends StatelessWidget {
  const WorkspaceMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkspaceSummaryStripe extends StatelessWidget {
  const WorkspaceSummaryStripe({
    super.key,
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkspaceHighlightChip extends StatelessWidget {
  const WorkspaceHighlightChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class WorkspaceStatusBadge extends StatelessWidget {
  const WorkspaceStatusBadge({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
