import 'package:flutter/material.dart';
import '../../../../core/models/bed.dart';

class BedCard extends StatelessWidget {
  const BedCard({
    super.key,
    required this.bed,
    this.isSelected,
    this.selected,
    this.overlapping,
    this.isOverlapping,
    this.borderColor,
    this.statusColor,
    this.bedNumber,
    this.index,
    this.showDetails = true,
    this.compact = false,
  });

  final Bed bed;
  final bool? isSelected;
  final bool? selected;
  final bool? overlapping;
  final bool? isOverlapping;
  final Color? borderColor;
  final Color? statusColor;
  final int? bedNumber;
  final int? index;
  final bool showDetails;
  final bool compact;

  bool get _selected => isSelected ?? selected ?? false;
  bool get _overlapping => overlapping ?? isOverlapping ?? false;
  int? get _number => bedNumber ?? index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final woodBorder = _overlapping
        ? const Color(0xFFB45309)
        : borderColor ?? const Color(0xFF7A4A16);

    final woodShadow = _overlapping
        ? const Color(0x33B45309)
        : const Color(0x2F5B3411);

    final fillTop = _overlapping
        ? const Color(0xFFF3E1C8)
        : const Color(0xFFF8F8F5);

    final fillBottom = _overlapping
        ? const Color(0xFFE8D3B6)
        : const Color(0xFFF1F1EE);

    final chipColor = statusColor ?? const Color(0xFF2F8F59);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final radius = BorderRadius.circular(compact ? 14 : 22);
        final innerRadius = BorderRadius.circular(compact ? 10 : 18);
        final rowCount = _rowCountFor(height);
        final showCenterLabel = width > 170 && height > 95;
        final showTopCard = width > 110 && height > 52;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: woodShadow,
                blurRadius: _selected ? 18 : 10,
                spreadRadius: _selected ? 2 : 0,
                offset: const Offset(0, 5),
              ),
              if (_selected)
                BoxShadow(
                  color: const Color(0x332F8F59),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: woodBorder, width: compact ? 4 : 6),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9A6324), Color(0xFF6B3F14)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 5 : 7),
              child: ClipRRect(
                borderRadius: innerRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [fillTop, fillBottom],
                        ),
                      ),
                    ),

                    // subtle paper/grid texture
                    CustomPaint(painter: _BedTexturePainter()),

                    // rounded planting rows
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 10,
                        vertical: compact ? 8 : 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(rowCount, (rowIndex) {
                          final dark = rowIndex.isEven;
                          return Container(
                            height: _rowHeightFor(height, rowCount),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0x22A1A1A1)
                                  : const Color(0x14999999),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                    ),

                    // centered big title
                    if (showCenterLabel)
                      IgnorePointer(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 20 : 28,
                            ),
                            child: Text(
                              bed.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withValues(alpha: 0.88),
                                    letterSpacing: -0.5,
                                    fontSize: compact ? 15 : 19,
                                    height: 1.05,
                                  ) ??
                                  TextStyle(
                                    fontSize: compact ? 15 : 19,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withValues(alpha: 0.88),
                                  ),
                            ),
                          ),
                        ),
                      ),

                    // top-left info card
                    if (showTopCard)
                      Positioned(
                        top: compact ? 8 : 10,
                        left: compact ? 8 : 10,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: width * 0.58),
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 8 : 10,
                            vertical: compact ? 5 : 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(
                              compact ? 10 : 12,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x15000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: const Color(0x14000000)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: compact ? 20 : 24,
                                height: compact ? 20 : 24,
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${(_number ?? 0) == 0 ? '' : _number}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 10 : 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              SizedBox(width: compact ? 7 : 9),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      bed.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: compact ? 11 : 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF231F1A),
                                      ),
                                    ),
                                    if (showDetails)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 1),
                                        child: Text(
                                          '${bed.width.toStringAsFixed(1)}m x ${bed.height.toStringAsFixed(1)}m',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: compact ? 9 : 10,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF6B6B6B),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _rowCountFor(double height) {
    if (height >= 220) return 4;
    if (height >= 130) return 3;
    return 2;
  }

  double _rowHeightFor(double height, int rowCount) {
    final available = height - 28;
    final rowHeight = available / (rowCount * 1.9);
    return rowHeight.clamp(16.0, 46.0);
  }
}

class _BedTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = const Color(0x0E000000)
      ..strokeWidth = 0.6;

    for (double x = 0; x <= size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }

    for (double y = 0; y <= size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
