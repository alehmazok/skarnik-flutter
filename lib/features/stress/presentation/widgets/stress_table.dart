import 'package:flutter/material.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_row.dart';

import 'stress_html_cell.dart';

class StressTable extends StatelessWidget {
  final List<StressRow> rows;

  const StressTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    return SingleChildScrollView(
      primary: true,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
        border: TableBorder(
          bottom: BorderSide(
            color: dividerColor,
          ),
          top: BorderSide(
            color: dividerColor,
          ),
          horizontalInside: BorderSide(
            color: dividerColor,
          ),
          verticalInside: BorderSide(
            color: dividerColor,
          ),
        ),
        children: rows
            .map(
              (row) => TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: StressHtmlCell(html: row.title),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: StressHtmlCell(html: row.content),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
