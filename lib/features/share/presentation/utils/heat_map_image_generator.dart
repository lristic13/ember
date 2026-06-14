import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/editorial_card_style.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../widgets/editorial_share_card.dart';

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
    required int month,
  }) async {
    // Resolve the overlay synchronously, before any async gap, so we never
    // touch a (possibly defunct) BuildContext after awaiting.
    final overlay = Overlay.of(context);

    // Pre-warm the card's fonts so the capture never renders a fallback frame.
    await EditorialCardText.ensureLoaded();

    // Create the share card widget wrapped in RepaintBoundary
    final shareCard = RepaintBoundary(
      key: _boundaryKey,
      child: EditorialShareCard(
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
            width: EditorialShareCard.width,
            height: EditorialShareCard.height,
            child: shareCard,
          ),
        ),
      ),
    );

    // Insert the overlay
    overlay.insert(_overlayEntry!);

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
      final filePath = await _saveToTempFile(
        bytes: byteData.buffer.asUint8List(),
        fileName:
            'ember_${habit.name.toLowerCase().replaceAll(' ', '_')}_${year}_$month.png',
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
