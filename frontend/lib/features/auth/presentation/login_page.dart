import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/features/auth/presentation/register_page.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/auth/presentation/auth_session_navigation.dart';
import 'package:bunchin_flutter/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final BunchinApi _api = BunchinApi();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _keepConnected = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      final session = await _api.login(
        credentials: LoginCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          keepConnected: _keepConnected,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        buildAuthenticatedWorkspaceRoute(session),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel concluir o login.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      brandHeadline: 'Acesso rápido para quem precisa entrar e continuar.',
      brandDescription:
          'Uma base de login limpa, escalável e coerente com o tema global do aplicativo.',
      brandTags: const ['Tema unificado', 'Pronto para API', 'Responsivo'],
      formPanel: _buildLoginPanel(context),
    );
  }

  Widget _buildLoginPanel(BuildContext context) {
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
            Text(
              'Entrar',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Use seu e-mail e senha para acessar sua conta.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'O cadastro nesta plataforma é exclusivo para empresas com CNPJ.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
                  return 'Digite um e-mail válido.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                _submit();
              },
              decoration: InputDecoration(
                labelText: 'Senha',
                hintText: 'Digite sua senha',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe sua senha.';
                }

                if (value.length < 8) {
                  return 'A senha precisa ter ao menos 8 caracteres.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _keepConnected,
                    onChanged: (value) {
                      setState(() {
                        _keepConnected = value ?? false;
                      });
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    checkboxShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: Text(
                      'Manter conectado',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Esqueci a senha'),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                  : const Text('Entrar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Entrar com Google'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sua empresa ainda nao tem conta?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text('Cadastrar empresa'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
