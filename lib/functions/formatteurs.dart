String formatDate(DateTime date, {bool stringMonth = false}){
  List<String> yearMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  String day = date.day < 10 ? '0${date.day}'  : date.day.toString();
  String month = "";
  if (stringMonth) {
    month = yearMonths[date.month - 1];
  } else {
    month = date.month < 10 ? '0${date.month}'  : date.month.toString();
  }
  return "$day/$month/${date.year}";
}

String getTimeInString(Duration duration) {
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
  return "${hours<10?'0$hours':hours.toString()}"
      ":${minutes<10?'0$minutes':minutes.toString()}"
      ":${seconds<10?'0$seconds':seconds.toString()}";
}