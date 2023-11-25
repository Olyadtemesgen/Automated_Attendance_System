# Automatic Attendance System

## Overview

The Automatic Attendance System is a project designed to streamline the attendance tracking process in classrooms using computer vision and face recognition techniques. This system offers three key features:

1. **Student Count:** Automatically determines the number of students present in the class using facial detection and recognition.

2. **Gender Classification:** Classifies students into male and female categories, providing insights into the gender distribution within the class.

3. **Attendance Tracking:** Monitors and records student attendance, indicating who attended the class and who did not.

## Features

- **Face Detection and Recognition:** Utilizes OpenCV and a face recognition library to detect and recognize faces in class photos.
  
- **Student Count:** Counts the number of unique faces to determine the total number of students present.

- **Gender Classification:** Optionally classifies students into male and female categories using pre-trained models.

- **Attendance Tracking:** Maintains a record of face embeddings or IDs for each session, enabling the tracking of attendance over time.

## Implementation

1. **Setup:**
    - Install the necessary dependencies by running `pip install -r requirements.txt`.

2. **Face Detection and Recognition:**
    - Use OpenCV for face detection and a face recognition library for recognition.

3. **Student Count:**
    - Keep track of unique face embeddings or IDs and count the number of unique faces.

4. **Gender Classification:**
    - Optionally use a pre-trained gender classification model or extract gender information from the face recognition model.

5. **Attendance Tracking:**
    - Maintain a database of face embeddings/IDs for each session and compare them to track attendance.

6. **Results:**
    - Display the total number of students, male and female counts, and attendance status.

## Usage

1. **Capturing Photos:**
    - Capture a group photo of the class using the provided script or tool.

2. **Run the System:**
    - Execute the main script to process the photo and obtain attendance insights.

3. **View Results:**
    - Check the console output or generated reports for student count, gender distribution, and attendance status.

## Important Notes

- Ensure proper consent from students for image capture and processing.
  
- Address privacy concerns and comply with relevant laws and regulations.

- Regularly update the face recognition model for improved accuracy.

## Contributors

- [Olyad Temesgen]
- [Naol Taye]
- [Dawit Abebe]

## Acknowledgments

- [TODO]
- [TODO]
