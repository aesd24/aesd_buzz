class Paginator {
  int currentPage = 0;
  int lastPage = 0;
  int total = 0;

  Paginator();

  Paginator.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    total = json['total'];
  }
}
