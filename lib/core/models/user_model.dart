class UserModel {
  final String id;
  final String? username; // username veya displayName
  final String? photoUrl;
  final String? bio;

  UserModel({
    required this.id,
    this.username,
    this.photoUrl,
    this.bio,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      username: data['username'] as String?,
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (username != null) 'username': username,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
    };
  }
}
