import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/auth/presentation/auth_session_navigation.dart';
import 'package:bunchin_flutter/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:bunchin_flutter/core/forms/br_input_masks.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final BunchinApi _api = BunchinApi();
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _tradeNameController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os termos para continuar o cadastro.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final session = await _api.registerCompany(
        draft: CompanyRegistrationDraft(
          companyName: _companyNameController.text.trim(),
          tradeName: _tradeNameController.text.trim(),
          cnpj: _cnpjController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          acceptTerms: _acceptTerms,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa cadastrada com sucesso.'),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        buildAuthenticatedWorkspaceRoute(session),
        (route) => false,
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
          content: Text('Nao foi possivel concluir o cadastro da empresa.'),
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
      brandHeadline:
          'Cadastro pensado para empresas que precisam operar rápido.',
      brandDescription:
          'Estruture o onboarding B2B com dados essenciais, validação clara e um fluxo pronto para conectar API, CRM ou backoffice.',
      brandTags: const [
        'Cadastro empresarial',
        'Onboarding B2B',
        'Pronto para integração',
      ],
      formPanel: _buildRegisterPanel(context),
    );
  }

  Widget _buildRegisterPanel(BuildContext context) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cadastrar empresa',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Este fluxo é exclusivo para empresas. Informe os dados principais da operação para criar o acesso inicial.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.72,
                ),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cadastro exclusivo para empresas com CNPJ. Perfis pessoais devem ser tratados em um fluxo separado.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _companyNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Razão social',
                hintText: 'Empresa Exemplo Tecnologia LTDA',
                prefixIcon: Icon(Icons.apartment_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a razão social.';
                }

                if (value.trim().length < 5) {
                  return 'Use o nome jurídico completo da empresa.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tradeNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome fantasia',
                hintText: 'Empresa Exemplo',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome fantasia.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [BrInputMasks.cnpjFormatter],
              decoration: const InputDecoration(
                labelText: 'CNPJ',
                hintText: '00.000.000/0000-00',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (value) {
                final digits = BrInputMasks.digitsOnly(value ?? '');

                if (digits.isEmpty) {
                  return 'Informe o CNPJ.';
                }

                if (!BrInputMasks.hasValidCnpjDigits(value ?? '')) {
                  return 'Digite um CNPJ com 14 dígitos.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'E-mail corporativo',
                hintText: 'contato@empresa.com',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe um e-mail corporativo.';
                }

                if (!value.contains('@') || !value.contains('.')) {
                  return 'Digite um e-mail válido.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [BrInputMasks.phoneFormatter],
              decoration: const InputDecoration(
                labelText: 'Telefone comercial',
                hintText: '(11) 99999-0000',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                final digits = BrInputMasks.digitsOnly(value ?? '');

                if (digits.isEmpty) {
                  return 'Informe um telefone para contato.';
                }

                if (!BrInputMasks.hasValidPhoneDigits(value ?? '')) {
                  return 'Use um telefone com DDD.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Senha',
                hintText: 'Crie uma senha de acesso',
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
                  return 'Crie uma senha.';
                }

                if (value.length < 8) {
                  return 'Use ao menos 8 caracteres.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirmar senha',
                hintText: 'Repita a senha criada',
                prefixIcon: const Icon(Icons.lock_person_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme a senha.';
                }

                if (value != _passwordController.text) {
                  return 'As senhas precisam ser iguais.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              checkboxShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                'Aceito os termos e autorizo o contato comercial para ativação da conta.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cadastrar empresa'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Voltar para login'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Já possui conta empresarial? Entre com suas credenciais atuais.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
