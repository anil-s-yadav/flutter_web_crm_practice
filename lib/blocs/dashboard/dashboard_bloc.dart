import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/repositories/analytics_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AnalyticsRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<LoadSalesDashboard>(_onLoadSalesDashboard);
    on<LoadSourcingDashboard>(_onLoadSourcingDashboard);
    on<LoadExecutiveDashboard>(_onLoadExecutiveDashboard);
  }

  void _onLoadAdminDashboard(LoadAdminDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getAdminAnalytics();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLoadSalesDashboard(LoadSalesDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getSalesAnalytics();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLoadSourcingDashboard(LoadSourcingDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getSourcingAnalytics();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLoadExecutiveDashboard(LoadExecutiveDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getExecutiveAnalytics();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
