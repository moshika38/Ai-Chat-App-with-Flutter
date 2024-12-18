class MassageModel {
  final String massage;
  final String author;
  final String time;

  MassageModel({
    required this.massage,
    required this.author,
    required this.time,
  });

  factory MassageModel.fromJson(Map<String, dynamic> json) {
    return MassageModel(
      massage: json['massage'] as String,
      author: json['author'] as String,
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'massage': massage,
      'author': author,
      'time': time,
    };
  }
}
