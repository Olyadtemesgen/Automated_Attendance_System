import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[200],
          title: Center(child: Text('Attendance System')),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Add your logout logic here
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                child: Text('Take Attendance'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddStudentPage()),
                  );
                },
                child: Text('Add Student'),
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

class _CameraPageState extends State<CameraPage> {
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
            ElevatedButton(
              onPressed: _take_picture,
              child: Text('Take Picture'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _select_picture,
              child: Text('Select Picture'),
            ),

            // If image is slected show it
            SizedBox(height: 20),

            // If the attendance is taken add an Attendance Results Button
            _attendance_taken == true
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AttendanceResultsPage(
                                attendance_result: _attendance_result)),
                      );
                    },
                    child: Text('Attendance Results'),
                  )
                : Text(''),
            _image_selected == null
                ? Text('No image selected')
                :
                // Make the image square and small
                SizedBox(
                    height: 200,
                    width: 200,
                    child: Image.file(_image_selected!),
                  ),

            _image_selected == null
                ? Text('')
                :
                // Make the image square and small
                ElevatedButton(
                    onPressed: _send_image, child: Text('Send Image')),

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
        nameController.clear();
        idController.clear();
        sectionController.clear();
        genderController.clear();
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
      nameController.clear();
      idController.clear();
      sectionController.clear();
      genderController.clear();
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: sectionController,
                decoration: InputDecoration(labelText: 'Section'),
              ),
              TextField(
                controller: genderController,
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              // Make a grid having take Images and Select Images horizontally
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                // Take Images and Select Images vertically

                children: [
                  ElevatedButton(
                    onPressed: _takePictures,
                    child: Text('Take Pictures'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectPictures,
                    child: Text('Select Pictures'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              ElevatedButton(
                // Disable it if the user has not taken or selected any images or all of the information is not provided

                onPressed: _addStudent,
                child: Text('Save Student'),
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
            title: const Text('Selection by Gender'),
            // Create two lines having Male: {}  and Female: {}

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Male"),
                    Text('${widget.attendance_result["genders"]["male"]}')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Female"),
                    Text('${widget.attendance_result["genders"]["female"]}')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Total"),
                    Text(
                        '${widget.attendance_result["genders"]["male"] + widget.attendance_result["genders"]["female"]}')
                  ],
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // Create a function to show the modal
    Future<void> _showSectionModalAttendance() async {
      // Create a list view builder to show the attendance results
      Expanded(
        child: ListView.builder(
          itemCount: widget.attendance_result.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${widget.attendance_result.keys.elementAt(index)}'),
              subtitle:
                  Text('${widget.attendance_result.values.elementAt(index)}'),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Results'),
      ),
      body: Center(
        // change the background color to #bbb

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => _dialogBuilder(context),
                child: Text('Select by Gender')),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Total Attendance'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TotalAttendancePage(
                          attendance_result: widget.attendance_result)),
                );
              },
            )
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
                  Text("Name"),
                  Text("Id"),
                  Text("Section"),
                  Text("Gender")
                ],
              ),
            ],
          ),
          // ListView.builder for Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: widget.attendance_result["predictions"].length,
              itemBuilder: (context, index) {
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
                      decoration: const BoxDecoration(
                        color: Colors.grey,
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
