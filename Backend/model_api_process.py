# -*- coding: utf-8 -*-

from flask import Flask, request, jsonify
import os
import time
import preprocess
import conveting_audio_to_text

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

ALLOWED_EXTENSIONS = {'wav'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def get_timestamped_filename(filename):
    timestamp = int(time.time())  # Get current timestamp
    name, extension = os.path.splitext(filename)
    return f"{name}_{timestamp}{extension}"


@app.route('/model_file_upload', methods=['POST'])
def upload_files():
    try:
        OPENSMILE_PATH = "/home/ubuntu/opensmile-3.0-linux-x64/bin/SMILExtract"
        CONFIG_PATH = "/home/ubuntu/opensmile-3.0-linux-x64/config/egemaps/v01b/eGeMAPSv01b.conf"
        # if 'text_file' not in request.files or 'wav_file' not in request.files:
        if 'wav_file' not in request.files:
            return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200

        # text_file = request.files['text_file']
        wav_file = request.files['wav_file']

        # if text_file.filename == '' or wav_file.filename == '':
        if wav_file.filename == '':
            return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200

        # if allowed_file(text_file.filename) and allowed_file(wav_file.filename):
        if allowed_file(wav_file.filename):
            # text_file_name = os.path.join(app.config['UPLOAD_FOLDER'], get_timestamped_filename(text_file.filename))
            wav_file_name = os.path.join(app.config['UPLOAD_FOLDER'], get_timestamped_filename(wav_file.filename))

            # text_file.save(text_file_name)
            wav_file.save(wav_file_name)
            # text_file_path=os.path.abspath(text_file_name)
            wav_file_path = os.path.abspath(wav_file_name)

            # converting audion to text
            try:
                text_file_path = conveting_audio_to_text.save_transcription_to_file(wav_file_path)
                print("The file is created")
            except:
                print("Error in creating transcript file")
                return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200

            try:

                # response=preprocess.preprocess_function(OPENSMILE_PATH=OPENSMILE_PATH,
                response = preprocess.preprocess_function(OPENSMILE_PATH=OPENSMILE_PATH,
                                                          SINGLE_TEXT_FILE=text_file_path,
                                                          SINGLE_WAVE_FILE=wav_file_path,
                                                          CONFIG_PATH=CONFIG_PATH)
            except:
                print("****************Error in predicting the data via model ****************")
                return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200

            print("Response", response)
            result_out = str(response[0])
            if response[0] == 1:
                print("****************Prediction result is (HIGH) probability of Alzheimer****************")
                response_data = {
                    "message": "The given sample has high probability of Alzheimer",
                    "response_code": 200
                }
                return jsonify(response_data), 200
            #else:
            elif response[0] == 0:
                print("****************Prediction result is mimimum probability of Alzheimer****************")

                response_data = {
                    "message": "The given sample has minimal probability of Alzheimer",
                    "response_code": 400
                }
                return jsonify(response_data), 200

        return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200
    except Exception as error:
        print("Error in the process")
        return jsonify({"message": "There was an internal error please try again", "response_code": 500}), 200


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
