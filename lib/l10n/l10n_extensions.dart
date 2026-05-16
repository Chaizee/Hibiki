import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../state/locale_controller.dart';
import 'app_strings.dart';

extension L10nContext on BuildContext {
  AppStrings get l10n => watch<LocaleController>().strings;
  AppStrings get l10nRead => read<LocaleController>().strings;
}
