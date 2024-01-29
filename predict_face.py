import face_recognition
import os
from PIL import Image
from keras.preprocessing import image
import numpy as np
from keras.models import load_model
import pickle
from sheet import mark_attendance, count_males_and_females
import datetime
from keras.models import load_model

def load_result_map(result_map_file):
    with open(result_map_file, 'rb') as f:
        result_map = pickle.load(f)
    return result_map

def predict(image_path):
    
    images = face_recognition.load_image_file(image_path)

    # make the image to have greatest resolution
    from PIL import Image
    img = Image.open(image_path)

    face_locations = face_recognition.face_locations(images, model="hoc")
    
    print("I found {} face(s) in this photograph.".format(len(face_locations)))
    images_name = []

    today = datetime.date.today()
    attendance_date = today.strftime("%d/%m/%Y")

    attendance_date = attendance_date + " " + str(datetime.datetime.now().hour)

    # add the current hour to attendance_date

    for idx, face_location in enumerate(face_locations):
        top, right, bottom, left = face_location

        top = max(0, top - 100)
        left = max(0, left - 100)
        right = min(images.shape[1], right + 100)
        bottom = min(images.shape[0], bottom + 100)

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

    for image_paths in images_name:
        test_image=image.load_img(image_paths,target_size=(64, 64))
        
        test_image=image.img_to_array(test_image)
        test_image=test_image/255

        test_image=np.expand_dims(test_image,axis=0)

        model = load_model('face_recognition_model.keras')

        predictions = model.predict(test_image)

        result=model.predict(test_image,verbose=0)

        result_map = load_result_map('ResultsMap.pkl')  

        print('####'*10)
        print('Prediction is: ',result_map[np.argmax(result)])
        
        print("image name", image_paths)
        # print the maximum probability
        print("Maximum probability is: ", np.max(result))
        while np.argmax(result) in is_already_predicted:
            result[0][np.argmax(result)] = -1
        
        is_already_predicted.add(np.argmax(result))

        if np.max(result) > 0.5:
            predictions_arr.append(result_map[np.argmax(result)])

            name, section, gender, id = result_map[np.argmax(result)].split('-')
            mark_attendance(name, id, section, attendance_date, gender)
        
    for image_paths in images_name:
        if os.path.exists(image_paths):
            os.remove(image_paths)
    
    # delete the file in file_path
    if os.path.exists(image_path):
        os.remove(image_path)
        
    male, female = count_males_and_females(attendance_date)
    return len(face_locations), predictions_arr, {"male": male, "female": female}