import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/cloud_sync_service.dart';
import '../../../../core/domain/api_result.dart';
import '../../../../core/domain/app_failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../nutrition/data/services/nutrition_local_service.dart';
import '../models/user_profile_entity.dart';
import '../services/profile_local_service.dart';

abstract interface class ProfileRepository {
  Future<ApiResult<UserProfile>> getProfile();

  Future<ApiResult<void>> saveProfile(UserProfile profile);

  Future<ApiResult<bool>> hasProfile();
}

final class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.localService,
    required this.nutritionService,
    required this.prefs,
    required this.auth,
    required this.firestore,
  });

  final ProfileLocalService localService;
final NutritionLocalService nutritionService;
  final SharedPreferences prefs;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  @override
  Future<ApiResult<UserProfile>> getProfile() async {
    try {
      final profile = await localService.getProfile();

      return Success(
        profile ?? kDefaultProfile,
      );
    } on CacheException catch (e) {
      return Failure(
        CacheFailure(message: e.message),
      );
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResult<void>> saveProfile(UserProfile profile) async {
    try {
      await localService.saveProfile(profile);

   nutritionService.saveCalorieGoal(profile.dailyCalorieGoal).catchError((_) {});

      CloudSyncService.syncKey(prefs, auth, firestore, 'user_profile');

      return const Success(null);
    } on CacheException catch (e) {
      return Failure(
        CacheFailure(message: e.message),
      );
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResult<bool>> hasProfile() async {
    try {
      final hasProfile = await localService.hasProfile();

      return Success(hasProfile);
    } catch (e) {
      return Failure(
        UnexpectedFailure(message: e.toString()),
      );
    }
  }
}
