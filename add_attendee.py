import os
import zipfile
import shutil
import openpyxl
import face_recognition
import matplotlib.pyplot as plt
import numpy as np
from keras.preprocessing import image
from PIL import Image

def add_student(zipFileName: str):
    # student name is the zipped file name without the extension
    #student name has the form name-section-gender-id so we split it
    student_name = os.path.splitext(zipFileName)[0]
    name, section, gender, id = os.path.splitext(zipFileName)[0].split('-')

    # Add the student to the Excel file
    name = name.split('/')[-1]
    add_student_to_excel("/home/olitye/Code/AI/CNN/attendance/SAMPLE.xlsx", name, id, section, gender)

    # Extract the zipped file
    # Unzip the file
    with zipfile.ZipFile(zipFileName, 'r') as zip_ref:
        # Extract the contents to a temporary directory
        zip_ref.extractall(student_name)

    # Get the path to the extracted folder (student_name/student_name)
    extracted_folder = os.path.join(student_name, student_name)

    # Get the destination directory to save the unzipped file
    destination_directory = '/home/olitye/Code/AI/CNN/Face-Images/Final Training Images'

    # Move the contents of the extracted folder to the destination directory
    folder_name = ""

    for folders in os.listdir(extracted_folder):
        shutil.move(os.path.join(extracted_folder, folders), destination_directory)
        folder_name = folders

    # Remove the temporary parent folder (student_name)
    os.rmdir(student_name)
    # Go Through the images and detect only one faces and save it to that the same image file
    # Get the path to the extracted folder (student_name/student_name)

    # split the student name to get the name only
    student_name = student_name.split('/')[-1]

    images_length = len(os.listdir(destination_directory + '/' + folder_name))

    # make a directory in Final Testing Images
    if not os.path.exists('/home/olitye/Code/AI/CNN/Face-Images/Final Testing Images/' + folder_name):
        os.makedirs('/home/olitye/Code/AI/CNN/Face-Images/Final Testing Images/' + folder_name)
    
    testing_destination = '/home/olitye/Code/AI/CNN/Face-Images/Final Testing Images/' + folder_name

    for image_path in os.listdir(destination_directory + '/' + folder_name)[:images_length]:

        # move the folder out. 
        # shutil.move(destination_directory + '/' + student_name + '/' + image_path, destination_directory)

        images_length -= 1
        images = face_recognition.load_image_file(destination_directory + '/' + folder_name + '/' + image_path)

        face_locations = face_recognition.face_locations(images)
        # recognize_faces(face_locations, images)
        print("I found {} face(s) in this photograph.".format(len(face_locations)))
        images_name = []

        for idx, face_location in enumerate(face_locations):
            top, right, bottom, left = face_location

            top = max(0, top )
            left = max(0, left )
            right = right 
            bottom = bottom 

            # print("A face is located at pixel location Top: {}, Left: {}, Bottom: {}, Right: {}".format(top, left, bottom, right))
            face_image = images[top:bottom, left:right]

            
            # save image in a folder TestImages
            pil_image = Image.fromarray(face_image)

            # image the image to the same path

            if images_length > 1:
                pil_image.save(destination_directory + '/' + student_name + '/' + image_path)
            
            else:
                pil_image.save(testing_destination + '/' + image_path)
                os.remove(destination_directory + '/' + folder_name + '/' + image_path)

            break
           


def is_student_unique(sheet, student_name, student_id, section, gender):
    # Iterate over rows in the sheet
    for row in sheet.iter_rows(min_row=2):
        existing_name = row[0].value
        existing_id = row[1].value
        existing_section = row[2].value
        existing_gender = row[3].value

        # Check if the student already exists in the sheet
        if (
            existing_name == student_name
            and existing_id == student_id
            and existing_section == section
            and existing_gender == gender
        ):
            return False

    return True

def add_student_to_excel(excel_file_path, student_name, student_id, section, gender):
    # Load the Excel file
    wb = openpyxl.load_workbook(excel_file_path)

    # Select the active sheet (you may need to modify this based on your Excel file structure)
    sheet = wb.active

    # Check if the student is already in the Excel file
    if not is_student_unique(sheet, student_name, student_id, section, gender):
        print("Student already exists in the Excel file.")
        wb.close()
        return

    # Find the column index of the first empty row
    row_index = sheet.max_row + 1

    # Write the student information in separate columns
    sheet.cell(row=row_index, column=1).value = student_name
    sheet.cell(row=row_index, column=2).value = student_id
    sheet.cell(row=row_index, column=3).value = section
    sheet.cell(row=row_index, column=4).value = gender

    # Save the modified Excel file
    wb.save(excel_file_path)
    wb.close()