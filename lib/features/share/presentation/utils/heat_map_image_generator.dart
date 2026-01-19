import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../widgets/share_card.dart';

/// Generates shareable PNG images from heat map data.
///
/// This uses an overlay-based approach where the widget is temporarily
/// added to the widget tree (offstage) to properly render it.
class HeatMapImageGenerator {
  static OverlayEntry? _overlayEntry;
  static final _boundaryKey = GlobalKey();

  /// Generates a shareable image and returns the file path.
  static Future<String> generate({
    required BuildContext context,
    required Habit habit,
    required List<HabitEntry> entries,
    required int year,
    int? month,
  }) async {
    // Create the share card widget wrapped in RepaintBoundary
    final shareCard = RepaintBoundary(
      key: _boundaryKey,
      child: ShareCard(
        habit: habit,
        entries: entries,
        year: year,
        month: month,
      ),
    );

    // Create an overlay entry to render the widget offstage
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -10000, // Position far off-screen
        top: -10000,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: ShareCard.width,
            height: ShareCard.height,
            child: shareCard,
          ),
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);

    try {
      // Wait for the widget to be built and laid out
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture the image
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Failed to find render boundary');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      // Save to temp file
      final monthSuffix = month != null ? '_$month' : '';
      final filePath = await _saveToTempFile(
        bytes: byteData.buffer.asUint8List(),
        fileName:
            'ember_${habit.name.toLowerCase().replaceAll(' ', '_')}_$year$monthSuffix.png',
      );

      return filePath;
    } finally {
      // Remove the overlay
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  static Future<String> _saveToTempFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
