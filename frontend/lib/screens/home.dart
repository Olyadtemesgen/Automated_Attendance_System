import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[200],
          title: Center(child: Text('Attendance System')),
        ),
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // make a card with image and below a button
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => CameraPage()),
              //     );
              //   },
              //   child: Text('Take Attendance'),
              // ),

              SizedBox(
                width: double.infinity,
                height: 120,
                child: Image.asset('./assets/images/download.png'),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    // make it a card
                    // width full

                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                      padding: EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraPage()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Image.asset(
                            './assets/images/students.jpg',
                            width: 200,
                          ),
                        ),
                        Container(
                          width: 300,
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          // make a child center
                          child: Center(
                            child: Text(
                              'Take Attendance',
                              style: TextStyle(
                                // make a color blue beautiful and add a border
                                fontSize: 18,

                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AddStudentPage()),
              // );
              //   },
              //   child: Text('Add Student'),
              // ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    // make it a card
                    // width full

                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddStudentPage()),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Image.asset(
                            './assets/images/student.png',
                            width: 200,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          width: 300,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          // make a child center
                          child: Center(
                            child: Text(
                              'Add Student',
                              style: TextStyle(
                                // make a color blue beautiful and add a border
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ));
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.9, end: 1.05).animate(_controller);
  late final Animation<double> _fadeAnimation =
      Tween<double>(begin: 1, end: 0.6).animate(_controller);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  File? _image_selected;
  List<File> _images_selected = [];
  late bool _loading = false;
  late int _is_full = 0;
  late bool _attendance_taken = false;
  // Create a json object state
  late Map<String, dynamic> _attendance_result = {};
  Future<void> _select_picture() async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image_selected = File(image!.path);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _take_picture() async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.camera);

      setState(() {
        _image_selected = File(image!.path);
      });

      print(
          "iiiiiiiiiiiiiiiiimmmmmmmmmmaggggggggggggggggeeeeeeeeeeeeeeeeee path is ${_image_selected!.path}");
    } catch (e) {
      print(e);
    }
  }

  // Send to the backend that is running on the flask server locally
  Future<void> _send_image() async {
    print("Heeeeeeeeeeeeeelllllllllloooooooooooooooooooooo, ");
    try {
      // Create a multipart request

      setState(() {
        _loading = true;
      });
      var request = http.MultipartRequest(
          "POST", Uri.parse("http://192.168.48.128:5000/take-attendance"));

      // Attach the file in the request
      request.files.add(
          await http.MultipartFile.fromPath('file', _image_selected!.path));

      // Send the request
      var response = await request.send();

      setState(() {
        _attendance_taken = true;
        _loading = false;
      });
      // Get the response from the backend
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print("Response String is $responseString");

      // change the response data to an object Map<String, dynamic>
      setState(() {
        _attendance_result = jsonDecode(responseString);
      });

      print("Attendance result is $_attendance_result");
      print(_attendance_result);

      print(responseString);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: const Text('Take Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 150,
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 7),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _take_picture,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(
                            top: 40, bottom: 40, left: 10, right: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            './assets/images/camera.svg',
                            width: 50,
                          ),
                          Text(
                            'Take Picture',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(
                            top: 40, bottom: 40, left: 10, right: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: _select_picture,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            './assets/images/upload.svg',
                            width: 50,
                          ),
                          Text(
                            'Select Picture',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 7),
                ],
              ),
            ),

            // If image is slected show it
            SizedBox(height: 20),

            // If the attendance is taken add an Attendance Results Button
            _attendance_taken == true
                ?
                // ? ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => AttendanceResultsPage(
                //                 attendance_result: _attendance_result)),
                //       );
                //     },
                //     child: Text('Attendance Results'),
                //   )
                Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                              ),
                              margin:
                                  EdgeInsets.only(left: 7, right: 7, top: 20),
                              child: Container(
                                child: Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 40),
                                      backgroundColor: Colors.blue,
                                      elevation: 0,
                                      side: BorderSide(
                                          width: 0, color: Colors.blue),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AttendanceResultsPage(
                                                    attendance_result:
                                                        _attendance_result)),
                                      );
                                    },
                                    child: Text(
                                      'Attendance Results',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  )
                : Text(''),
            _image_selected == null
                ? Text(
                    'No image selected',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  )
                :
                // Make the image square and small
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.file(_image_selected!),
                    ),
                  ),

            _image_selected == null
                ? Text('')
                :
                // Make the image square and small
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    margin: EdgeInsets.only(left: 7, right: 7, top: 20),
                    child: Expanded(
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 40),
                            backgroundColor: Colors.blue,
                            elevation: 0,
                            side: BorderSide(width: 0, color: Colors.blue),
                          ),
                          onPressed: _send_image,
                          child: Text(
                            'Send Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

            SizedBox(height: 20),
            _loading == true ? CircularProgressIndicator() : Text(''),
          ],
        ),
      ),
    );
  }
}

// Add student page

// import 'package:flutter/material.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  late bool _loading = false;
  late bool _is_on_training = false;
  File? _image;
  late int _is_full = 0;
  String _folder = '';
  late int _imageId = 0;
  List<File> _image_selected = [];

  Future<void> _takePictures() async {
    // Take many images as a user wants
    for (int i = 0; i < 18; i++) {
      if (i == 0) {
        String name = nameController.text;
        String id = idController.text;
        String section = sectionController.text;
        String gender = genderController.text;

        // Create a directory for the student using the provided details
        String folderName = '$name-$id-$section-$gender';
        Directory directory = await getApplicationDocumentsDirectory();

        String studentDirectoryPath = '${directory.path}/$folderName';
        setState(() {
          _folder = studentDirectoryPath;
        });
      }
      try {
        final imagePicker = ImagePicker();
        final image = await imagePicker.pickImage(source: ImageSource.camera);

        setState(() {
          _image = File(image!.path);
        });

        print("Image path: ${_image!.path}");
        _saveStudentInformation(); // Call your function to save information
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _selectPictures() async {
    List<File> images = [];

    String name = nameController.text;
    String id = idController.text;
    String section = sectionController.text;
    String gender = genderController.text;

    // Create a directory for the student using the provided details
    String folderName = '$name-$id-$section-$gender';
    Directory directory = await getApplicationDocumentsDirectory();

    String studentDirectoryPath = '${directory.path}/$folderName';
    setState(() {
      _folder = studentDirectoryPath;
    });
    try {
      final imagePicker = ImagePicker();
      final pickedImages = await imagePicker.pickMultiImage();

      for (int i = 0; i < pickedImages.length; i++) {
        images.add(File(pickedImages[i].path));
        // print("image", images[i]);
        print("Image path: ${images[i].path}");
      }

      // Save the images to the student's directory and zip it
      setState(() {
        _image_selected = images;
      });

      _saveStudentsInformation(); // Call your function to save information
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveStudentsInformation() async {
    try {
      // Ensure the directory exists
      await Directory(_folder).create(recursive: true);
      // Move the captured image to the student's directory
      for (int i = 0; i < _image_selected.length; i++) {
        _image = _image_selected[i];
        String imagePath = '$_folder/image$_imageId.jpg';
        await _image!.copy(imagePath);

        print("Image id: $_imageId");
        print("Folder path: $_folder");
        print("Image path: $imagePath");

        // Add logic to save student information to the backend if needed
        // Clear text controllers and image after saving
        // nameController.clear();
        // idController.clear();
        // sectionController.clear();
        // genderController.clear();
        setState(() {
          _image = null;
          _imageId++;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveStudentInformation() async {
    try {
      // Ensure the directory exists
      await Directory(_folder).create(recursive: true);
      // Move the captured image to the student's directory
      if (_image != null) {
        String imagePath = '$_folder/image$_imageId.jpg';
        await _image!.copy(imagePath);
        print("Image id: $_imageId");
        print("Folder path: $_folder");
        print("Image path: $imagePath");
        setState(() {
          _image = null;
          _imageId++;
        });
      }
      // Add logic to save student information to the backend if needed
      // Clear text controllers and image after saving
      // nameController.clear();
      // idController.clear();
      // sectionController.clear();
      // genderController.clear();
      setState(() {
        _image = null;
        _imageId++;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addStudent() async {
    // Zip The folder in _folder and send it to the backend
    try {
      // Create a multipart request

      // Zip the _folder file
      final encoder = ZipEncoder();
      final archive = Archive();

      final folder = Directory(_folder);

      if (folder.listSync().isEmpty) {
        return;
      }

      await for (final file in folder.list(recursive: true)) {
        if (file is File) {
          final filePath = file.path.substring(folder.path.length + 1);
          final fileContent = await file.readAsBytes();
          archive
              .addFile(ArchiveFile(filePath, fileContent.length, fileContent));
        }
      }

      setState(() {
        _is_on_training = true;
      });

      // Encode the archive to bytes
      final List<int>? zipBytes = encoder.encode(archive);

      // Create a multipart request
      var request = http.MultipartRequest(
          "POST", Uri.parse("http://192.168.48.128:5000/upload-images"));

      request.files.add(http.MultipartFile.fromBytes('file', zipBytes!,
          filename: '${_folder}.zip'));

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        print('Zip file sent successfully');
      } else {
        print('Failed to send zip file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  // make fully rounded
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(160),
                    color: Colors.white70,
                  ),
                  child: SvgPicture.asset(
                    './assets/images/student-icon.svg',
                    width: 200,
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  // labelText: 'Gender',
                  label: RichText(
                    text: TextSpan(
                        text: 'Name',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ))
                        ]),
                  ),
                ),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  // labelText: 'Gender',
                  label: RichText(
                    text: TextSpan(
                        text: 'ID',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ))
                        ]),
                  ),
                ),
              ),
              TextField(
                controller: sectionController,
                decoration: InputDecoration(
                  // labelText: 'Gender',
                  label: RichText(
                    text: TextSpan(
                        text: 'Section',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ))
                        ]),
                  ),
                ),
              ),
              TextField(
                controller: genderController,
                decoration: InputDecoration(
                  // labelText: 'Gender',
                  label: RichText(
                    text: TextSpan(
                        text: 'Gender',
                        style: const TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Colors.red,
                              ))
                        ]),
                  ),
                ),
              ),
              // Make a grid having take Images and Select Images horizontally
              SizedBox(height: 20),
              Container(
                height: 150,
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // SizedBox(width: 7),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _takePictures,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(
                              top: 40, bottom: 40, left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              './assets/images/camera.svg',
                              width: 50,
                            ),
                            Text(
                              'Take Picture',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(
                              top: 40, bottom: 40, left: 10, right: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: _selectPictures,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              './assets/images/upload.svg',
                              width: 50,
                            ),
                            Text(
                              'Select Picture',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(width: 7),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                margin: EdgeInsets.only(left: 7, right: 7),
                child: Expanded(
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.blue,

                        elevation: 0,
                        // make its background the color of its parent

                        side: BorderSide(width: 0, color: Colors.blue),
                      ),
                      // if _folder is empty disable the button else enable it
                      onPressed: _folder == ''
                          ? null
                          : _is_on_training == true
                              ? null
                              : _addStudent,
                      //

                      child: Text(
                        'Save Student',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),

              _is_on_training == true
                  ? const Text(
                      // Make the color of the text green
                      style: TextStyle(color: Colors.green),
                      'Training in progress. It might take sometime',
                    )
                  : Text(''),
              // _image == null ? Text('No image taken') : Image.file(_image!),
            ],
          ),
        ),
      ),
    );
  }
}

// Create an attendance results page

class AttendanceResultsPage extends StatefulWidget {
  final Map<String, dynamic> attendance_result;
  const AttendanceResultsPage({Key? key, required this.attendance_result})
      : super(key: key);

  @override
  _AttendanceResultsPageState createState() => _AttendanceResultsPageState();
}

class _AttendanceResultsPageState extends State<AttendanceResultsPage> {
  var _section_chosen = "";
  @override
  Widget build(BuildContext context) {
    // Create a function to show the modal
    Future<void> _showGenderModalAttendance() async {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Modal BottomSheet'),
                  ElevatedButton(
                    child: const Text('Close BottomSheet'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Future<void> _dialogBuilder(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            title: const Text('Selection by Gender'),
            // Create two lines having Male: {}  and Female: {}

            content: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Male",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '${widget.attendance_result["genders"]["male"]}',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                  Text(
                    "______________________",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Female",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '${widget.attendance_result["genders"]["female"]}',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                  // make a line
                  Text(
                    "______________________",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '${widget.attendance_result["genders"]["male"] + widget.attendance_result["genders"]["female"]}',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Text(
                    "______________________",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      );
    }

    // Create a function to show the modal
    Future<void> _showSectionDropdownAttendance() async {}

    var students = widget.attendance_result["predictions"];

    var section_set = Set<String>();

    for (int i = 0; i < students.length; i++) {
      section_set.add(students[i].split("-")[1]);
    }

    var section_list = section_set.toList();

    print("rebuilding");
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Results'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Center(
        // change the background color to #bbb

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Filter Methods:",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.8, 40),
                      // backgroundColor: Colors.blue,
                      elevation: 0,
                      side: BorderSide(width: 2, color: Colors.blue),
                    ),
                    onPressed: () => _dialogBuilder(context),
                    child: Center(
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              // border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          // margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          child: Text('Select by Gender',
                              style: TextStyle(color: Colors.blue),
                              textAlign: TextAlign.center)),
                    )),
              ),
            ),
            SizedBox(height: 20),
            // Select by Section
            Center(
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.blue,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  // color: Colors.blue,
                ),
                // child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10.0),
                //       ),
                //       minimumSize:
                //           Size(MediaQuery.of(context).size.width * 0.8, 40),
                //       // backgroundColor: Colors.blue,
                //       elevation: 0,
                //       side: BorderSide(width: 2, color: Colors.blue),
                //     ),
                //     onPressed: () => _showSectionModalAttendance(),
                //     child: Center(
                //       child: Container(
                //           width: double.infinity,
                //           decoration: BoxDecoration(
                //               // border: Border.all(color: Colors.blue, width: 1),
                //               borderRadius: BorderRadius.circular(10)),
                //           // margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                //           child: Text('Select by Section',
                //               style: TextStyle(color: Colors.blue),
                //               textAlign: TextAlign.center)),
                //     )),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text("Select By Section",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center),
                    // icon: const Icon(Icons.arrow_downward),
                    iconSize: 28,

                    elevation: 16,
                    // style: const TextStyle(color: Colors.blue),
                    style: TextStyle(color: Colors.blue),
                    isExpanded: true,
                    // underline: Container(
                    //   height: 2,
                    //   color: Colors.blue,
                    // ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _section_chosen = newValue!;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => TotalAttendanceBySection(
                                attendance_result: widget.attendance_result,
                                section: _section_chosen)),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),

                    iconEnabledColor: Colors.blue,

                    items: section_list
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        onTap: () {
                          setState(() {
                            _section_chosen = value;
                          });
                          // route to a new page that shows the attendance and using the section
                        },
                        child: Center(
                          child: Text(value,
                              style: TextStyle(color: Colors.blue),
                              textAlign: TextAlign.center),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   child: Text('Total Attendance'),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => TotalAttendancePage(
            //               attendance_result: widget.attendance_result)),
            //     );
            //   },
            // )

            SizedBox(height: 20),
            // Total Attendance
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize:
                          Size(MediaQuery.of(context).size.width * 0.8, 40),
                      // backgroundColor: Colors.blue,
                      elevation: 0,
                      side: BorderSide(width: 2, color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TotalAttendancePage(
                                attendance_result: widget.attendance_result)),
                      );
                    },
                    child: Center(
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              // border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          // margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          child: Text('Total Attendance',
                              style: TextStyle(color: Colors.blue),
                              textAlign: TextAlign.center)),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a total attendance page

class TotalAttendancePage extends StatefulWidget {
  final Map<String, dynamic> attendance_result;
  const TotalAttendancePage({Key? key, required this.attendance_result})
      : super(key: key);

  @override
  _TotalAttendancePageState createState() => _TotalAttendancePageState();
}

class _TotalAttendancePageState extends State<TotalAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Attendance'),
        backgroundColor: Colors.lightBlue[200],
      ),

      // create a table having 4 columns Name, Id, Section, Gender from the attendance_result["predictions"][index]["name"] etc

      body: Column(
        children: <Widget>[
          // Header Row Widget
          Table(
            border: TableBorder.all(),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(64),
              3: FixedColumnWidth(64),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Center(child: Text("Name")),
                  Center(child: Text("Id")),
                  Center(child: Text("Section")),
                  Center(child: Text("Gender"))
                ],
              ),
            ],
          ),
          // ListView.builder for Data Rows

          Expanded(
            child: ListView.builder(
              itemCount: widget.attendance_result["predictions"].length,
              itemBuilder: (context, index) {
                var _color;

                index % 2 == 0
                    ? _color = Colors.grey
                    : _color = Colors.grey[200];
                return Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(64),
                    3: FixedColumnWidth(64),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: BoxDecoration(
                        color: _color,
                      ),
                      children: <Widget>[
                        Center(
                          child: Text(
                              '${widget.attendance_result["predictions"][index].split("-")[0]}'),
                        ),
                        Center(
                          child: Text(
                              '${widget.attendance_result["predictions"][index].split("-")[3]}'),
                        ),
                        Center(
                          child: Text(
                              '${widget.attendance_result["predictions"][index].split("-")[1]}'),
                        ),
                        Center(
                          child: Text(
                              '${widget.attendance_result["predictions"][index].split("-")[2]}'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class TotalAttendanceBySection extends StatefulWidget

class TotalAttendanceBySection extends StatefulWidget {
  final Map<String, dynamic> attendance_result;
  final String section;
  const TotalAttendanceBySection(
      {Key? key, required this.attendance_result, required this.section})
      : super(key: key);

  @override
  _TotalAttendanceBySectionState createState() =>
      _TotalAttendanceBySectionState();
}

class _TotalAttendanceBySectionState extends State<TotalAttendanceBySection> {
  @override
  Widget build(BuildContext context) {
    var _selected_by_section = [];
    for (var i = 0; i < widget.attendance_result["predictions"].length; i++) {
      widget.attendance_result["predictions"][i].split("-")[1] == widget.section
          ? _selected_by_section.add(widget.attendance_result["predictions"][i])
          : null;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Section ${widget.section} Attendance"),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Column(
        children: <Widget>[
          // Header Row Widget
          Table(
            border: TableBorder.all(),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(64),
              3: FixedColumnWidth(64),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Center(child: Text("Name")),
                  Center(child: Text("Id")),
                  Center(child: Text("Section")),
                  Center(child: Text("Gender"))
                ],
              ),
            ],
          ),
          // ListView.builder for Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: _selected_by_section.length,
              itemBuilder: (context, index) {
                var _color;

                index % 2 == 0
                    ? _color = Colors.grey
                    : _color = Colors.grey[200];
                return Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(64),
                    3: FixedColumnWidth(64),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: BoxDecoration(
                        color: _color,
                      ),
                      children: <Widget>[
                        Center(
                          child: Text(
                              '${_selected_by_section[index].split("-")[0]}'),
                        ),
                        Center(
                          child: Text(
                              '${_selected_by_section[index].split("-")[3]}'),
                        ),
                        Center(
                          child: Text(
                              '${_selected_by_section[index].split("-")[1]}'),
                        ),
                        Center(
                          child: Text(
                              '${_selected_by_section[index].split("-")[2]}'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
