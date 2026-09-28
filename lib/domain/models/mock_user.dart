import 'social/user.dart';

class MockUser {
  String id;
  String name;
  String? imageURL;
  String? description;

  MockUser({
    required this.id,
    required this.name,
    this.imageURL,
    this.description,
  });

  factory MockUser.byId(String id) {
    return MockUser(id: id, name: '$id의 닉네임', description: '$id입니다');
  }

  UserSummary toSummary() {
    final cleanHandle = id.startsWith('@') ? id.substring(1) : id;
    return UserSummary(
      uid: cleanHandle,
      username: cleanHandle,
      nickname: name,
      imageUrl: imageURL,
    );
  }
}
