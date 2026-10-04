import 'dart:async';

/// ناقل أحداث بسيط: أي خدمة بتكتب بيانات محلية (وجبات، تمارين، وزن، خطة…)
/// بتنادي [notify]، والشاشات/الـ Cubits اللي بتعرض الداتا دي بتسمع وتحدّث نفسها.
/// كمان الـ cloud sync بيسمع عشان يرفع التعديلات.
abstract class AppDataBus {
  AppDataBus._();

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void notify() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
