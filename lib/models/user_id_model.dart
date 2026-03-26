class UserIdModel {
  final String userId;
  final String name;
  final String avatarUrl;

  UserIdModel({
    required this.userId,
    required this.name,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'name': name, 'avatarUrl': avatarUrl};
  }

  factory UserIdModel.fromJson(Map<String, dynamic> json) {
    return UserIdModel(
      userId: json['userId'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
