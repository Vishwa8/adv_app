class Ad {
  Ad({this.adId, this.imageUrls, required this.name, required this.price, required this.description, required this.lastModified});

  String name;
  String? adId;
  double price;
  String description;
  DateTime lastModified;
  List? imageUrls;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'lastModified': lastModified,
      'imageUrls': imageUrls,
    };
  }

  factory Ad.fromMap(data, String? docId) {
    final String adId = docId!;
    final String name = data()['name'];
    final double price = data()['price'];
    final String description = data()['description'];
    final DateTime lastModified = data()['lastModified'].toDate();
    final List? imageUrls = data()['imageUrls'];

    return Ad(
        adId: adId,
        name: name,
        price: price,
        description: description,
        lastModified: lastModified,
        imageUrls: imageUrls,
    );
  }
}