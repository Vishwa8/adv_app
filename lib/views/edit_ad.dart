import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/ad.dart';
import 'package:project/services/loading_bloc.dart';
import 'package:provider/provider.dart';
import 'package:project/services/database.dart';

import 'helpers/empty_content.dart';

class EditAd extends StatelessWidget {

  static Widget create({required BuildContext context, adId, name, price, description, imageUrls}) {
    return Provider<LoadingBloc>(
      create: (_) => LoadingBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<LoadingBloc>(
        builder: (context, bloc, _) => EditAd(
          adId: adId,
          name: name,
          price: price,
          description: description,
          imageUrls: imageUrls,
          oldImageUrls: imageUrls,
          bloc: bloc,
        ),
      ),
    );
  }

  EditAd({
    this.adId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.oldImageUrls,
    required this.bloc,
  });

  String? adId;
  late String name;
  late double price;
  late String description;
  final LoadingBloc bloc;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList = [];
  List? imageUrls = [];
  List? oldImageUrls = [];

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit(context) async {

    if (_validateAndSaveForm()) {
      try {
        bloc.setIsLoading(true);
        final database = Provider.of<Database>(context, listen: false);

        if (oldImageUrls != null ) {
          database.deleteImages(oldImageUrls);
        }

        await _uploadFunction(_imageFileList, database);

        final ad = Ad(
          name: name,
          price: price,
          description: description,
          lastModified: DateTime.now(),
          imageUrls: imageUrls,
        );
        await database.updateAd(ad, adId!);
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
    }
    bloc.setIsLoading(false);
  }

  Future<void> _uploadFunction(List<XFile> imagesList, Database database) async {
    if (imagesList.isEmpty) return;

    try {
      imageUrls = [];
      bloc.setIsLoading(true);

      for (var img in imagesList) {
        var imageUrl = await database.uploadImage(img);
        imageUrls!.add(imageUrl.toString());
      }
    } catch (e) {
      print(e);
    }
  }

  void _selectImages() async {
    if (_imageFileList.isNotEmpty) _imageFileList.clear();

    try {
      final List<XFile>? selectedImages = await _picker.pickMultiImage();
      if (selectedImages!.isNotEmpty) {
        _imageFileList.addAll(selectedImages);
      }
      bloc.setIsLoading(false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: StreamBuilder<bool>(
          stream: bloc.isLoadingStream,
          initialData: false,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                elevation: 10,
                centerTitle: true,
                title: const Text(
                  'Edit Ad',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () => snapshot.data! ? null : _submit(context),
                  ),
                ],
              ),
              body: _buildContents(snapshot.data),
            );
          }),
    );
  }

  Widget _buildContents(isLoading) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Card(
            elevation: 10,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildForm(),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: _selectImages,
                    child: const Text(
                      "Pick Images",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 300,
                    child:
                    _imageFileList.isNotEmpty ?
                    GridView.builder(
                      itemCount: _imageFileList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: Image.file(
                            File(_imageFileList[index].path),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                        : imageUrls!.isEmpty
                        ? const Center(
                      child: EmptyContent(
                        title: "",
                        message: "Select some images to continue",
                      ),
                    )
                        : GridView.builder(
                      itemCount: imageUrls!.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: Image.network(
                            imageUrls![index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        isLoading
            ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                    'uploading...',
                    style: TextStyle(fontSize: 20),
                  ),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(),
              ],
            ))
            : Container(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Name'),
        validator: (value) => value!.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => name = value!,
        initialValue: name,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Price'),
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => price = double.tryParse(value!) ?? 0,
        initialValue: price.toString(),
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Description'),
        validator: (value) => value!.isNotEmpty ? null : 'Description can\'t be empty',
        onSaved: (value) => description = value!,
        textInputAction: TextInputAction.newline,
        initialValue: description,
        maxLines: 4,
      ),
    ];
  }
}
