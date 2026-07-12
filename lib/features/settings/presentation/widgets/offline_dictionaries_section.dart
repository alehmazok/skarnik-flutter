import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/strings.dart';

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

    return switch (status) {
      DictionaryNotDownloaded() || DictionaryDownloadFailed() => ListTile(
        leading: const Icon(Icons.download_outlined),
        title: Text(name),
        subtitle: status is DictionaryDownloadFailed
            ? const Text(Strings.downloadDictionaryError)
            : const Text(Strings.downloadDictionary),
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
            const Text(Strings.downloading),
            LinearProgressIndicator(value: progress.fraction),
            Text('${progress.done} / ${progress.total} ${Strings.wordsUnit}'),
          ],
        ),
      ),
      DictionaryDownloaded(:final wordCount) => ListTile(
        leading: const Icon(Icons.download_done_outlined),
        title: Text(name),
        subtitle: Text('${Strings.downloaded}: $wordCount ${Strings.wordsUnit}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
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
