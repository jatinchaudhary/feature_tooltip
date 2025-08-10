import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Defines which side of the anchor the tooltip should appear on.
///
/// * [up] – the tooltip appears above the anchor; the arrow points down.
/// * [down] – the tooltip appears below the anchor; the arrow points up.
/// * [left] – the tooltip appears to the left of the anchor; the arrow points right.
/// * [right] – the tooltip appears to the right of the anchor; the arrow points left.
enum TooltipDirection { up, down, left, right }

/// Determines what gesture triggers the tooltip.
///
/// * [tap] – tapping the anchor toggles the tooltip on/off.
/// * [longPress] – long‑pressing the anchor shows the tooltip. Releasing hides it.
/// * [manual] – the developer controls when the tooltip shows or hides via the API.
enum ToolTipTriggerMode { tap, longPress, manual }

/// A highly configurable tooltip widget.
///
/// The [FeatureTooltip] allows you to display custom content in a speech‑bubble
/// style overlay anchored to another widget. You can customise where the
/// tooltip appears relative to the anchor, how it is styled, the animation
/// behaviour and even blur the background while it is visible. Compared to the
/// built‑in [Tooltip] in Flutter, this widget offers far greater control over
/// positioning and appearance.
class FeatureTooltip extends StatefulWidget {
  /// Creates an advanced tooltip.
  const FeatureTooltip({
    Key? key,
    required this.child,
    this.message,
    this.content,
    this.direction = TooltipDirection.up,
    this.offset = Offset.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.backgroundColor = const Color(0xCC000000),
    this.textStyle = const TextStyle(color: Colors.white),
    this.showDuration = const Duration(milliseconds: 200),
    this.hideDuration = const Duration(milliseconds: 200),
    this.waitDuration = Duration.zero,
    this.displayDuration = const Duration(seconds: 3),
    this.animationCurve = Curves.easeOut,
    this.blurBackground = false,
    this.blurSigma = 3.0,
    this.dismissOnTap = true,
    this.arrowWidth = 12.0,
    this.arrowLength = 6.0,
    this.elevation = 4.0,
    this.triggerMode = ToolTipTriggerMode.longPress,
    this.onTooltipShown,
    this.onTooltipDismissed,
  })  : assert(message != null || content != null,
            'Either message or content must be provided'),
        super(key: key);

  /// The widget that the tooltip is anchored to.
  final Widget child;

  /// A simple textual message to display. Ignored if [content] is supplied.
  final String? message;

  /// Custom widget to display inside the tooltip instead of [message].
  final Widget? content;

  /// Where the tooltip should appear relative to the anchor.
  final TooltipDirection direction;

  /// Fine‑tune the tooltip’s position relative to its default placement.
  ///
  /// For example, you might add a horizontal offset when the tooltip is left or
  /// right oriented, or a vertical offset when it is up or down oriented.
  final Offset offset;

  /// Padding inside the tooltip around its content.
  final EdgeInsets padding;

  /// External margin around the tooltip bubble. Does not affect arrow
  /// positioning.
  final EdgeInsets margin;

  /// Border radius of the tooltip bubble.
  final BorderRadius borderRadius;

  /// Background colour of the tooltip bubble and arrow.
  final Color backgroundColor;

  /// Text style for [message]. Ignored if [content] is provided.
  final TextStyle textStyle;

  /// Duration for the show (fade/slide) animation.
  final Duration showDuration;

  /// Duration for the hide (reverse) animation.
  final Duration hideDuration;

  /// Delay before showing the tooltip after being triggered.
  final Duration waitDuration;

  /// How long the tooltip stays visible before automatically hiding. Use
  /// [Duration.zero] to keep the tooltip visible until dismissed manually
  /// (for example with [dismissOnTap]).
  final Duration displayDuration;

  /// Curve used for both the fade and slide animations.
  final Curve animationCurve;

  /// Whether to blur the content behind the tooltip while it is visible.
  final bool blurBackground;

  /// The sigma used for Gaussian blur when [blurBackground] is true.
  final double blurSigma;

  /// If true, tapping anywhere outside the tooltip will hide it.
  final bool dismissOnTap;

  /// Width of the arrow base perpendicular to the direction the tooltip
  /// appears.
  final double arrowWidth;

  /// Length of the arrow parallel to the direction the tooltip appears.
  final double arrowLength;

  /// Elevation of the material used for the tooltip. This affects the drop
  /// shadow. Set to zero for a flat tooltip without shadow.
  final double elevation;

  /// Which user gesture triggers the tooltip to show and hide.
  final ToolTipTriggerMode triggerMode;

  /// Callback invoked when the tooltip becomes visible.
  final VoidCallback? onTooltipShown;

  /// Callback invoked when the tooltip is dismissed.
  final VoidCallback? onTooltipDismissed;

  @override
  State<FeatureTooltip> createState() => _FeatureTooltipState();
}

class _FeatureTooltipState extends State<FeatureTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Offset _tooltipOffset = Offset.zero;
  final GlobalKey _tooltipKey = GlobalKey();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initAnimationController();
  }

  void _initAnimationController() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.showDuration,
      reverseDuration: widget.hideDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    // Use a slight offset to slide from, depending on the tooltip’s direction.
    _slideAnimation = Tween<Offset>(
      begin: _computeBeginOffset(widget.direction),
      end: Offset.zero,
    ).animate(_fadeAnimation);
  }

  /// Returns an offset for the slide animation based on the direction.
  Offset _computeBeginOffset(TooltipDirection direction) {
    switch (direction) {
      case TooltipDirection.up:
        // Slide up from slightly below.
        return const Offset(0, 0.1);
      case TooltipDirection.down:
        // Slide down from slightly above.
        return const Offset(0, -0.1);
      case TooltipDirection.left:
        // Slide left from slightly right.
        return const Offset(0.1, 0);
      case TooltipDirection.right:
        // Slide right from slightly left.
        return const Offset(-0.1, 0);
    }
  }

  @override
  void didUpdateWidget(covariant FeatureTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild the animation controller if any animation‑relevant fields change.
    if (oldWidget.showDuration != widget.showDuration ||
        oldWidget.hideDuration != widget.hideDuration ||
        oldWidget.animationCurve != widget.animationCurve ||
        oldWidget.direction != widget.direction) {
      _controller.dispose();
      _initAnimationController();
    }
  }

  /// Shows the tooltip. If it’s already visible, this does nothing.
  void _showTooltip() {
    if (_isVisible) return;
    _hideTimer?.cancel();
    // Insert the overlay entry immediately, but position will be updated after
    // first layout.
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
    _isVisible = true;
    if (widget.waitDuration > Duration.zero) {
      Future.delayed(widget.waitDuration, () {
        if (_isVisible) {
          _controller.forward();
          widget.onTooltipShown?.call();
          if (widget.displayDuration != Duration.zero) {
            _hideTimer =
                Timer(widget.displayDuration, _hideTooltip); // auto hide
          }
        }
      });
    } else {
      _controller.forward();
      widget.onTooltipShown?.call();
      if (widget.displayDuration != Duration.zero) {
        _hideTimer = Timer(widget.displayDuration, _hideTooltip);
      }
    }
    // Compute the tooltip position after the overlay has been laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePosition();
    });
  }

  /// Computes where the tooltip should appear relative to its anchor.
  void _updatePosition() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size anchorSize = renderBox.size;
    final Offset anchorPosition = renderBox.localToGlobal(Offset.zero);
    final Size tooltipSize = _tooltipKey.currentContext?.size ?? Size.zero;
    double dx;
    double dy;
    switch (widget.direction) {
      case TooltipDirection.up:
        dx = anchorPosition.dx +
            (anchorSize.width - tooltipSize.width) / 2 +
            widget.offset.dx;
        dy = anchorPosition.dy - tooltipSize.height - widget.offset.dy;
        break;
      case TooltipDirection.down:
        dx = anchorPosition.dx +
            (anchorSize.width - tooltipSize.width) / 2 +
            widget.offset.dx;
        dy = anchorPosition.dy + anchorSize.height + widget.offset.dy;
        break;
      case TooltipDirection.left:
        dx = anchorPosition.dx - tooltipSize.width - widget.offset.dx;
        dy = anchorPosition.dy +
            (anchorSize.height - tooltipSize.height) / 2 +
            widget.offset.dy;
        break;
      case TooltipDirection.right:
        dx = anchorPosition.dx + anchorSize.width + widget.offset.dx;
        dy = anchorPosition.dy +
            (anchorSize.height - tooltipSize.height) / 2 +
            widget.offset.dy;
        break;
    }
    setState(() {
      _tooltipOffset = Offset(dx, dy);
    });
    _overlayEntry?.markNeedsBuild();
  }

  /// Hides the tooltip with animation.
  void _hideTooltip() {
    if (!_isVisible) return;
    _hideTimer?.cancel();
    _controller.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      widget.onTooltipDismissed?.call();
    });
  }

  /// Constructs the overlay entry containing the blurred backdrop (if
  /// enabled), the dismiss gesture handler and the tooltip itself.
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: <Widget>[
            // If background blur is enabled we insert a BackdropFilter behind
            // everything. A GestureDetector wraps it to dismiss on tap if
            // requested.
            if (widget.blurBackground)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.dismissOnTap ? _hideTooltip : null,
                  behavior: HitTestBehavior.translucent,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
                    child: Container(
                      color: Colors.black.withOpacity(0.0),
                    ),
                  ),
                ),
              )
            else if (widget.dismissOnTap)
              // If blur isn’t used we still need to detect taps outside the
              // tooltip to dismiss it. In this case we use an empty
              // GestureDetector covering the screen.
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideTooltip,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
            // The positioned tooltip. It will slide/fade into view according
            // to the configured animations.
            Positioned(
              left: _tooltipOffset.dx,
              top: _tooltipOffset.dy,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Material(
                    color: Colors.transparent,
                    elevation: widget.elevation,
                    child: _TooltipBubble(
                      key: _tooltipKey,
                      message: widget.message,
                      content: widget.content,
                      padding: widget.padding,
                      margin: widget.margin,
                      borderRadius: widget.borderRadius,
                      backgroundColor: widget.backgroundColor,
                      textStyle: widget.textStyle,
                      direction: widget.direction,
                      arrowWidth: widget.arrowWidth,
                      arrowLength: widget.arrowLength,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handles tap gestures when [triggerMode] is [ToolTipTriggerMode.tap].
  void _handleTap() {
    if (widget.triggerMode != ToolTipTriggerMode.tap) return;
    if (_isVisible) {
      _hideTooltip();
    } else {
      _showTooltip();
    }
  }

  /// Handles long‑press gestures when [triggerMode] is
  /// [ToolTipTriggerMode.longPress].
  void _handleLongPress() {
    if (widget.triggerMode != ToolTipTriggerMode.longPress) return;
    _showTooltip();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      onTap: widget.triggerMode == ToolTipTriggerMode.tap ? _handleTap : null,
      onLongPress: widget.triggerMode == ToolTipTriggerMode.longPress
          ? _handleLongPress
          : null,
      child: widget.child,
    );
    return result;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}

/// Internal widget that draws the tooltip bubble with an arrow and hosts
/// either simple text or a custom child.
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    Key? key,
    this.message,
    this.content,
    required this.padding,
    required this.margin,
    required this.borderRadius,
    required this.backgroundColor,
    required this.textStyle,
    required this.direction,
    required this.arrowWidth,
    required this.arrowLength,
  })  : assert(message != null || content != null,
            'Either message or content must be provided'),
        super(key: key);

  final String? message;
  final Widget? content;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final TextStyle textStyle;
  final TooltipDirection direction;
  final double arrowWidth;
  final double arrowLength;

  /// Computes extra padding to avoid the arrow overlapping with the content.
  EdgeInsets _effectiveContentPadding() {
    switch (direction) {
      case TooltipDirection.up:
        // Arrow on the bottom; increase bottom padding.
        return padding.copyWith(
          bottom: padding.bottom + arrowLength,
        );
      case TooltipDirection.down:
        // Arrow on the top; increase top padding.
        return padding.copyWith(
          top: padding.top + arrowLength,
        );
      case TooltipDirection.left:
        // Arrow on the right; increase right padding.
        return padding.copyWith(
          right: padding.right + arrowLength,
        );
      case TooltipDirection.right:
        // Arrow on the left; increase left padding.
        return padding.copyWith(
          left: padding.left + arrowLength,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    if (content != null) {
      childWidget = content!;
    } else {
      childWidget = Text(
        message!,
        style: textStyle,
        textAlign: TextAlign.start,
      );
    }
    return Container(
      margin: margin,
      child: CustomPaint(
        painter: _BubblePainter(
          color: backgroundColor,
          borderRadius: borderRadius,
          direction: direction,
          arrowWidth: arrowWidth,
          arrowLength: arrowLength,
        ),
        child: Padding(
          padding: _effectiveContentPadding(),
          child: childWidget,
        ),
      ),
    );
  }
}

/// Paints the tooltip bubble with an integrated arrow. This painter
/// understands the direction of the tooltip and draws the arrow on the
/// appropriate side. The rest of the rectangle has rounded corners.
class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.color,
    required this.borderRadius,
    required this.direction,
    required this.arrowWidth,
    required this.arrowLength,
  });

  final Color color;
  final BorderRadius borderRadius;
  final TooltipDirection direction;
  final double arrowWidth;
  final double arrowLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    // The radius for each corner. Use the provided BorderRadius to create an
    // RRect for the main bubble body.
    switch (direction) {
      case TooltipDirection.up:
        {
          final double bodyHeight = size.height - arrowLength;
          final Rect bodyRect = Rect.fromLTWH(0, 0, size.width, bodyHeight);
          final RRect rrect = RRect.fromRectAndCorners(
            bodyRect,
            topLeft: borderRadius.topLeft,
            topRight: borderRadius.topRight,
            bottomLeft: borderRadius.bottomLeft,
            bottomRight: borderRadius.bottomRight,
          );
          path.addRRect(rrect);
          final double arrowX = (size.width - arrowWidth) / 2;
          final double arrowY = bodyHeight;
          path.moveTo(arrowX, arrowY);
          path.lineTo(arrowX + arrowWidth, arrowY);
          path.lineTo(arrowX + arrowWidth / 2, arrowY + arrowLength);
          path.close();
          break;
        }
      case TooltipDirection.down:
        {
          final double bodyHeight = size.height - arrowLength;
          final Rect bodyRect = Rect.fromLTWH(0, arrowLength, size.width, bodyHeight);
          final RRect rrect = RRect.fromRectAndCorners(
            bodyRect,
            topLeft: borderRadius.topLeft,
            topRight: borderRadius.topRight,
            bottomLeft: borderRadius.bottomLeft,
            bottomRight: borderRadius.bottomRight,
          );
          path.addRRect(rrect);
          final double arrowX = (size.width - arrowWidth) / 2;
          // The arrow base is at y = arrowLength; the tip is at y = 0.
          path.moveTo(arrowX, arrowLength);
          path.lineTo(arrowX + arrowWidth, arrowLength);
          path.lineTo(arrowX + arrowWidth / 2, 0);
          path.close();
          break;
        }
      case TooltipDirection.left:
        {
          final double bodyWidth = size.width - arrowLength;
          final Rect bodyRect = Rect.fromLTWH(0, 0, bodyWidth, size.height);
          final RRect rrect = RRect.fromRectAndCorners(
            bodyRect,
            topLeft: borderRadius.topLeft,
            bottomLeft: borderRadius.bottomLeft,
            topRight: borderRadius.topRight,
            bottomRight: borderRadius.bottomRight,
          );
          path.addRRect(rrect);
          final double arrowY = (size.height - arrowWidth) / 2;
          final double arrowX = bodyWidth;
          // Arrow on the right; tip points to the right.
          path.moveTo(arrowX, arrowY);
          path.lineTo(arrowX + arrowLength, arrowY + arrowWidth / 2);
          path.lineTo(arrowX, arrowY + arrowWidth);
          path.close();
          break;
        }
      case TooltipDirection.right:
        {
          final double bodyWidth = size.width - arrowLength;
          final Rect bodyRect = Rect.fromLTWH(arrowLength, 0, bodyWidth, size.height);
          final RRect rrect = RRect.fromRectAndCorners(
            bodyRect,
            topLeft: borderRadius.topLeft,
            bottomLeft: borderRadius.bottomLeft,
            topRight: borderRadius.topRight,
            bottomRight: borderRadius.bottomRight,
          );
          path.addRRect(rrect);
          final double arrowY = (size.height - arrowWidth) / 2;
          final double arrowX = arrowLength;
          // Arrow on the left; tip points to the left.
          path.moveTo(arrowX, arrowY);
          path.lineTo(0, arrowY + arrowWidth / 2);
          path.lineTo(arrowX, arrowY + arrowWidth);
          path.close();
          break;
        }
    }
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.direction != direction ||
        oldDelegate.arrowWidth != arrowWidth ||
        oldDelegate.arrowLength != arrowLength;
  }
}