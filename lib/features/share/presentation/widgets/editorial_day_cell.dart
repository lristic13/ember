import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';

/// A single day tile in the Editorial card calendar.
///
/// Logged days render as a filled accent gradient with a glow and a top sheen;
/// empty days render as a dark bordered tile.
class EditorialDayCell extends StatelessWidget {
  final int day;
  final bool logged;
  final double size;
  final EditorialAccent accent;

  const EditorialDayCell({
    super.key,
    required this.day,
    required this.logged,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: logged ? null : EditorialCardColors.cell,
        gradient: logged
            ? LinearGradient(
                // ~155° to match the CSS reference.
                begin: const Alignment(-0.9, -1),
                end: const Alignment(0.9, 1),
                colors: [accent.bright, accent.mid, accent.deep],
                stops: const [0.0, 0.45, 1.0],
              )
            : null,
        border: logged
            ? null
            : Border.all(color: EditorialCardColors.cellBorder, width: 1),
        boxShadow: logged
            ? [
                BoxShadow(
                  color: accent.glow,
                  blurRadius: size * 0.16,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (logged)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        EditorialCardColors.sheen,
                        EditorialCardColors.sheen.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ),
            Text(
              '$day',
              style: EditorialCardText.display(
                size * 0.34,
                weight: logged ? FontWeight.w600 : FontWeight.w500,
                color: logged
                    ? accent.ink
                    : EditorialCardColors.dimmer,
                letterSpacing: -0.02 * size * 0.34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
