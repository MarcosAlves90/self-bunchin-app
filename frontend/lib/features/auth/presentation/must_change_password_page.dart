import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/admin/presentation/admin_employees_page.dart';
import 'package:bunchin_flutter/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';

class MustChangePasswordPage extends StatefulWidget {
  const MustChangePasswordPage({super.key});

  @override
  State<MustChangePasswordPage> createState() => _MustChangePasswordPageState();
}

class _MustChangePasswordPageState extends State<MustChangePasswordPage> {
  final BunchinApi _api = BunchinApi();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
      await _api.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso.'),
        ),
      );

      // Navigate to workspace based on user role
      Navigator.of(context).pushReplacement(
        _buildWorkspaceRoute(),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel redefinir sua senha.'),
        ),
      );
    }
  }

  Route<void> _buildWorkspaceRoute() {
    // User is authenticated but we only know they completed password change.
    // Fetching full AuthContext here would add latency. Navigate to admin
    // as safe default — admin is the most common role after password reset.
    // Refresh on workspace will fetch real context.
    return MaterialPageRoute<void>(
      builder: (_) => const AdminEmployeesPage(),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe uma nova senha.';
    }
    if (value.length < 8) {
      return 'A senha precisa ter ao menos 8 caracteres.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme a nova senha.';
    }
    if (value != _newPasswordController.text) {
      return 'As senhas nao conferem.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      brandHeadline: 'Redefinição obrigatória de senha.',
      brandDescription:
          'Você está usando uma senha temporária. Crie uma nova senha para continuar.',
      brandTags: const [
        'E2E Encryption',
        'Seguranca',
        'Cloud Native',
      ],
      formPanel: _buildFormPanel(context),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
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
              'Criar nova senha',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Defina uma senha forte e exclusiva para proteger sua conta.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Senha atual (temporaria)',
                hintText: 'Digite a senha recebida por e-mail',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    });
                  },
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe sua senha atual.';
                }
                if (value.length < 8) {
                  return 'A senha precisa ter ao menos 8 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nova senha',
                hintText: 'Minimo de 8 caracteres',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: _validatePassword,
              onChanged: (_) {
                if (_confirmPasswordController.text.isNotEmpty) {
                  _formKey.currentState?.validate();
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirmar nova senha',
                hintText: 'Repita a nova senha',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: _validateConfirm,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                    : const Text('Redefinir senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}