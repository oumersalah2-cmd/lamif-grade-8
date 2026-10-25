/// Time duration filters for performance analysis charts
enum TimeRangeFilter {
  last7Days('7D', 'Torbee 1', 'Last 7 Days', 7),
  last30Days('30D', 'Ji\'a 1', 'Last 30 Days', 30),
  last90Days('90D', 'Ji\'a 3', 'Last 3 Months', 90),
  allTime('ALL', 'Hunda', 'All Time', null);

  final String code;
  final String labelOm;
  final String labelEn;
  final int? daysCount;

  const TimeRangeFilter(this.code, this.labelOm, this.labelEn, this.daysCount);

  DateTime? get cutoffDate {
    if (daysCount == null) return null;
    return DateTime.now().subtract(Duration(days: daysCount!));
  }
}
