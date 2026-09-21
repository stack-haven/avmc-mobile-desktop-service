import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:growth_companion/features/growth_dashboard/application/bloc/growth_dashboard_cubit.dart';
import 'package:growth_companion/features/growth_dashboard/domain/entities/growth_dashboard.dart';
import 'package:growth_companion/features/growth_dashboard/domain/repositories/growth_dashboard_repository.dart';
import 'package:growth_companion/features/growth_dashboard/domain/usecases/get_growth_dashboard.dart';
import 'package:growth_companion/features/growth_dashboard/presentation/pages/growth_dashboard_page.dart';

class _MockGrowthDashboardRepository extends Mock implements GrowthDashboardRepository {}

class _FakeGrowthDashboard extends Fake implements GrowthDashboard {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeGrowthDashboard());
  });

  group('GrowthDashboardPage', () {
    late GrowthDashboardRepository repository;

    setUp(() {
      repository = _MockGrowthDashboardRepository();
    });

    Widget buildSubject() {
      return MaterialApp(
        home: RepositoryProvider<GrowthDashboardRepository>.value(
          value: repository,
          child: const GrowthDashboardPage(),
        ),
      );
    }

    testWidgets('renders loaded view on success', (tester) async {
      when(() => repository.getById(any())).thenAnswer(
        (_) async => GrowthDashboard(
          id: 'test-id',
          name: 'Test',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('renders error message on failure', (tester) async {
      when(() => repository.getById(any())).thenThrow(Exception('boom'));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });
}
