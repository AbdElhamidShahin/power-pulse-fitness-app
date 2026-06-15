import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/settings/logic/cubit/settings_states.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsInitial());

  Future<void> launchUrl(String url) async {
    emit(const SettingsLaunching());
    try {
      final uri = Uri.parse(url);
      final launched = await launch(uri.toString());
      emit(launched
          ? const SettingsLaunched()
          : const SettingsLaunchError('تعذّر فتح الرابط'));
    } catch (_) {
      emit(const SettingsLaunchError('تعذّر فتح الرابط'));
    }
  }
}
