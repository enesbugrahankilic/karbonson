// lib/core/utils/text_extensions.dart
// Text widget extensions for consistent text overflow handling

import 'package:flutter/material.dart';

/// Extension methods for Text widget to handle overflow consistently
extension TextOverflowExtension on Text {
  /// Returns a Text widget with ellipsis overflow and single line
  Text withEllipsis() {
    return Text(
      data ?? '',
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: TextOverflow.ellipsis,
      textScaler: textScaler,
      maxLines: 1,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  /// Returns a Text widget with ellipsis overflow and specified max lines
  Text withMaxLines(int maxLines) {
    return Text(
      data ?? '',
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: TextOverflow.ellipsis,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
