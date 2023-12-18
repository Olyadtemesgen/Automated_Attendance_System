import face_recognition
import os
import matplotlib.pyplot as plt
import numpy as np
from keras.preprocessing import image
from PIL import Image

def recognize_faces(ImagePath: str):

    images = face_recognition.load_image_file(ImagePath)
    face_locations = face_recognition.face_locations(image)

    print("I found {} face(s) in this photograph.".format(len(face_locations)))
    images_name = []
    
    for idx, face_location in enumerate(face_locations):
        top, right, bottom, left = face_location

        top = max(0, top - 20)
        left = max(0, left -20)
        right = right + 20
        bottom = bottom + 20 

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

    return len(face_locations), images_name