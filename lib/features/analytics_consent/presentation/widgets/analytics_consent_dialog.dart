import 'package:flutter/material.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/strings.dart';

import '../analytics_consent_cubit.dart';

/// Uses [AlertDialog] instead of `adaptive_dialog` — this dialog must be
/// truly non-dismissible (no barrier tap, no back gesture) so the user makes
/// an explicit choice, which `showOkCancelAlertDialog` cannot guarantee.
class AnalyticsConsentDialog extends StatelessWidget {
  const AnalyticsConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text(Strings.analyticsConsentTitle),
        content: const Text(Strings.analyticsConsentMessage),
        actions: [
          TextButton(
            onPressed: () => _answer(context, false),
            child: const Text(Strings.analyticsConsentDecline),
          ),
          TextButton(
            onPressed: () => _answer(context, true),
            child: const Text(Strings.analyticsConsentAccept),
          ),
        ],
      ),
    );
  }

  void _answer(BuildContext context, bool granted) {
    getIt<AnalyticsConsentCubit>().setConsent(granted);
    Navigator.of(context).pop();
  }
}
