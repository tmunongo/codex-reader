import 'package:flutter/material.dart';

/// A resizable split view with left and right panes
class SplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double initialLeftWidth;
  final double minLeftWidth;
  final double maxLeftWidth;
  final double dividerWidth;
  final Color? dividerColor;
  final ValueChanged<double>? onDividerDragged;

  const SplitView({
    super.key,
    required this.left,
    required this.right,
    this.initialLeftWidth = 300,
    this.minLeftWidth = 200,
    this.maxLeftWidth = 600,
    this.dividerWidth = 8,
    this.dividerColor,
    this.onDividerDragged,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double _leftWidth;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _leftWidth = widget.initialLeftWidth;
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _leftWidth = (_leftWidth + details.delta.dx).clamp(
        widget.minLeftWidth,
        widget.maxLeftWidth.clamp(widget.minLeftWidth, maxWidth - 100),
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    widget.onDividerDragged?.call(_leftWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // Ensure left width fits within constraints
        final constrainedLeftWidth = _leftWidth.clamp(
          widget.minLeftWidth,
          (maxWidth - widget.dividerWidth - 100).clamp(
            widget.minLeftWidth,
            widget.maxLeftWidth,
          ),
        );

        return Row(
          children: [
            // Left pane
            SizedBox(width: constrainedLeftWidth, child: widget.left),

            // Divider with drag handle
            GestureDetector(
              onHorizontalDragStart: (_) {
                setState(() {
                  _isDragging = true;
                });
              },
              onHorizontalDragUpdate: (details) {
                _onDragUpdate(details, maxWidth);
              },
              onHorizontalDragEnd: _onDragEnd,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: widget.dividerWidth,
                  color: _isDragging
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .3)
                      : (widget.dividerColor ??
                            Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: .2)),
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: .4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right pane
            Expanded(child: widget.right),
          ],
        );
      },
    );
  }
}
