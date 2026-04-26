import 'package:bunchin_flutter/core/network/api_client.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/core/storage/token_storage.dart';
import 'package:bunchin_flutter/features/auth/presentation/login_page.dart';
import 'package:bunchin_flutter/features/auth/presentation/logout_navigation.dart';
import 'package:bunchin_flutter/features/shared/presentation/widgets/workspace_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'logout action clears the session and returns to login',
    (tester) async {
      final client = _FakeLogoutApiClient(
        postError: ApiException(
          'Falha ao encerrar sessao no servidor.',
          statusCode: 500,
        ),
      );
      final tokenStorage = _InMemoryTokenStorage()..savedToken = 'token-123';
      final api = BunchinApi(client: client, tokenStorage: tokenStorage);

      await tester.pumpWidget(
        MaterialApp(
          home: WorkspaceScaffold(
            sidebar: const SizedBox(height: 32),
            contentBuilder: (_, __) => const SizedBox.shrink(),
            onLogoutRequested: (context) => logoutFromWorkspace(
              context,
              api: api,
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair do Sistema'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(client.lastPath, '/auth/logout');
      expect(client.lastWithAuth, isTrue);
      expect(tokenStorage.clearCalled, isTrue);
      expect(tokenStorage.savedToken, isNull);
    },
  );
}

class _FakeLogoutApiClient extends ApiClient {
  _FakeLogoutApiClient({this.postError});

  final Object? postError;
  String? lastPath;
  bool? lastWithAuth;

  @override
  Future<dynamic> post(
    String path, {
    Object? body,
    bool withAuth = false,
  }) async {
    lastPath = path;
    lastWithAuth = withAuth;
    if (postError != null) {
      throw postError!;
    }
    return null;
  }
}

class _InMemoryTokenStorage extends TokenStorage {
  String? savedToken;
  bool clearCalled = false;

  @override
  Future<void> saveAccessToken(String token) async {
    savedToken = token;
  }

  @override
  Future<String?> readAccessToken() async {
    return savedToken;
  }

  @override
  Future<void> clearAccessToken() async {
    clearCalled = true;
    savedToken = null;
  }
}
