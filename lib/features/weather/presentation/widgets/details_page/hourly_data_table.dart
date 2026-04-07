import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';

class HourlyDataRow {
  final String label;
  final List<String> values;

  const HourlyDataRow({required this.label, required this.values});
}

class HourlyDataTable extends StatefulWidget {
  final List<DateTime> hours;
  final List<HourlyDataRow> rows;

  const HourlyDataTable({
    super.key,
    required this.hours,
    required this.rows,
  });

  @override
  State<HourlyDataTable> createState() => _HourlyDataTableState();
}

class _HourlyDataTableState extends State<HourlyDataTable> {
  final _scrollController = ScrollController();
  final _showLeftFade = ValueNotifier(false);
  final _showRightFade = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showLeftFade.dispose();
    _showRightFade.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    _showLeftFade.value = pos.pixels > 0;
    _showRightFade.value = pos.pixels < pos.maxScrollExtent;
  }

  @override
  Widget build(BuildContext context) {
    final hourFmt = DateFormat('ha');
    final labelStyle = GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.cream.withValues(alpha: 0.7),
    );
    final hourStyle = GoogleFonts.figtree(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.cream.withValues(alpha: 0.9),
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.cream,
    );

    const cellWidth = 42.0;
    const labelWidth = 62.0;
    const rowHeight = 18.0;

    return ListenableBuilder(
      listenable: Listenable.merge([_showLeftFade, _showRightFade]),
      builder: (context, child) => ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              if (_showLeftFade.value) Colors.transparent else Colors.white,
              Colors.white,
              Colors.white,
              if (_showRightFade.value) Colors.transparent else Colors.white,
            ],
            stops: const [0.0, 0.08, 0.92, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: child,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed label column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: rowHeight), // spacer for hour row
                ...widget.rows.map(
                  (r) => SizedBox(
                    width: labelWidth,
                    height: rowHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(r.label, style: labelStyle),
                    ),
                  ),
                ),
              ],
            ),
            // Scrollable data columns
            ...List.generate(widget.hours.length, (i) {
              return Column(
                children: [
                  SizedBox(
                    width: cellWidth,
                    height: rowHeight,
                    child: Center(
                      child: Text(
                        hourFmt.format(widget.hours[i]).toLowerCase(),
                        style: hourStyle,
                      ),
                    ),
                  ),
                  ...widget.rows.map(
                    (r) => SizedBox(
                      width: cellWidth,
                      height: rowHeight,
                      child: Center(
                        child: Text(
                          i < r.values.length ? r.values[i] : '--',
                          style: valueStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
