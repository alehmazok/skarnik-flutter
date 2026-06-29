import 'package:flutter/material.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_row.dart';

import 'stress_html_cell.dart';

class StressTable extends StatelessWidget {
  final List<StressRow> rows;

  const StressTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: dividerColor),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: StressHtmlCell(html: rows[index].title)),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: dividerColor)),
              ),
              child: StressHtmlCell(html: rows[index].content),
            ),
          ),
        ],
      ),
    );
  }
}
