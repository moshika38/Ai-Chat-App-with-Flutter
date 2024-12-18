class UserModel {
  final String id;
  final List<String>? roomID;

  UserModel({
    required this.id,
    required this.roomID,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      roomID: (json['roomID'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomID': roomID,
    };
  }

}