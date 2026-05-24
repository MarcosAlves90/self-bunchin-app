part of 'auth_shell.dart';

class AuthFormFrame extends StatelessWidget {
  const AuthFormFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (MediaQuery.sizeOf(context).width < 920) ...<Widget>[
            const AuthCompactBrandBadge(),
            const SizedBox(height: 24),
          ],
          child,
        ],
      ),
    );
  }
}

class AuthPageHeading extends StatelessWidget {
  const AuthPageHeading({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (onBack == null) {
      return Text(
        title,
        style: authPageTitleStyle(context),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: authPageTitleStyle(context),
          ),
        ),
      ],
    );
  }
}
