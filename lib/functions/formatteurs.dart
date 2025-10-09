import 'package:intl/intl.dart';

String getTimePart(DateTime date) {
  final time =
      "${date.hour < 10 ? '0${date.hour}' : date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}";
  return time;
}

String formatDate(DateTime date, {bool withTime = true}) {
  if (withTime) return DateFormat('d MMM yyyy à HH:mm', 'fr_FR').format(date);
  return DateFormat('d MMM yyyy', 'fr_FR').format(date);
}

String getTimeInString(
  Duration duration, {
  bool showHours = true,
  bool showSeconds = true,
}) {
  int seconds = duration.inSeconds;
  int minutes = 0;
  int hours = 0;
  while (seconds > 60) {
    minutes++;
    seconds -= 60;
  }
  while (minutes > 60) {
    hours++;
    minutes -= 60;
  }
  final hoursString =
      showHours ? "${hours < 10 ? '0$hours' : hours.toString()}:" : '';
  final minutesString = "${minutes < 10 ? '0$minutes' : minutes.toString()}:";
  final secondsString =
      showSeconds
          ? seconds < 10
              ? '0$seconds'
              : seconds.toString()
          : '';

  return hoursString + minutesString + secondsString;
}

String getPostFormattedDate(DateTime postDate) {
  final now = DateTime.now();
  final difference = now.difference(postDate);

  if (difference.inDays >= 30) {
    return DateFormat('d MMM yyyy', 'fr_FR').format(postDate);
  } else if (difference.inDays >= 1) {
    return 'Il y a ${difference.inDays} ${difference.inDays == 1 ? "jour" : "jours"}';
  } else if (difference.inHours >= 1) {
    return 'Il y a ${difference.inHours} ${difference.inHours == 1 ? "heure" : "heures"}';
  } else if (difference.inMinutes >= 1) {
    return 'Il y a ${difference.inMinutes} ${difference.inMinutes == 1 ? "minute" : "minutes"}';
  } else {
    return 'À l\'instant';
  }
}

String formatPrice(int price) {
  return NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'Fr',
    decimalDigits: 0,
  ).format(price);
}
