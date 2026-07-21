import 'package:flutter/material.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';

/// Renders [list] alone below [Breakpoints.masterDetail] width (phone behavior,
/// unchanged). Above it, renders [list] and [detail] side by side.
class MasterDetailView extends StatelessWidget {
  final Widget list;
  final Widget? detail;

  const MasterDetailView({
    super.key,
    required this.list,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.masterDetail;
    if (!isWide) return list;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 360, child: list),
        const VerticalDivider(width: 1),
        Expanded(
          child:
              detail ??
              const Center(
                child: Text(Strings.selectWordPrompt),
              ),
        ),
      ],
    );
  }
}
