import 'package:flutter/foundation.dart';

@immutable
class ViewOptions {
  const ViewOptions({
    this.dashboardExpanded = true,
    this.gridVisible = true,
    this.labelsVisible = true,
    this.cropRowsVisible = true,
    this.mapInstructionsVisible = true,
  });

  final bool dashboardExpanded;
  final bool gridVisible;
  final bool labelsVisible;
  final bool cropRowsVisible;
  final bool mapInstructionsVisible;

  ViewOptions copyWith({
    bool? dashboardExpanded,
    bool? gridVisible,
    bool? labelsVisible,
    bool? cropRowsVisible,
    bool? mapInstructionsVisible,
  }) {
    return ViewOptions(
      dashboardExpanded: dashboardExpanded ?? this.dashboardExpanded,
      gridVisible: gridVisible ?? this.gridVisible,
      labelsVisible: labelsVisible ?? this.labelsVisible,
      cropRowsVisible: cropRowsVisible ?? this.cropRowsVisible,
      mapInstructionsVisible:
          mapInstructionsVisible ?? this.mapInstructionsVisible,
    );
  }
}
