import 'package:flutter/foundation.dart';

import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:aquanoph/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/activity/domain/repositories/activity_repository.dart';

/// One-shot fetch per pond-local day (realtime = future).
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repo;
  ActivityProvider({ActivityRepository? repo})
      : _repo = repo ?? ActivityRepositoryImpl(ActivityRemoteDatasource());

  bool isLoading = false;
  String? error;
  bool busy = false;
  List<ActivityEntity> activities = [];
  String? pondId;
  String? timezone;

  Future<void> load(String pondId, String timezone) async {
    this.pondId = pondId;
    this.timezone = timezone;
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      final day = pondDayUtc(DateTime.now().toUtc(), timezone);
      activities = await _repo.getDay(pondId, day.from, day.to);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveChecklist(List<Map<String, dynamic>> changes) async {
    if (busy || pondId == null) return false;
    busy = true;
    notifyListeners();
    try {
      await _repo.saveChecklist(pondId!, changes);
      await load(pondId!, timezone!);
      busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      busy = false;
      notifyListeners();
      return false;
    }
  }

  /// Read-only fetch of one pond-local day (no state change) — for
  /// pre-flight conflict checks before apply-to-other-day upserts.
  Future<List<ActivityEntity>> fetchDay(
    String pondId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      return await _repo.getDay(pondId, from, to);
    } catch (e) {
      error = e.toString();
      return [];
    }
  }

  Future<String?> upsert(Map<String, dynamic> activity) async {
    if (busy || pondId == null) return null;
    busy = true;
    notifyListeners();
    try {
      final id = await _repo.upsertActivity(pondId!, activity);
      await load(pondId!, timezone!);
      busy = false;
      notifyListeners();
      return id;
    } catch (e) {
      error = e.toString();
      busy = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> delete(String activityId) async {
    if (busy) return false;
    busy = true;
    notifyListeners();
    try {
      await _repo.deleteActivity(activityId);
      await load(pondId!, timezone!);
      busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      busy = false;
      notifyListeners();
      return false;
    }
  }
}
