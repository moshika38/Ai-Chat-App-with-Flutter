class MassageModel {
<<<<<<< HEAD
=======
  final String id;
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
  final String massage;
  final String author;
  final String time;

  MassageModel({
<<<<<<< HEAD
=======
    required this.id,
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
    required this.massage,
    required this.author,
    required this.time,
  });
<<<<<<< HEAD

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
=======
>>>>>>> 7ad738f41c28de2dee91559451073c2534c12800
}
