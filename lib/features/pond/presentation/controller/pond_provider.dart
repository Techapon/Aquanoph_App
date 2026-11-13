import 'package:flutter/foundation.dart';

import 'package:aquanoph/features/pond/data/datasources/pond_remote_datasource.dart';
import 'package:aquanoph/features/pond/data/repositories/pond_repository_impl.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/domain/usecases/create_pond_usecase.dart';
import 'package:aquanoph/features/pond/domain/usecases/get_ponds_usecase.dart';
import 'package:aquanoph/features/pond/domain/usecases/update_pond_usecase.dart';
import 'package:aquanoph/features/recommendation/data/datasources/recommendation_remote_datasource.dart';
import 'package:aquanoph/features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/recommendation/domain/usecases/get_recommendations_usecase.dart';
import 'package:aquanoph/features/severity/data/datasources/severity_remote_datasource.dart';
import 'package:aquanoph/features/severity/data/repositories/severity_repository_impl.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/domain/usecases/get_pond_status_usecase.dart';

class PondProvider extends ChangeNotifier {
  final _repo = PondRepositoryImpl(PondRemoteDatasource());
  final _getStatus = GetPondStatusUsecase(
    SeverityRepositoryImpl(SeverityRemoteDatasource()),
  );
  final _getRecs = GetRecommendationsUsecase(
    RecommendationRepositoryImpl(RecommendationRemoteDatasource()),
  );
  late final _getPonds = GetPondsUsecase(_repo);
  late final _createPond = CreatePondUsecase(_repo);
  late final _updatePond = UpdatePondUsecase(_repo);

  bool isLoading = false;
  String? error;
  List<PondEntity> ponds = [];

  /// Per-pond card data for the list screen (null / empty until loaded).
  /// ponytail: 2 queries per pond (N+1). Fine for a prototype with a handful
  /// of ponds; upgrade when slow -> one view or RPC returning all rows at once.
  Map<String, PondStatusEntity?> statuses = {};
  Map<String, RecommendationEntity?> warnings = {};

  Future<void> load(String userId) => _run(() async {
    ponds = await _getPonds(userId);
    await Future.wait(ponds.map(_loadCards));
  });

  Future<void> _loadCards(PondEntity pond) async {
    final s = _getStatus(pond.id);
    final r = _getRecs(pond.id);
    statuses[pond.id] = await s;
    final recs = await r;
    warnings[pond.id] = recs.isEmpty ? null : recs.first;
  }

  /// RPC derives the owner itself (auth.uid()); userId here is only for reloading the list.
  Future<bool> create(String userId, PondDraft draft) async {
    var ok = false;
    await _run(() async {
      await _createPond(draft);
      await load(userId);
      ok = true;
    });
    return ok;
  }

  Future<bool> update(
    String userId,
    String pondId, {
    String? name,
    int? stockingCount,
    double? avgWeightG,
  }) async {
    var ok = false;
    await _run(() async {
      await _updatePond(
        pondId,
        name: name,
        stockingCount: stockingCount,
        avgWeightG: avgWeightG,
      );
      await load(userId);
      ok = true;
    });
    return ok;
  }

  Future<void> _run(Future<void> Function() op) async {
    error = null;
    isLoading = true;
    notifyListeners();
    try {
      await op();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
