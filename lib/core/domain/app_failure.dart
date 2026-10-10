import '../error/exceptions.dart';

sealed class AppFailure {
  const AppFailure({required this.message});
  final String message;
}

final class ServerFailure extends AppFailure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure() : super(message: 'تحقق من اتصال الإنترنت');
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.message = 'لم يتم العثور على البيانات'});
}

final class CacheFailure extends AppFailure {
  const CacheFailure({super.message = 'خطأ في التخزين المحلي'});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}

// ─── Extension: رسالة المستخدم ────────────────────────────────────────────
// بديل _mapFailure المكرر في 5 Cubits (exercises ×3، profile ×2، progress ×2، home ×1، nutrition ×3)
extension AppFailureX on AppFailure {
  /// رسالة عربية مناسبة للعرض في الـ UI.
  /// لو الـ Cubit عنده رسالة خاصة (زي "التمرين غير موجود") يستخدم [withOverrides].
  String get userMessage => switch (this) {
        NetworkFailure()    => 'تحقق من اتصال الإنترنت',
        ServerFailure()     => 'خطأ في الخادم، حاول لاحقاً',
        NotFoundFailure()   => message,
        CacheFailure()      => 'خطأ في التخزين المحلي',
        UnexpectedFailure() => 'حدث خطأ غير متوقع',
      };

  /// نفس [userMessage] لكن مع override لأنواع معيّنة.
  String withOverrides(Map<Type, String> overrides) =>
      overrides[runtimeType] ?? userMessage;
}

// ─── mapExceptionToFailure ─────────────────────────────────────────────────
// يدمج منطق failure_mapper.dart القديم — اللي بيستخدمه مش محتاج يعمل import منفصل
AppFailure mapExceptionToFailure(Exception e) => switch (e) {
      NetworkException()   => const NetworkFailure(),
      NotFoundException()  => NotFoundFailure(message: e.message),
      CacheException()     => CacheFailure(message: e.message),
      ServerException()    => ServerFailure(
                                message: e.message,
                                statusCode: e.statusCode,
                              ),
      _                    => UnexpectedFailure(message: e.toString()),
    };

// احتفظنا بـ failureMessage للـ backward compat (لو في كود تاني بيستخدمه)
@Deprecated('استخدم AppFailure.userMessage بدلاً منه')
String failureMessage(AppFailure failure) => failure.userMessage;
