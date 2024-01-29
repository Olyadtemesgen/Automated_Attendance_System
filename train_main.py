import os
import time
import pickle
from keras.applications.vgg16 import VGG16
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten
from keras.optimizers import Adam
from keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt
import numpy as np
from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import MaxPool2D
from keras.layers import Flatten
from keras.layers import Dense
from keras.optimizers import Adam
from PIL import Image 
from keras.models import load_model
from keras.preprocessing import image
import matplotlib.image as mpimg

def train_model():
    
    TrainingImagePath='/home/olitye/Code/AI/CNN/Images/Training-Images'
    TestImagePath = '/home/olitye/Code/AI/CNN/Images/Testing-Images'

    # Deep Learning CNN model to recognize face
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        shear_range=0.1,
        zoom_range=0.1,
        horizontal_flip=True)

    # Defining pre-processing transformations on raw images of testing data
    # No transformations are done on the testing images
    test_datagen = ImageDataGenerator(
            rescale=1./255
    )

    # Generating the Training Data
    training_set = train_datagen.flow_from_directory(
            TrainingImagePath,
            target_size=(64, 64),
            batch_size=32,
            class_mode='categorical')


    # Generating the Testing Data
    test_set = test_datagen.flow_from_directory(
            TestImagePath,
            target_size=(64, 64),
            batch_size=32,
            class_mode='categorical')

    
    TrainClasses=training_set.class_indices

    ResultMap={}
    for faceValue,faceName in zip(TrainClasses.values(),TrainClasses.keys()):
        ResultMap[faceValue]=faceName

    with open("ResultsMap.pkl", 'wb') as fileWriteStream:
        pickle.dump(ResultMap, fileWriteStream)

    print("Mapping of Face and its ID",ResultMap)

    OutputNeurons=len(ResultMap)
    print('\n The Number of output neurons(People): ', OutputNeurons)

    model = Sequential()

    model.add(Convolution2D(32, kernel_size=(5, 5), strides=(1, 1), input_shape=(64, 64, 3), activation='relu'))
    model.add(MaxPool2D(pool_size=(2, 2)))

    model.add(Convolution2D(64, kernel_size=(5, 5), strides=(1, 1), activation='relu'))
    model.add(MaxPool2D(pool_size=(2, 2)))

    model.add(Convolution2D(128, kernel_size=(5, 5), strides=(1, 1), activation='relu'))
    model.add(MaxPool2D(pool_size=(2, 2)))

    model.add(Convolution2D(256, kernel_size=(3, 3), strides=(1, 1), activation='relu'))
    model.add(MaxPool2D(pool_size=(2, 2)))

    model.add(Flatten())

    model.add(Dense(64, activation='relu'))
    model.add(Dense(OutputNeurons, activation='softmax'))

    model.compile(loss='binary_crossentropy', optimizer=Adam(learning_rate=0.001), metrics=['accuracy'])
    
    StartTime=time.time()
    
    history = model.fit(
            training_set,
            epochs=70,
            validation_data=test_set,
        )

    EndTime=time.time()
    print("###### Total Time Taken: ", round((EndTime-StartTime)/60), 'Minutes ######')

    model.save("face_recognition_model.keras")

# train_model()