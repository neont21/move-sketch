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
}
