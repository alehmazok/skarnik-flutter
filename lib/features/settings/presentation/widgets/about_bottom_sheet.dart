import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings_cubit.dart';

class AboutBottomSheet extends StatefulWidget {
  const AboutBottomSheet({super.key});

  @override
  State<AboutBottomSheet> createState() => _AboutBottomSheetState();
}

class _AboutBottomSheetState extends State<AboutBottomSheet> {
  final TapGestureRecognizer _skarnikLinkRecognizer = TapGestureRecognizer()
    ..onTap = () => launchUrl(
      Uri(scheme: 'https', host: AppConfig.skarnikSiteHostName),
      mode: LaunchMode.externalApplication,
    );
  late final Future<String> _appNameAndVersion;

  @override
  void initState() {
    super.initState();
    _appNameAndVersion = context.read<SettingsCubit>().getAppNameAndVersion();
  }

  @override
  void dispose() {
    _skarnikLinkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              Strings.aboutSkarnik,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Гэтая праграма — ${Platform.isIOS ? 'iOS' : 'Android'}-кліент сайта ',
                      ),
                      TextSpan(
                        text: AppConfig.skarnikSiteHostName,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).colorScheme.primary,
                          decorationColor: Theme.of(context).colorScheme.primary,
                        ),
                        recognizer: _skarnikLinkRecognizer,
                      ),
                      const TextSpan(
                        text: '. Працуе ў рэжыме анлайн.',
                      ),
                    ],
                  ),
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: '\n\n1. ',
                      ),
                      TextSpan(
                        text: 'Тлумачальны',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' слоўнік беларускай мовы змяшчае больш за 95 тысяч слоў. Створаны на аснове акадэмічнага выдання пад рэдакцыяй К. Крапівы — пяцітомніка 1977-1984 гг.',
                      ),
                    ],
                  ),
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: '\n2. ',
                      ),
                      TextSpan(
                        text: 'Беларуска-рускі',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' слоўнік змяшчае больш за 100 тысяч слоў. Гэта «адваротны» слоўнік ад руска-беларускага.',
                      ),
                    ],
                  ),
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: '\n3. ',
                      ),
                      TextSpan(
                        text: 'Руска-беларускі',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' слоўнік таксама змяшчае больш за 100 тысяч слоў. За аснову ўзяты акадэмічны слоўнік пад рэдакцыяй Я. Коласа, К. Крапівы і П. Глебкі.',
                      ),
                    ],
                  ),
                  const TextSpan(
                    text: '\n\nСайт skarnik.by пачаў працаваць 7 жніўня 2012 года.',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              Strings.aboutUsefulLinks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.link_outlined),
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              AppConfig.starnikSiteHostName,
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
            subtitle: const Text(Strings.aboutStarnikByDescription),
            onTap: () => launchUrl(
              Uri(scheme: 'https', host: AppConfig.starnikSiteHostName),
              mode: LaunchMode.externalApplication,
            ),
          ),
          ListTile(
            leading: Icon(AdaptiveIcons.link),
            titleTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              AppConfig.drukarnikSiteHostName,
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
            subtitle: const Text(Strings.aboutDrukarnikDescription),
            onTap: () => launchUrl(
              Uri(scheme: 'https', host: AppConfig.drukarnikSiteHostName),
              mode: LaunchMode.externalApplication,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextButton.icon(
              icon: Icon(AdaptiveIcons.email),
              onPressed: context.read<SettingsCubit>().mailToDevs,
              label: const Text(Strings.writeToDevs),
            ),
          ),
          FutureBuilder<String>(
            future: _appNameAndVersion,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data;
                if (data != null) {
                  return ListTile(
                    subtitle: Text(
                      data,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
