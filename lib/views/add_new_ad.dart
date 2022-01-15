import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/ad.dart';
import 'package:project/services/loading_bloc.dart';
import 'package:project/views/helpers/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:project/services/database.dart';

class AddNewAd extends StatelessWidget {

  static Widget create(BuildContext context) {
    return Provider<LoadingBloc>(
      create: (_) => LoadingBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<LoadingBloc>(
        builder: (context, bloc, _) => AddNewAd(bloc: bloc),
      ),
    );
  }

  AddNewAd({required this.bloc});
  final LoadingBloc bloc;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFileList = [];
  List<String> _imageUrls = [];

  late String _name;
  late double _price;
  late String _description;

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

        await _uploadFunction(_imageFileList, database);

        final ad = Ad(
          name: _name,
          price: _price,
          description: _description,
          lastModified: DateTime.now(),
          imageUrls: _imageUrls,
        );
        await database.createAd(ad);
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
      for (var img in imagesList) {
        var imageUrl = await database.uploadImage(img);
        _imageUrls.add(imageUrl.toString());
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
                  'New Ad',
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
          })
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
                    _imageFileList.isEmpty
                        ? const Center(
                      child: EmptyContent(
                        title: "",
                        message: "Select some images to continue",
                      ),
                    )
                        : GridView.builder(
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
              children: [
                Container(
                  child: const Text(
                    'uploading...',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const CircularProgressIndicator(),
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
        onSaved: (value) => _name = value!,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Price'),
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onSaved: (value) => _price = double.tryParse(value!) ?? 0,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Description'),
        validator: (value) =>
            value!.isNotEmpty ? null : 'Description can\'t be empty',
        onSaved: (value) => _description = value!,
        textInputAction: TextInputAction.newline,
        maxLines: 4,
      ),
    ];
  }
}
