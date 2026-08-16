import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/cloud_sync_service.dart';
import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../models/workout_plan_entity.dart';
import '../services/workout_plan_service.dart';

abstract interface class WorkoutPlanRepository {
  Future<ApiResult<WorkoutPlan?>> getPlan();
  Future<ApiResult<void>> savePlan(WorkoutPlan plan);
  Future<ApiResult<void>> deletePlan();
}

final class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  WorkoutPlanRepositoryImpl(
    this._service,
    this._prefs,
    this._auth,
    this._firestore,
  );

  final WorkoutPlanService _service;
  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<ApiResult<WorkoutPlan?>> getPlan() async {
    try {
      return Success(await _service.getPlan());
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> savePlan(WorkoutPlan plan) async {
    try {
      await _service.savePlan(plan);

      // ─── Cloud sync ────────────────────────────────────────────────────────
      CloudSyncService.syncKey(_prefs, _auth, _firestore, 'workout_plan');

      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deletePlan() async {
    try {
      await _service.deletePlan();

      // After deleting locally, update cloud to reflect the deletion.
      // syncKey will find the key absent and no-op safely, so we explicitly
      // remove the field from Firestore by setting it to null via merge.
      _syncDeletedPlan();

      return const Success(null);
    } on CacheException catch (e) {
      return Failure(CacheFailure(message: e.message));
    } catch (e) {
      return Failure(UnexpectedFailure(message: e.toString()));
    }
  }

  void _syncDeletedPlan() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestore
        .collection('users')
        .doc(uid)
        .collection('data')
        .doc('local_cache')
        .set({'workout_plan': null}, SetOptions(merge: true))
        .catchError((_) {});
  }
}
