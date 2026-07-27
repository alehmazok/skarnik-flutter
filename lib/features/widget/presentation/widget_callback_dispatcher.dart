import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:workmanager/workmanager.dart';

import '../data/service/home_widget_gateway.dart';
import '../data/service/widget_bootstrap.dart';
import '../domain/use_case/refresh_widget_data.dart';

const wordOfDayTaskName = 'wordOfDayRefreshTask';

final _logger = Logger('widgetCallbackDispatcher');

@pragma('vm:entry-point')
void widgetCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await ensureWidgetBootstrap();
      final wordOfTheDay = await getIt<RefreshWidgetDataUseCase>().call();
      await getIt<HomeWidgetGateway>().save(wordOfTheDay);
      _logger.info('Віджэт "Слова дня" абноўлены: ${wordOfTheDay.word}.');
    } catch (e, st) {
      _logger.severe('Не атрымалася абнавіць віджэт "Слова дня".', e, st);
    }
    return Future.value(true);
  });
}
