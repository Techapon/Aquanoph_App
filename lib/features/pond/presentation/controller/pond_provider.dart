import 'package:flutter/foundation.dart';

import 'package:aquanoph/features/pond/data/datasources/pond_remote_datasource.dart';
import 'package:aquanoph/features/pond/data/repositories/pond_repository_impl.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/domain/usecases/create_pond_usecase.dart';
import 'package:aquanoph/features/pond/domain/usecases/get_ponds_usecase.dart';
import 'package:aquanoph/features/pond/domain/usecases/update_pond_usecase.dart';

class PondProvider extends ChangeNotifier {
  final _repo = PondRepositoryImpl(PondRemoteDatasource());
  late final _getPonds = GetPondsUsecase(_repo);
  late final _createPond = CreatePondUsecase(_repo);
  late final _updatePond = UpdatePondUsecase(_repo);

  bool isLoading = false;
  String? error;
  List<PondEntity> ponds = [];

  Future<void> load(String userId) => _run(() async => ponds = await _getPonds(userId));

  /// RPC derives the owner itself (auth.uid()); userId here is only for reloading the list.
  Future<bool> create(String userId, PondDraft draft) async {
    var ok = false;
    await _run(() async {
      await _createPond(draft);
      ponds = await _getPonds(userId);
      ok = true;
    });
    return ok;
  }

  Future<bool> update(String userId, String pondId, {String? name, int? stockingCount, double? avgWeightG}) async {
    var ok = false;
    await _run(() async {
      await _updatePond(pondId, name: name, stockingCount: stockingCount, avgWeightG: avgWeightG);
      ponds = await _getPonds(userId);
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
