import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:folly_fields/widgets/folly_divider.dart';
import 'package:intl/intl.dart';

///
///
///
class FollyTable extends StatefulWidget {
  final int rowsCount;
  final List<double> columnsSize;
  final List<FollyCell> headerColumns;
  final double headerHeight;
  final FollyCell Function(int row, int column) cellBuilder;
  final double rowHeight;
  final void Function(int row)? onRowTap;
  final double dividerHeight;
  final double scrollBarThickness;
  final int scrollTimeout; // FIXME - Fix it!
  final bool verticalScrollAlwaysVisible;
  final bool horizontalScrollAlwaysVisible;
  final int freezeColumns;
  final Set<PointerDeviceKind>? dragDevices;

  ///
  ///
  ///
  const FollyTable({
    required this.rowsCount,
    required this.columnsSize,
    required this.cellBuilder,
    this.headerColumns = const <FollyCell>[],
    this.headerHeight = 16.0,
    this.rowHeight = 16.0,
    this.onRowTap,
    this.dividerHeight = 1.0,
    this.scrollBarThickness = 8.0,
    this.scrollTimeout = 300,
    this.verticalScrollAlwaysVisible = true,
    this.horizontalScrollAlwaysVisible = true,
    this.freezeColumns = 0,
    this.dragDevices,
    super.key,
  });

  ///
  ///
  ///
  @override
  FollyTableState createState() => FollyTableState();
}

///
///
///
class FollyTableState extends State<FollyTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _internalController = ScrollController();
  final ScrollController _freezeController = ScrollController();

  int lastCall = 0;
  String caller = '';

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();

    _verticalController.addListener(() {
      if (caller.isEmpty ||
          DateTime.now().millisecondsSinceEpoch - lastCall >
              widget.scrollTimeout) {
        caller = 'vertical';
      }
      lastCall = DateTime.now().millisecondsSinceEpoch;

      if (caller == 'vertical') {
        _internalController.jumpTo(_verticalController.offset);
        if (widget.freezeColumns > 0) {
          _freezeController.jumpTo(_verticalController.offset);
        }
      }
    });

    _internalController.addListener(() {
      if (caller.isEmpty ||
          DateTime.now().millisecondsSinceEpoch - lastCall >
              widget.scrollTimeout) {
        caller = 'internal';
      }
      lastCall = DateTime.now().millisecondsSinceEpoch;

      if (caller == 'internal') {
        _verticalController.jumpTo(_internalController.offset);
        if (widget.freezeColumns > 0) {
          _freezeController.jumpTo(_internalController.offset);
        }
      }
    });

    if (widget.freezeColumns > 0) {
      _freezeController.addListener(() {
        if (caller.isEmpty ||
            DateTime.now().millisecondsSinceEpoch - lastCall >
                widget.scrollTimeout) {
          caller = 'freeze';
        }
        lastCall = DateTime.now().millisecondsSinceEpoch;

        if (caller == 'freeze') {
          _verticalController.jumpTo(_freezeController.offset);
          _internalController.jumpTo(_freezeController.offset);
        }
      });
    }
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /// Frozen Content
        if (widget.freezeColumns > 0)
          _drawColumns(
            0,
            widget.freezeColumns,
            _freezeController,
          ),

        /// Table Content
        Flexible(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              dragDevices: widget.dragDevices,
            ),
            child: Scrollbar(
              controller: _horizontalController,
              // isAlwaysShown: widget.horizontalScrollAlwaysVisible,
              thumbVisibility: widget.horizontalScrollAlwaysVisible,
              thickness: widget.scrollBarThickness,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: _drawColumns(
                  widget.freezeColumns,
                  widget.columnsSize.length,
                  _internalController,
                ),
              ),
            ),
          ),
        ),

        /// Vertical Scrollbar
        Column(
          children: <Widget>[
            SizedBox(
              width: widget.scrollBarThickness,
              height: widget.headerHeight + widget.dividerHeight + 4.0,
            ),
            Expanded(
              child: Scrollbar(
                controller: _verticalController,
                // isAlwaysShown: widget.verticalScrollAlwaysVisible,
                thumbVisibility: widget.verticalScrollAlwaysVisible,
                thickness: widget.scrollBarThickness,
                child: SingleChildScrollView(
                  controller: _verticalController,
                  child: SizedBox(
                    width: widget.scrollBarThickness,
                    height: (widget.rowHeight + widget.dividerHeight + 4.0) *
                        widget.rowsCount,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///
  ///
  ///
  Column _drawColumns(
    int start,
    int end,
    ScrollController scrollController,
  ) {
    List<int> cols = List<int>.generate(
      end - start,
      (int index) => start + index,
    );

    double width = cols.fold(
      0,
      (double p, int i) => p + widget.columnsSize[i] + 4,
    );

    return Column(
      children: <Widget>[
        Row(
          children: cols
              .map(
                (int col) => _buildCell(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
                  cell: widget.headerColumns[col],
                  width: widget.columnsSize[col],
                  height: widget.headerHeight,
                ),
              )
              .toList(),
        ),
        SizedBox(
          width: width,
          child: FollyDivider(
            height: widget.dividerHeight,
          ),
        ),
        Expanded(
          child: SizedBox(
            width: width,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                scrollbars: false,
                dragDevices: widget.dragDevices,
              ),
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.rowsCount,
                itemBuilder: (BuildContext context, int row) {
                  return Column(
                    children: <Widget>[
                      InkWell(
                        onTap: widget.onRowTap == null
                            ? null
                            : () => widget.onRowTap!(row),
                        hoverColor: Colors.transparent,
                        child: Row(
                          children: cols
                              .map(
                                (int col) => _buildCell(
                                  cell: widget.cellBuilder(row, col),
                                  width: widget.columnsSize[col],
                                  height: widget.rowHeight,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      FollyDivider(
                        height: widget.dividerHeight,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///
  ///
  ///
  Widget _buildCell({
    required FollyCell cell,
    required double width,
    required double height,
    EdgeInsetsGeometry padding = const EdgeInsets.all(2),
  }) =>
      Container(
        color: cell.color,
        padding: padding,
        child: SizedBox(
          width: width,
          height: height,
          child: cell,
        ),
      );

  ///
  ///
  ///
  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _internalController.dispose();
    super.dispose();
  }
}

///
///
///
class FollyCell extends StatelessWidget {
  final AlignmentGeometry align;
  final Color color;
  final Widget child;

  ///
  ///
  ///
  const FollyCell({
    required this.child,
    this.align = Alignment.centerLeft,
    this.color = Colors.transparent,
    super.key,
  });

  ///
  ///
  ///
  FollyCell.empty({
    this.color = Colors.transparent,
    super.key,
  })  : align = Alignment.centerLeft,
        child = Container();

  ///
  ///
  ///
  FollyCell.textHeader(
    String text, {
    this.align = Alignment.bottomLeft,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.start,
    TextStyle style = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                text,
                textAlign: textAlign,
                style: style,
              )
            : Text(
                text,
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.textHeaderCenter(
    String text, {
    this.color = Colors.transparent,
    TextStyle style = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    bool selectable = false,
    super.key,
  })  : align = Alignment.bottomCenter,
        child = selectable
            ? SelectableText(
                text,
                textAlign: TextAlign.center,
                style: style,
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.text(
    String text, {
    this.align = Alignment.centerLeft,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                text,
                textAlign: textAlign,
                style: style,
              )
            : Text(
                text,
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.center(
    String text, {
    this.color = Colors.transparent,
    TextStyle? style,
    bool selectable = false,
    super.key,
  })  : align = Alignment.center,
        child = selectable
            ? SelectableText(
                text,
                textAlign: TextAlign.center,
                style: style,
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.number(
    num number, {
    this.align = Alignment.centerRight,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.end,
    TextStyle? style,
    String locale = 'pt_br',
    String pattern = '#,##0.00',
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                NumberFormat(pattern, locale).format(number),
                textAlign: textAlign,
                style: style,
              )
            : Text(
                NumberFormat(pattern, locale).format(number),
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.integer(
    num number, {
    this.align = Alignment.centerRight,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.end,
    TextStyle? style,
    String locale = 'pt_br',
    String pattern = '#,##0',
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                NumberFormat(pattern, locale).format(number),
                textAlign: textAlign,
                style: style,
              )
            : Text(
                NumberFormat(pattern, locale).format(number),
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.date(
    DateTime date, {
    this.align = Alignment.center,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.center,
    TextStyle? style,
    String locale = 'pt_br',
    String pattern = 'dd/MM/yyyy',
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              )
            : Text(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.time(
    DateTime date, {
    this.align = Alignment.center,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.center,
    TextStyle? style,
    String locale = 'pt_br',
    String pattern = 'HH:mm',
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              )
            : Text(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.dateTime(
    DateTime date, {
    this.align = Alignment.center,
    this.color = Colors.transparent,
    TextAlign textAlign = TextAlign.center,
    TextStyle? style,
    String locale = 'pt_br',
    String pattern = 'dd/MM/yyyy HH:mm',
    bool selectable = false,
    super.key,
  })  : child = selectable
            ? SelectableText(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              )
            : Text(
                DateFormat(pattern, locale).format(date),
                textAlign: textAlign,
                style: style,
              );

  ///
  ///
  ///
  FollyCell.iconButton(
    IconData iconData, {
    Function()? onPressed,
    this.align = Alignment.center,
    this.color = Colors.transparent,
    super.key,
  })  : child = FittedBox(
          child: IconButton(
            icon: Icon(iconData),
            onPressed: onPressed,
          ),
        );

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: child,
    );
  }
}
