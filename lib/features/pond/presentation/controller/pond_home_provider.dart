import 'package:flutter/foundation.dart';

import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:aquanoph/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/activity/domain/usecases/get_activities_usecase.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/recommendation/data/datasources/recommendation_remote_datasource.dart';
import 'package:aquanoph/features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/recommendation/domain/usecases/get_recommendations_usecase.dart';
import 'package:aquanoph/features/severity/data/datasources/severity_remote_datasource.dart';
import 'package:aquanoph/features/severity/data/repositories/severity_repository_impl.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';
import 'package:aquanoph/features/severity/domain/usecases/get_parameter_reports_usecase.dart';
import 'package:aquanoph/features/severity/domain/usecases/get_pond_status_usecase.dart';

/// Pond home screen state: severity status + open recommendations + today's activities.
/// Loads once on push; pull-to-refresh re-calls load(). Realtime = step 4.
class PondHomeProvider extends ChangeNotifier {
  final _getStatus = GetPondStatusUsecase(SeverityRepositoryImpl(SeverityRemoteDatasource()));
  final _getParams = GetParameterReportsUsecase(SeverityRepositoryImpl(SeverityRemoteDatasource()));
  final _getRecs = GetRecommendationsUsecase(RecommendationRepositoryImpl(RecommendationRemoteDatasource()));
  final _getActs = GetActivitiesUsecase(ActivityRepositoryImpl(ActivityRemoteDatasource()));

  bool isLoading = false;
  String? error;
  PondStatusEntity? status;
  List<SeverityReportEntity> parameters = [];
  List<RecommendationEntity> recommendations = [];
  List<ActivityEntity> activities = [];

  Future<void> load(PondEntity pond) async {
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      final day = pondDayUtc(DateTime.now().toUtc(), pond.timezone);
      final s = _getStatus(pond.id);
      final pr = _getParams(pond.id);
      final r = _getRecs(pond.id);
      final a = _getActs(pond.id, day.from, day.to);
      status = await s;
      parameters = await pr;
      recommendations = await r;
      activities = await a;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  List<ActivityEntity> of(ActivityType type) => activities.where((a) => a.type == type).toList();
}
