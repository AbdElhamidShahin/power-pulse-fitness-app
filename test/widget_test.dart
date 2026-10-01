import 'package:flutter_test/flutter_test.dart';
import 'package:power_pulse/core/domain/app_failure.dart';
import 'package:power_pulse/core/error/exceptions.dart';

void main() {
  // ─── AppFailureX.userMessage ────────────────────────────────
  group('AppFailure.userMessage', () {
    test('NetworkFailure returns connectivity message', () {
      const f = NetworkFailure();
      expect(f.userMessage, 'تحقق من اتصال الإنترنت');
    });

    test('ServerFailure returns server message', () {
      const f = ServerFailure(message: 'Internal Server Error');
      expect(f.userMessage, 'خطأ في الخادم، حاول لاحقاً');
    });

    test('NotFoundFailure returns its own message', () {
      const f = NotFoundFailure(message: 'التمرين غير موجود');
      expect(f.userMessage, 'التمرين غير موجود');
    });

    test('CacheFailure returns storage message', () {
      const f = CacheFailure();
      expect(f.userMessage, 'خطأ في التخزين المحلي');
    });

    test('UnexpectedFailure returns unexpected message', () {
      const f = UnexpectedFailure();
      expect(f.userMessage, 'حدث خطأ غير متوقع');
    });
  });

  // ─── AppFailureX.withOverrides ──────────────────────────────
  group('AppFailure.withOverrides', () {
    test('returns override when type matches', () {
      const f = NotFoundFailure(message: 'default');
      final msg = f.withOverrides({NotFoundFailure: 'التمرين غير موجود'});
      expect(msg, 'التمرين غير موجود');
    });

    test('falls back to userMessage when type not in overrides', () {
      const f = NetworkFailure();
      final msg = f.withOverrides({NotFoundFailure: 'override'});
      expect(msg, 'تحقق من اتصال الإنترنت');
    });
  });

  // ─── mapExceptionToFailure ──────────────────────────────────
  group('mapExceptionToFailure', () {
    test('NetworkException → NetworkFailure', () {
      final f = mapExceptionToFailure(const NetworkException());
      expect(f, isA<NetworkFailure>());
    });

    test('NotFoundException → NotFoundFailure with message', () {
      final f = mapExceptionToFailure(const NotFoundException(message: 'not found'));
      expect(f, isA<NotFoundFailure>());
      expect(f.message, 'not found');
    });

    test('ServerException → ServerFailure with statusCode', () {
      final f = mapExceptionToFailure(
          const ServerException(message: 'error', statusCode: 500));
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, 500);
    });

    test('CacheException → CacheFailure', () {
      final f = mapExceptionToFailure(const CacheException(message: 'disk full'));
      expect(f, isA<CacheFailure>());
    });

    test('Unknown exception → UnexpectedFailure', () {
      final f = mapExceptionToFailure(Exception('something weird'));
      expect(f, isA<UnexpectedFailure>());
    });
  });
}
