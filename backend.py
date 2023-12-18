from flask import Flask, request
import os
from werkzeug.utils import secure_filename
import zipfile
from flask import Flask, request, render_template
import os
from werkzeug.utils import secure_filename
from predict_face import predict
from add_attendee import add_student
from train import train_model as train

app = Flask(__name__)

# Specify the folder where the uploaded zip file will be stored
UPLOAD_FOLDER = '/home/olitye/Code/AI/CNN'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/', methods=['POST', 'GET'])
def say_hello():
    return 'Hello, World!'

@app.route('/upload-images', methods=['POST'])
def upload_zip():
    # Check if a file was included in the request
    if 'file' not in request.files:
        return 'No file uploaded', 400
    
    file = request.files['file']
    
    # Check if the file has a valid filename
    if file.filename == '':
        return 'Invalid filename', 400
    
    # Save the file to the upload folder
    if file and allowed_file_zip(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        # Extract the contents of the zip file
        add_student(file_path)
        train()
        return '{} added to the class Successfully.'.format(filename).replace('.zip', '').split('-')[0]
    
    return 'Invalid file', 400

# Helper function to check if the file extension is allowed
def allowed_file_zip(filename):
    allowed_extensions = {'zip'}
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions




# Helper function to check if the file extension is allowed
def allowed_file_img(filename):
    allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions


# Specify the folder where the uploaded images will be stored
UPLOAD_FOLDER = '/home/olitye/Code/AI/CNN'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/take-attendance', methods=['GET', 'POST'])
def upload_image():
    if request.method == 'POST':
        # Check if a file was included in the request
        print(type(request.files["file"]))
        print(request.files["file"])
       
        if 'file' not in request.files:
            return 'No file uploaded', 400
        
        image = request.files['file']

        if image.filename == '':
            return 'Invalid filename', 400

        if image and allowed_file_img(image.filename):

            filename = secure_filename(image.filename)
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            image.save(file_path)
            # Predict the face in the image
            
            students, predictions, genders = predict(file_path)

            return {
                'students': students,
                'predictions': predictions, 
                "genders": genders
            }
        
        return 'Invalid file', 400
    
    return ""




# @app.route('/take-attendance', methods=['POST'])
# def take_attendance():
#     # Check if a file was included in the request
#     if 'file' not in request.files:
#         return 'No file uploaded', 400
    
#     file = request.files['file']
    
#     # Check if the file has a valid filename
#     if file.filename == '':
#         return 'Invalid filename', 400
    
#     # Save the file to the upload folder
#     if file and allowed_file_img(file.filename):
#         filename = secure_filename(file.filename)
#         file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
#         file.save(file_path)

#         # Extract the contents of the zip file
#         predict(file_path)
#         return 'Attendance Taken Successfully.'
    
#     return 'Invalid file', 400
