import '../models/bed.dart';

class CommandHistory {
  static const int _maxDepth = 50;

  final List<List<Bed>> _past = [];
  final List<List<Bed>> _future = [];

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  List<Bed> _clone(List<Bed> beds) => beds
      .map(
        (b) => Bed(
          id: b.id,
          name: b.name,
          x: b.x,
          y: b.y,
          width: b.width,
          height: b.height,
          cropCount: b.cropCount,
        ),
      )
      .toList();

  void push(List<Bed> current) {
    _past.add(_clone(current));
    if (_past.length > _maxDepth) _past.removeAt(0);
    _future.clear();
  }

  List<Bed>? undo(List<Bed> current) {
    if (!canUndo) return null;
    _future.add(_clone(current));
    return _clone(_past.removeLast());
  }

  List<Bed>? redo(List<Bed> current) {
    if (!canRedo) return null;
    _past.add(_clone(current));
    return _clone(_future.removeLast());
  }
}
