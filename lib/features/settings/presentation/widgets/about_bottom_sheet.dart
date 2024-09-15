import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../settings_cubit.dart';

class AboutBottomSheet extends StatelessWidget {
  const AboutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Гэтая праграма — ${Platform.isIOS ? 'iOS' : 'Android'}-кліент сайта ',
                  ),
                  TextSpan(
                    text: 'Skarnik.by',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary,
                      decorationColor: Theme.of(context).colorScheme.primary,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () => launchUrlString('https://skarnik.by'),
                  ),
                  const TextSpan(
                    text: '. Працуе ў рэжыме анлайн.',
                  ),
                ],
              ),
              const TextSpan(
                children: [
                  TextSpan(
                    text: '\n\n\t\t\t1. ',
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
                    text: '\n\t\t\t2. ',
                  ),
                  TextSpan(
                    text: 'Беларуска-рускі',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' слоўнік змяшчае больш за 100 тысяч слоў. Гэта «адваротны» слоўнік ад руска-беларускага.',
                  ),
                ],
              ),
              const TextSpan(
                children: [
                  TextSpan(
                    text: '\n\t\t\t3. ',
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
                text:
                    '\n\n\t\t\tСкарнік дапрацаваны з улікам сучаснай практыкі і ўвесь час абнаўляецца (дадаюцца новыя словы, выпраўляюцца памылкі, недакладнасці і г. д.). Дзякуем усім за водгукі і прапановы.',
              ),
              WidgetSpan(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: TextButton(
                      onPressed: context.read<SettingsCubit>().mailToDevs,
                      child: const Text(Strings.writeToDevs),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
