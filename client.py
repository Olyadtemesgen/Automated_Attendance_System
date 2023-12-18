# import os
# testing_path = "/home/olitye/Code/AI/CNN/Face-Images/Final Testing Images/"
# training_path = "/home/olitye/Code/AI/CNN/Face-Images/Final Training Images/"

# # go through all the folders in the testing path and change the name to name-A-{gender}-{id}

# idx = 1
# for folder in os.listdir(testing_path):
    
#     folder_path = testing_path + folder

#     folder_name = folder.split('-')[0]
#     os.rename(folder_path, folder_name + '-A-M-{}'.format(idx))
#     idx += 1

# idx = 1
# for folder in os.listdir(training_path):
    
#     folder_path = training_path + folder
#     folder_name = folder.split('-')[0]
#     os.rename(folder_path, folder_name + '-A-M-{}'.format(idx))
#     idx += 1

from train import train_model as train

train()