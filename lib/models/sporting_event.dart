class SportingEvent {
  final String sport;
  final String opponent;
  final DateTime dateTime;
  final String location;
  final bool isHome;
  final String? result;

  SportingEvent({
    required this.sport,
    required this.opponent,
    required this.dateTime,
    required this.location,
    required this.isHome,
    this.result,
  });

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }

  String get formattedTime {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get homeAwayText {
    return isHome ? 'vs' : '@';
  }
}
