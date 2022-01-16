import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/ad.dart';
import 'package:project/services/api_path.dart';

abstract class Database {
  Future<void> createAd(Ad ad);
  Future<void> updateAd(Ad ad, String adId);
  Future<void> deleteAd(Ad ad);
  Stream<List<Ad>> adsStream();
  Stream<Ad> adStream({required String adId});
  Stream<List<Ad>> filteredAdsStream(double min, double max);
  void deleteImages(List? imagesUrls);
  Future<String> uploadImage(XFile image);
}

class FirestoreDatabase implements Database {

  @override
  Future<void> createAd(Ad ad) async => await _addData(
        path: APIPath.ads(),
        data: ad.toMap(),
      );

  @override
  Future<void> updateAd(Ad ad, String adId) async => await _updateData(
    path: APIPath.ads(),
    data: ad.toMap(),
    docId: adId,
  );

  @override
  Future<void> deleteAd(Ad ad) async => await _deleteData(
    path: APIPath.ad(ad.adId),
    imagesUrls: ad.imageUrls,
  );

  @override
  Stream<Ad> adStream({required String adId}) => documentStream(
    path: APIPath.ad(adId),
    builder: (data, documentId) => Ad.fromMap(data, documentId),
  );

  @override
  Stream<List<Ad>> adsStream() {
    final path = APIPath.ads();
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();

    return snapshots.map((snapshot) =>
        snapshot.docs.map((snapshot) => Ad.fromMap(snapshot.data, snapshot.id)).toList());
  }

  @override
  Stream<List<Ad>> filteredAdsStream(double min, double max) {
    final path = APIPath.ads();
    final reference = FirebaseFirestore.instance.collection(path).where("price", isGreaterThan: min).where("price", isLessThan: max);
    final snapshots = reference.snapshots();

    return snapshots.map((snapshot) =>
        snapshot.docs.map((snapshot) => Ad.fromMap(snapshot.data, snapshot.id)).toList());
  }

  @override
  void deleteImages(List? imagesUrls) async {
    if (imagesUrls != null ) {
      for(var img in imagesUrls) {
        await FirebaseStorage.instance.refFromURL(img)
            .delete()
            .then((_) => {print('Successfully deleted $img storage item' )});
      }
    }
  }

  @override
  Future<String> uploadImage(XFile image) async {
    Reference reference =  FirebaseStorage.instance.ref().child("ADVImages").child("${DateTime.now().toString()}/${image.name}");
    UploadTask uploadTask = reference.putFile(File(image.path));
    await uploadTask.whenComplete(() {
      print(reference.getDownloadURL());
    });

    return await reference.getDownloadURL();
  }

  Future<void> _addData({required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.collection(path);
    await reference.add(data);
  }

  Future<void> _updateData({required String path, required Map<String, dynamic> data, required String docId}) async {
    final reference = FirebaseFirestore.instance.collection(path).doc(docId);
    // await reference.update({
    //   "imageUrls": "",
    // });
    await reference.set(data);
  }

  Future<void> _deleteData({required String path, List? imagesUrls}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    deleteImages(imagesUrls);
    await reference.delete();
  }

  Stream<T> documentStream<T>({
    required String path,
    required T builder(data, String documentID),
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data, snapshot.id));
  }
}
