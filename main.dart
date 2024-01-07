// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:frontend/screens/home.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Obtain a list of the available cameras on the device.
//   // final cameras = await availableCameras();

//   // Get a specific camera from the list of available cameras.
//   // final firstCamera = cameras.first;

//   runApp(
//     MaterialApp(
//       home: Home(),
//     ),
//   );
// }

// class HomePage extends StatelessWidget {
//   final CameraDescription camera;

//   const HomePage({
//     required this.camera,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Automated Attendance System'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               // Add your logout logic here
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CameraPage(camera: camera),
//                   ),
//                 );
//               },
//               child: Text('Take Attendance'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddStudentPage()),
//                 );
//               },
//               child: Text('Add Student'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CameraPage extends StatefulWidget {
//   final CameraDescription camera;

//   const CameraPage({
//     required this.camera,
//   });

//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   File? _image;

//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _takePicture() async {
//     await _initializeControllerFuture;

//     final image = await _controller.takePicture();

//     setState(() {
//       _image = File(image.path);
//     });

//     // Add logic to send the image to the backend
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Take Attendance'),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _image == null ? Text('No image taken') : Image.file(_image!),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _takePicture,
//                     child: Text('Take Picture'),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

// class AddStudentPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Student'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'ID'),
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Section'),
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Gender'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Add logic to handle file input
//               },
//               child: Text('Choose File'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add logic to save student information to the backend
//               },
//               child: Text('Save Student'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late int _pictureCount;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    _pictureCount = 0;

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String folderName = 'captured_pictures';
    final String folderPath = '${appDirectory.path}/$folderName';
    await Directory(folderPath).create(recursive: true);

    final String filePath = '$folderPath/picture_$_pictureCount.jpg';

    try {
      await _controller.takePicture();
      setState(() {
        _pictureCount++;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Camera App'),
        ),
        body: Column(
          children: [
            Expanded(
              child: CameraPreview(_controller),
            ),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
