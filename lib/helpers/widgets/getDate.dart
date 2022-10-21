import 'package:intl/intl.dart';

Map getDate(DateTime date) {
  var amPm = date.hour >= 12 ? "PM" : "AM";
  String _timeFormat = DateFormat('kk:mm').format(date);
  String _cleanDate = int.parse(_timeFormat.split(':')[0]) > 12
      ? "${int.parse(_timeFormat.split(':')[0]) - 12}:${_timeFormat.split(':')[1]} $amPm"
      : "$_timeFormat $amPm";
  var fullDate = '${DateFormat('E, MMM d').format(date)}, $_cleanDate';
  return {
    "fullDate": fullDate,
    "cleanedDate": _cleanDate,
  };
}
