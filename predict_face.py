import face_recognition
import os
from PIL import Image
from keras.preprocessing import image
import numpy as np
from keras.models import load_model
import pickle
from sheet import mark_attendance, count_males_and_females
import datetime

def load_result_map(result_map_file):
    with open(result_map_file, 'rb') as f:
        result_map = pickle.load(f)
    return result_map


image_path = "/home/olitye/Code/AI/CNN/students.jpg"

def predict(image_path):
    
    images = face_recognition.load_image_file(image_path)

    face_locations = face_recognition.face_locations(images)
    # recognize_faces(face_locations, images)
    
    print("I found {} face(s) in this photograph.".format(len(face_locations)))
    images_name = []

    today = datetime.date.today()
    attendance_date = today.strftime("%d/%m/%Y")

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

        # create a folder TestImages if not exists
        if not os.path.exists('/home/olitye/Code/AI/CNN/TestImages'):
            os.makedirs('/home/olitye/Code/AI/CNN/TestImages')
        pil_image.save("/home/olitye/Code/AI/CNN/TestImages/face_{}.jpg".format(idx))

        #save the image absolute path into images_name
        images_name.append('/home/olitye/Code/AI/CNN/TestImages/face_{}.jpg'.format(idx))

    predictions_arr = []

    is_already_predicted = set()

    for image_path in images_name:
        test_image=image.load_img(image_path,target_size=(64, 64))
        
        test_image=image.img_to_array(test_image)

        test_image=np.expand_dims(test_image,axis=0)

        model = load_model('face_recognition_model.h5')
        predictions = model.predict(test_image)

        result=model.predict(test_image,verbose=0)

        result_map = load_result_map('ResultsMap.pkl')  

        print('####'*10)
        print('Prediction is: ',result_map[np.argmax(result)])
        
        # while the maximum is already predicted, then predict the second maximum
        while np.argmax(result) in is_already_predicted:
            result[0][np.argmax(result)] = -1
        
        is_already_predicted.add(np.argmax(result))

        predictions_arr.append(result_map[np.argmax(result)])

        name, section, gender, id = result_map[np.argmax(result)].split('-')
        mark_attendance(name, id, section, attendance_date, gender)

    # # go through all the Face-Images and then go through all the child folder of it and then take the first image and then predict it
    # root_folder = "/home/olitye/Code/AI/CNN/Face-Images/Final Testing Images"

    # # Iterate over the face images
    # for folder_name in os.listdir(root_folder):
    #     folder_path = os.path.join(root_folder, folder_name)
        
    #     # Check if the item in the root folder is a directory (child folder)
    #     if os.path.isdir(folder_path):
    #         # Get the first image in the child folder
    #         images = os.listdir(folder_path)
    #         if len(images) > 0:
    #             image_path = os.path.join(folder_path, images[0])
                
    #             test_image=image.load_img(image_path,target_size=(64, 64))
    
    #             test_image=image.img_to_array(test_image)

    #             test_image=np.expand_dims(test_image,axis=0)

    #             model = load_model('face_recognition_model.h5')
    #             predictions = model.predict(test_image)

    #             result=model.predict(test_image,verbose=0)

    #             result_map = load_result_map('ResultsMap.pkl')  

    #             print('####'*10)
    #             print("foooooooooooooooooldeeeeeeeeeeeeeerrrrrrr name", folder_name)
    #             print('Prediction is: ',result_map[np.argmax(result)])

    
    # delete all the images saved
    for image_path in images_name:
        os.remove(image_path)
        
    male, female = count_males_and_females(attendance_date)
    return len(face_locations), predictions_arr, {"male": male, "female": female}