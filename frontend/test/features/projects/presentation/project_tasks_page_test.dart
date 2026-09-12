import 'package:bunchin_flutter/contracts/auth.dart';
import 'package:bunchin_flutter/contracts/employee.dart';
import 'package:bunchin_flutter/contracts/project.dart';
import 'package:bunchin_flutter/contracts/task.dart';
import 'package:bunchin_flutter/core/network/bunchin_api.dart';
import 'package:bunchin_flutter/features/projects/presentation/project_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('manager sees project and task management actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectTasksPage(
          api: _FakeProjectTasksApi(role: 'manager', employeeId: 'emp-02'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Projetos e tarefas'), findsOneWidget);
    expect(find.text('Projeto principal'), findsWidgets);
    expect(find.text('Implementar tela'), findsWidgets);
    expect(find.text('Novo projeto'), findsOneWidget);
    expect(find.text('Nova tarefa'), findsOneWidget);
    expect(find.text('Acesso ao projeto'), findsOneWidget);
    expect(find.text('Adicionar ao projeto'), findsOneWidget);
    expect(find.text('Entrar na tarefa'), findsOneWidget);
    expect(find.text('Adicionar membro'), findsOneWidget);
  });

  testWidgets('employee can access tasks without project editing actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectTasksPage(
          api: _FakeProjectTasksApi(role: 'employee', employeeId: 'emp-04'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Projeto principal'), findsWidgets);
    expect(find.text('Implementar tela'), findsWidgets);
    expect(find.text('Novo projeto'), findsNothing);
    expect(find.text('Nova tarefa'), findsNothing);
    expect(find.text('Adicionar ao projeto'), findsNothing);
    expect(find.text('Entrar na tarefa'), findsOneWidget);
  });

  testWidgets('project and task editors mirror backend text limits',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectTasksPage(
          api: _FakeProjectTasksApi(role: 'manager', employeeId: 'emp-02'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo projeto'));
    await tester.pumpAndSettle();

    final projectNameField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Nome',
      ),
    );
    final projectDescriptionField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Descrição',
      ),
    );
    expect(projectNameField.maxLength, projectNameMaxLength);
    expect(projectDescriptionField.maxLength, projectDescriptionMaxLength);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    final newTaskButton = find.text('Nova tarefa');
    await tester.ensureVisible(newTaskButton);
    await tester.tap(newTaskButton);
    await tester.pumpAndSettle();

    final taskNameField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Nome',
      ),
    );
    final taskDescriptionField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Descrição',
      ),
    );
    expect(taskNameField.maxLength, taskNameMaxLength);
    expect(taskDescriptionField.maxLength, taskDescriptionMaxLength);
  });

  testWidgets('joining a task refreshes membership state', (tester) async {
    final api = _FakeProjectTasksApi(role: 'employee', employeeId: 'emp-04');
    await tester.pumpWidget(MaterialApp(home: ProjectTasksPage(api: api)));
    await tester.pumpAndSettle();

    final joinButton = find.text('Entrar na tarefa');
    await tester.ensureVisible(joinButton);
    await tester.tap(joinButton);
    await tester.pumpAndSettle();

    expect(api.joinCalls, 1);
    expect(find.text('Sair da tarefa'), findsOneWidget);
    expect(find.text('1 de 2 vaga(s) ocupada(s).'), findsOneWidget);
  });
}

class _FakeProjectTasksApi extends BunchinApi {
  _FakeProjectTasksApi({required this.role, required this.employeeId});

  final String role;
  final String? employeeId;
  int joinCalls = 0;
  bool joined = false;

  @override
  Future<AuthContext> getAuthContext() async {
    return AuthContext(
      company: const AuthCompanySummary(
        id: 'company-01',
        legalName: 'Bunchin Tecnologia LTDA',
        tradeName: 'Bunchin',
        cnpjMasked: '12.***.***/****-90',
        emailMasked: 'co*****@bunchin.com',
        phoneMasked: '11*****0000',
      ),
      user: AuthUserSummary(
        id: 'user-01',
        email: 'usuario@bunchin.com',
        role: role,
        employeeId: employeeId,
      ),
    );
  }

  @override
  Future<List<ProjectSummary>> listProjects({ProjectStatus? status}) async {
    return <ProjectSummary>[
      ProjectSummary(
        id: 'project-01',
        name: 'Projeto principal',
        description: 'Descrição do projeto',
        taskEmployeeLimit: 2,
        status: ProjectStatus.active,
        createdAt: DateTime(2026, 9, 9),
        updatedAt: DateTime(2026, 9, 9),
      ),
    ];
  }

  @override
  Future<List<ProjectMemberSummary>> listProjectMembers(String projectId) async {
    if (employeeId == null) {
      return <ProjectMemberSummary>[];
    }
    return <ProjectMemberSummary>[
      ProjectMemberSummary(
        employeeId: employeeId!,
        projectId: projectId,
        employeeName: role == 'manager' ? 'Caio Martins' : 'João Lima',
        createdAt: DateTime(2026, 9, 9),
      ),
      ProjectMemberSummary(
        employeeId: 'emp-05',
        projectId: projectId,
        employeeName: 'Ana Lima',
        createdAt: DateTime(2026, 9, 9),
      ),
    ];
  }

  @override
  Future<List<TaskRecord>> listTasks(String projectId) async {
    return <TaskRecord>[
      TaskRecord(
        id: 'task-01',
        projectId: projectId,
        parentTaskId: null,
        name: 'Implementar tela',
        description: 'Descrição da tarefa',
        type: TaskType.feature,
        createdAt: DateTime(2026, 9, 9),
        updatedAt: DateTime(2026, 9, 9),
      ),
    ];
  }

  @override
  Future<List<TaskMemberSummary>> listTaskMembers(
    String projectId,
    String taskId,
  ) async {
    if (!joined || employeeId == null) {
      return <TaskMemberSummary>[];
    }
    return <TaskMemberSummary>[
      TaskMemberSummary(
        employeeId: employeeId!,
        taskId: taskId,
        employeeName: 'João Lima',
        createdAt: DateTime(2026, 9, 9),
      ),
    ];
  }

  @override
  Future<List<EmployeeProfile>> listEmployees() async => <EmployeeProfile>[];

  @override
  Future<TaskMemberSummary> joinTask(String projectId, String taskId) async {
    joinCalls += 1;
    joined = true;
    return TaskMemberSummary(
      employeeId: employeeId!,
      taskId: taskId,
      employeeName: 'João Lima',
      createdAt: DateTime(2026, 9, 9),
    );
  }
}
