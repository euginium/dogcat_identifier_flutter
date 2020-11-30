import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  List _output;
  File _image;

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Dog Identifier'),
        elevation: 0,
      ),
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image == null
                    ? Expanded(child: Container())
                    : Image.file(_image),
                SizedBox(
                  height: 15,
                ),
                _output == null
                    ? Text('')
                    : Text(
                        '${_output[0]['label']}',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      chooseImage();
                    },
                    child: Icon(Icons.image),
                  ),
                ),
              ],
            ),
    );
  }
}
