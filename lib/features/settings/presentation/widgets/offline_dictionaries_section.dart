import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';

import '../offline_dictionaries_cubit.dart';

const _shortName = {
  Dictionary.belRus: Strings.dictBelRus,
  Dictionary.rusBel: Strings.dictRusBel,
  Dictionary.tsbm: Strings.dictTsbm,
};

class OfflineDictionariesSection extends StatelessWidget {
  const OfflineDictionariesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflineDictionariesCubit, Map<Dictionary, DictionaryOfflineStatus>>(
      builder: (context, state) {
        return Column(
          children: [
            for (final dictionary in Dictionary.values)
              _DictionaryTile(
                dictionary: dictionary,
                status: state[dictionary] ?? const DictionaryNotDownloaded(),
              ),
          ],
        );
      },
    );
  }
}

class _DictionaryTile extends StatelessWidget {
  const _DictionaryTile({required this.dictionary, required this.status});

  final Dictionary dictionary;
  final DictionaryOfflineStatus status;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OfflineDictionariesCubit>();
    final name = _shortName[dictionary]!;

    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return switch (status) {
      DictionaryNotDownloaded() || DictionaryDownloadFailed() => ListTile(
        leading: Icon(AdaptiveIcons.download),
        title: Text(name),
        subtitle: Text(
          status is DictionaryDownloadFailed
              ? Strings.downloadDictionaryError
              : Strings.downloadDictionary,
          style: TextStyle(color: subtitleColor),
        ),
        onTap: () => _startDownload(context, cubit),
      ),
      DictionaryDownloading(:final progress) => ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Strings.downloading, style: TextStyle(color: subtitleColor)),
            LinearProgressIndicator(value: progress.fraction),
            Text(
              '${progress.done} / ${progress.total} ${Strings.wordsUnit}',
              style: TextStyle(color: subtitleColor),
            ),
          ],
        ),
      ),
      DictionaryDownloaded(:final wordCount) => ListTile(
        leading: Icon(AdaptiveIcons.downloadDone),
        title: Text(name),
        subtitle: Text(
          '${Strings.downloaded}: $wordCount ${Strings.wordsUnit}',
          style: TextStyle(color: subtitleColor),
        ),
        trailing: IconButton(
          icon: Icon(AdaptiveIcons.trash, color: Theme.of(context).colorScheme.error),
          onPressed: () => _showDeleteConfirmation(context, cubit),
        ),
      ),
    };
  }

  Future<void> _startDownload(BuildContext context, OfflineDictionariesCubit cubit) async {
    final started = await cubit.download(dictionary);
    if (!started && context.mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text(Strings.downloadRateLimited)));
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, OfflineDictionariesCubit cubit) async {
    final name = _shortName[dictionary]!;
    final result = await showOkCancelAlertDialog(
      context: context,
      title: Strings.attention,
      message: Strings.deleteOfflineDictionaryConfirmation.replaceFirst('{}', name),
      cancelLabel: Strings.no,
      okLabel: Strings.yes,
    );
    if (result == OkCancelResult.ok) {
      await cubit.delete(dictionary);
    }
  }
}
