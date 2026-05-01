import 'seed_catalog.dart';

enum SowMethod { tray, direct, either }

class SowCalendarItem {
  const SowCalendarItem({
    required this.seedKey,
    required this.method,
    required this.months,
    required this.note,
  });

  final String seedKey;
  final SowMethod method;
  final List<int> months;
  final String note;

  bool isForMonth(int month) {
    return months.contains(month);
  }

  SeedCatalogItem get seed {
    return SeedCatalog.byKey(seedKey);
  }
}

class MonthlySowPlan {
  const MonthlySowPlan({
    required this.month,
    required this.tray,
    required this.direct,
    required this.either,
    required this.nextMonthTray,
    required this.nextMonthDirect,
    required this.nextMonthEither,
  });

  final int month;
  final List<SowCalendarItem> tray;
  final List<SowCalendarItem> direct;
  final List<SowCalendarItem> either;
  final List<SowCalendarItem> nextMonthTray;
  final List<SowCalendarItem> nextMonthDirect;
  final List<SowCalendarItem> nextMonthEither;

  bool get hasCurrentItems {
    return tray.isNotEmpty || direct.isNotEmpty || either.isNotEmpty;
  }

  bool get hasNextMonthItems {
    return nextMonthTray.isNotEmpty ||
        nextMonthDirect.isNotEmpty ||
        nextMonthEither.isNotEmpty;
  }
}

class SowCalendar {
  const SowCalendar._();

  static const List<SowCalendarItem> items = [
    SowCalendarItem(
      seedKey: 'tomato',
      method: SowMethod.tray,
      months: [7, 8, 9, 10],
      note: 'Start in trays with warmth. Transplant after frost risk.',
    ),
    SowCalendarItem(
      seedKey: 'capsicum',
      method: SowMethod.tray,
      months: [7, 8, 9],
      note: 'Slow crop. Start early in warm trays.',
    ),
    SowCalendarItem(
      seedKey: 'chilli',
      method: SowMethod.tray,
      months: [7, 8, 9],
      note: 'Needs warmth and patience. Germination can be slow.',
    ),
    SowCalendarItem(
      seedKey: 'eggplant',
      method: SowMethod.tray,
      months: [7, 8, 9],
      note: 'Start warm like capsicum.',
    ),
    SowCalendarItem(
      seedKey: 'broccoli',
      method: SowMethod.tray,
      months: [2, 3, 4, 5, 8, 9],
      note: 'Good cool-season crop. Avoid leggy seedlings.',
    ),
    SowCalendarItem(
      seedKey: 'lettuce',
      method: SowMethod.either,
      months: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      note: 'Sow small batches often. Protect from heat.',
    ),
    SowCalendarItem(
      seedKey: 'basil',
      method: SowMethod.tray,
      months: [9, 10, 11, 12],
      note: 'Needs warmth. Do not plant outside too early.',
    ),
    SowCalendarItem(
      seedKey: 'cucumber',
      method: SowMethod.tray,
      months: [9, 10, 11, 12],
      note: 'Start close to transplant time. Avoid root disturbance.',
    ),
    SowCalendarItem(
      seedKey: 'zucchini',
      method: SowMethod.tray,
      months: [9, 10, 11, 12],
      note: 'Fast grower. Do not leave too long in trays.',
    ),
    SowCalendarItem(
      seedKey: 'pumpkin',
      method: SowMethod.tray,
      months: [9, 10, 11],
      note: 'Sow when transplanting into warm soil is close.',
    ),
    SowCalendarItem(
      seedKey: 'watermelon',
      method: SowMethod.tray,
      months: [9, 10, 11],
      note: 'Needs warm soil and frost-free transplanting.',
    ),
  ];

  static MonthlySowPlan planFor(DateTime date) {
    final month = date.month;
    final nextMonth = month == 12 ? 1 : month + 1;

    final current = items.where((item) => item.isForMonth(month)).toList();
    final next = items.where((item) => item.isForMonth(nextMonth)).toList();

    return MonthlySowPlan(
      month: month,
      tray: _byMethod(current, SowMethod.tray),
      direct: _byMethod(current, SowMethod.direct),
      either: _byMethod(current, SowMethod.either),
      nextMonthTray: _byMethod(next, SowMethod.tray),
      nextMonthDirect: _byMethod(next, SowMethod.direct),
      nextMonthEither: _byMethod(next, SowMethod.either),
    );
  }

  static List<SowCalendarItem> _byMethod(
    List<SowCalendarItem> source,
    SowMethod method,
  ) {
    return source.where((item) => item.method == method).toList();
  }

  static String monthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Month';
    }
  }
}
