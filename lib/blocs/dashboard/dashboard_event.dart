import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminDashboard extends DashboardEvent {}

class LoadSalesDashboard extends DashboardEvent {}

class LoadSourcingDashboard extends DashboardEvent {}

class LoadExecutiveDashboard extends DashboardEvent {}
