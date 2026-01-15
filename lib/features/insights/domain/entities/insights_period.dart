enum InsightsPeriod {
  week(7, 'Last 7 days'),
  month(30, 'Last 30 days'),
  quarter(90, 'Last 90 days');

  final int days;
  final String label;

  const InsightsPeriod(this.days, this.label);
}
