import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/word_of_the_day.dart';

/// Must match the Kotlin `WordOfDayWidgetReceiver`'s fully-qualified class
/// name exactly — `androidName` alone assumes the class sits directly under
/// the app's runtime package (which gets a `.debug` suffix in debug builds),
/// but ours lives in a `.widget` sub-package, so `qualifiedAndroidName` (used
/// as-is, no prefixing) is required instead.
const wordOfDayAndroidWidgetName = 'by.mazokaleh.skarnik.widget.WordOfDayWidgetReceiver';

/// Thin wrapper around `home_widget`'s Dart API, keeping the plugin out of
/// the domain layer (same pattern as `SkarnikDio` wrapping `dio`).
@injectable
class HomeWidgetGateway {
  Future<void> save(WordOfTheDay data) async {
    await HomeWidget.saveWidgetData<String>('word', data.word);
    await HomeWidget.saveWidgetData<String>('translation', data.translation);
    await HomeWidget.saveWidgetData<String>('wordId', data.wordId.toString());
    await HomeWidget.updateWidget(qualifiedAndroidName: wordOfDayAndroidWidgetName);
  }
}
