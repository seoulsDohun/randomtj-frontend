class SingModel {
  final String title, singer, no;

  SingModel({
    required this.title,
    required this.singer,
    required this.no,
  });

  SingModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        singer = json['singer'],
        no = json['no'];
}
