import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:growth_companion/features/growth_dashboard/application/bloc/growth_dashboard_cubit.dart';
import 'package:growth_companion/features/growth_dashboard/domain/entities/growth_dashboard.dart';
import 'package:growth_companion/features/growth_dashboard/domain/repositories/growth_dashboard_repository.dart';
import 'package:growth_companion/features/growth_dashboard/domain/usecases/get_growth_dashboard.dart';

class _MockGrowthDashboardRepository extends Mock implements GrowthDashboardRepository {}

class _FakeGrowthDashboard extends Fake implements GrowthDashboard {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeGrowthDashboard());
  });

  group('GrowthDashboardCubit', () {
    late GrowthDashboardRepository repository;

    setUp(() {
      repository = _MockGrowthDashboardRepository();
    });

    blocTest<GrowthDashboardCubit, GrowthDashboardState>(
      'emits [loading, loaded] when load succeeds',
      build: () => GrowthDashboardCubit(getGrowthDashboard: GetGrowthDashboard(repository)),
      setUp: () {
        when(() => repository.getById(any())).thenAnswer(
          (_) async => GrowthDashboard(
            id: 'test-id',
            name: 'Test',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<GrowthDashboardLoading>(),
        isA<GrowthDashboardLoaded>(),
      ],
    );

    blocTest<GrowthDashboardCubit, GrowthDashboardState>(
      'emits [loading, error] when load fails',
      build: () => GrowthDashboardCubit(getGrowthDashboard: GetGrowthDashboard(repository)),
      setUp: () {
        when(() => repository.getById(any())).thenThrow(Exception('boom'));
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<GrowthDashboardLoading>(),
        isA<GrowthDashboardError>(),
      ],
    );
  });
}
