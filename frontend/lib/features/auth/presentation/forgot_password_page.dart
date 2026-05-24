import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final BunchinApi _api = BunchinApi();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _api.resetPassword(email: _emailController.text.trim());
    } on ApiException {
      // Always show success to avoid email enumeration
    } catch (_) {
      // Generic error — show success anyway (anti-enumeration)
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  void _backToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      brandHeadline: 'Recupere acesso com rapidez.',
      brandDescription:
          'Envie um link seguro para redefinir sua senha e retomar o controle da operação.',
      brandTags: const [
        'E2E Encryption',
        'Automação',
        'Cloud Native',
      ],
      formPanel: _buildForgotPasswordPanel(context),
    );
  }

  Widget _buildForgotPasswordPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.sizeOf(context).width < 920) ...[
              const AuthCompactBrandBadge(),
              const SizedBox(height: 24),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _backToLogin,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Esqueci a senha',
                    style: authPageTitleStyle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_submitted)
              _buildSuccessMessage(theme, colorScheme)
            else ...[
              Text(
                'Informe o e-mail corporativo para receber instrucoes de redefinicao.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'voce@empresa.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu e-mail.';
                  }

                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Digite um e-mail valido.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        _submit();
                      },
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar link'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _backToLogin,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Voltar para login'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 56,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'E-mail enviado com sucesso.',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Se o e-mail informado estiver cadastrado em nossa base, '
          'voce recebera as instrucoes de redefinicao de senha em breve.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _backToLogin,
          icon: const Icon(Icons.login_rounded),
          label: const Text('Voltar para login'),
        ),
      ],
    );
  }
}
