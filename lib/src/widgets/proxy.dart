import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'box.dart';

class BaselineProxy extends SingleChildRenderObjectWidget {
  const BaselineProxy({Key? key, Widget? child, this.textStyle, this.padding})
      : super(key: key, child: child);

  final TextStyle? textStyle;
  final EdgeInsets? padding;

  @override
  RenderBaselineProxy createRenderObject(BuildContext context) {
    return RenderBaselineProxy(
      null,
      textStyle!,
      padding,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderBaselineProxy renderObject) {
    renderObject
      ..textStyle = textStyle!
      ..padding = padding!;
  }
}

class RenderBaselineProxy extends RenderProxyBox {
  RenderBaselineProxy(
    RenderParagraph? child,
    TextStyle textStyle,
    EdgeInsets? padding,
  )   : _prototypePainter = TextPainter(
            text: TextSpan(text: ' ', style: textStyle),
            textDirection: TextDirection.ltr,
            strutStyle:
                StrutStyle.fromTextStyle(textStyle, forceStrutHeight: true)),
        super(child);

  final TextPainter _prototypePainter;

  set textStyle(TextStyle value) {
    if (_prototypePainter.text!.style == value) {
      return;
    }
    _prototypePainter.text = TextSpan(text: ' ', style: value);
    markNeedsLayout();
  }

  EdgeInsets? _padding;

  set padding(EdgeInsets value) {
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) =>
      _prototypePainter.computeDistanceToActualBaseline(baseline);

  // SEE What happens + _padding?.top;

  @override
  void performLayout() {
    super.performLayout();
    _prototypePainter.layout();
  }
}

class EmbedProxy extends SingleChildRenderObjectWidget {
  const EmbedProxy(Widget child, {this.embedSize}) : super(child: child);

  // 修改，添加embedSize参数，保存图片宽高
  final Size? embedSize;

  @override
  RenderEmbedProxy createRenderObject(BuildContext context) =>
      RenderEmbedProxy(null, embedSize: embedSize);
}

class RenderEmbedProxy extends RenderProxyBox implements RenderContentProxyBox {
  RenderEmbedProxy(RenderBox? child, {this.embedSize}) : super(child);

  /// 添加embedSize参数，有此参数则优先作为渲染宽高
  final Size? embedSize;

  double get width => embedSize == null
      ? size.width
      : getImageSize(embedSize!.width, embedSize!.height);

  double get height => embedSize == null
      ? size.height
      : getImageSize(embedSize!.width, embedSize!.height);

  @override
  List<TextBox> getBoxesForSelection(TextSelection selection) {
    if (!selection.isCollapsed) {
      return <TextBox>[
        TextBox.fromLTRBD(0, 0, width, height, TextDirection.ltr)
      ];
    }

    final left = selection.extentOffset == 0 ? 0.0 : width;
    final right = selection.extentOffset == 0 ? 0.0 : width;
    return <TextBox>[
      TextBox.fromLTRBD(left, 0, right, height, TextDirection.ltr)
    ];
  }

  @override
  double getFullHeightForCaret(TextPosition position) => size.height;

  @override
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) {
    assert(
        position.offset == 1 || position.offset == 0 || position.offset == -1);
    return position.offset <= 0
        ? Offset.zero
        : Offset(size.width - caretPrototype.width, 0);
  }

  @override
  TextPosition getPositionForOffset(Offset offset) =>
      TextPosition(offset: offset.dx > width / 2 ? 1 : 0);

  @override
  TextRange getWordBoundary(TextPosition position) =>
      const TextRange(start: 0, end: 1);

  @override
  double get preferredLineHeight => size.height;

  double getImageSize(num _width, num _height,
      {BoxFit? defaultFit, double? maxSizeConstraint}) {
    return 0;

    // maxSizeConstraint ??= maxMediaWidth;
    // // todo 120 or minSizeConstraint?
    // var width = _width ?? 120;
    // width = width > 0 ? width : 120;
    // var height = _height ?? maxSizeConstraint;
    // height = height > 0 ? height : maxSizeConstraint;
    // BoxFit fit = defaultFit ?? BoxFit.contain;
    // if (width / height > (maxSizeConstraint / minSizeConstraint)) {
    //   // 横线长图
    //   width = maxSizeConstraint;
    //   height = minSizeConstraint;
    //   fit = BoxFit.fitHeight;
    // } else if (height / width > (maxSizeConstraint / minSizeConstraint)) {
    //   // 纵向长图
    //   width = minSizeConstraint;
    //   height = maxSizeConstraint;
    //   fit = BoxFit.fitWidth;
    // } else if (width > maxSizeConstraint || height > maxSizeConstraint) {
    //   final s = min(maxSizeConstraint / width, maxSizeConstraint / height);
    //   width = _width * s;
    //   height = _height * s;
    // } else if (width < minSizeConstraint || height < minSizeConstraint) {
    //   final s = max(minSizeConstraint / width, minSizeConstraint / height);
    //   width = _width * s;
    //   height = _height * s;
    // }
    // return Tuple3(width, height, fit);
  }
}

class RichTextProxy extends SingleChildRenderObjectWidget {
  /// Child argument should be an instance of RichText widget.
  const RichTextProxy(
      {required RichText child,
      required this.textStyle,
      required this.textAlign,
      required this.textDirection,
      required this.locale,
      required this.strutStyle,
      this.textScaleFactor = 1.0,
      this.textWidthBasis = TextWidthBasis.parent,
      this.textHeightBehavior,
      Key? key})
      : super(key: key, child: child);

  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double textScaleFactor;
  final Locale locale;
  final StrutStyle strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  RenderParagraphProxy createRenderObject(BuildContext context) {
    return RenderParagraphProxy(
        null,
        textStyle,
        textAlign,
        textDirection,
        textScaleFactor,
        strutStyle,
        locale,
        textWidthBasis,
        textHeightBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParagraphProxy renderObject) {
    renderObject
      ..textStyle = textStyle
      ..textAlign = textAlign
      ..textDirection = textDirection
      ..textScaleFactor = textScaleFactor
      ..locale = locale
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior;
  }
}

class RenderParagraphProxy extends RenderProxyBox
    implements RenderContentProxyBox {
  RenderParagraphProxy(
    RenderParagraph? child,
    TextStyle textStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    double textScaleFactor,
    StrutStyle strutStyle,
    Locale locale,
    TextWidthBasis textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  )   : _prototypePainter = TextPainter(
            text: TextSpan(text: ' ', style: textStyle),
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor,
            strutStyle: strutStyle,
            locale: locale,
            textWidthBasis: textWidthBasis,
            textHeightBehavior: textHeightBehavior),
        super(child);

  final TextPainter _prototypePainter;

  set textStyle(TextStyle value) {
    if (_prototypePainter.text!.style == value) {
      return;
    }
    _prototypePainter.text = TextSpan(text: ' ', style: value);
    markNeedsLayout();
  }

  set textAlign(TextAlign value) {
    if (_prototypePainter.textAlign == value) {
      return;
    }
    _prototypePainter.textAlign = value;
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_prototypePainter.textDirection == value) {
      return;
    }
    _prototypePainter.textDirection = value;
    markNeedsLayout();
  }

  set textScaleFactor(double value) {
    if (_prototypePainter.textScaleFactor == value) {
      return;
    }
    _prototypePainter.textScaleFactor = value;
    markNeedsLayout();
  }

  set strutStyle(StrutStyle value) {
    if (_prototypePainter.strutStyle == value) {
      return;
    }
    _prototypePainter.strutStyle = value;
    markNeedsLayout();
  }

  set locale(Locale value) {
    if (_prototypePainter.locale == value) {
      return;
    }
    _prototypePainter.locale = value;
    markNeedsLayout();
  }

  set textWidthBasis(TextWidthBasis value) {
    if (_prototypePainter.textWidthBasis == value) {
      return;
    }
    _prototypePainter.textWidthBasis = value;
    markNeedsLayout();
  }

  set textHeightBehavior(TextHeightBehavior? value) {
    if (_prototypePainter.textHeightBehavior == value) {
      return;
    }
    _prototypePainter.textHeightBehavior = value;
    markNeedsLayout();
  }

  @override
  RenderParagraph? get child => super.child as RenderParagraph?;

  @override
  double get preferredLineHeight => _prototypePainter.preferredLineHeight;

  @override
  Offset getOffsetForCaret(TextPosition position, Rect caretPrototype) =>
      child!.getOffsetForCaret(position, caretPrototype);

  @override
  TextPosition getPositionForOffset(Offset offset) =>
      child!.getPositionForOffset(offset);

  @override
  double? getFullHeightForCaret(TextPosition position) =>
      child!.getFullHeightForCaret(position);

  @override
  TextRange getWordBoundary(TextPosition position) =>
      child!.getWordBoundary(position);

  @override
  List<TextBox> getBoxesForSelection(TextSelection selection) => child!
      .getBoxesForSelection(selection, boxHeightStyle: BoxHeightStyle.strut);

  @override
  void performLayout() {
    super.performLayout();
    _prototypePainter.layout(
        minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
  }
}
