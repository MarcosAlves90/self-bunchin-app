import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';

Route<void> buildLoggedOutRoute() {
  return MaterialPageRoute<void>(
    builder: (_) => const LoginPage(),
  );
}

Future<void> logoutFromWorkspace(
  BuildContext context, {
  BunchinApi? api,
}) async {
  try {
    await (api ?? BunchinApi()).logout();
  } on ApiException {
    // O token local ja foi limpo; nao mantenha a sessão ativa por erro remoto.
  } catch (_) {
    // Falhas inesperadas do servidor nao devem bloquear o logout local.
  }

  if (!context.mounted) {
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    buildLoggedOutRoute(),
    (route) => false,
  );
}
