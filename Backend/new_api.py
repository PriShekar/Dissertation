from flask import Flask, request, jsonify
import os
import time
import preprocess

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'wav', 'txt'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_timestamped_filename(filename):
    timestamp = int(time.time())  # Get current timestamp
    name, extension = os.path.splitext(filename)
    return f"{name}_{timestamp}{extension}"

@app.route('/model_file_upload', methods=['POST'])
def upload_files():
    OPENSMILE_PATH="/home/ec2-user/opensmile-3.0-linux-x64/bin/SMILExtract"
    CONFIG_PATH="/home/ec2-user/opensmile-3.0-linux-x64/config/egemaps/v01b/eGeMAPSv01b.conf"
    if 'text_file' not in request.files or 'wav_file' not in request.files:
        return jsonify({"error": "Both files must be present in the request"}), 400

    text_file = request.files['text_file']
    wav_file = request.files['wav_file']

    if text_file.filename == '' or wav_file.filename == '':
        return jsonify({"error": "Both files must be selected"}), 400

    if allowed_file(text_file.filename) and allowed_file(wav_file.filename):
        text_file_name = os.path.join(app.config['UPLOAD_FOLDER'], get_timestamped_filename(text_file.filename))
        wav_file_name = os.path.join(app.config['UPLOAD_FOLDER'], get_timestamped_filename(wav_file.filename))

        text_file.save(text_file_name)
        wav_file.save(wav_file_name)

        response=preprocess.preprocess_function(OPENSMILE_PATH=OPENSMILE_PATH,
                                       SINGLE_TEXT_FILE=text_file_name,
                                       SINGLE_WAVE_FILE=wav_file_name,
                                       CONFIG_PATH=CONFIG_PATH)
        if response:

            response_data = {
                "message": "Files uploaded successfully with result",
                "text_file_path": os.path.basename(text_file_name),
                "wav_file_path": os.path.basename(wav_file_name),
                "response_data":response
            }
            return jsonify(response_data), 200
        else:
            response_data = {
                "message": "Files uploaded successfully but no result",
                "text_file_path": os.path.basename(text_file_name),
                "wav_file_path": os.path.basename(wav_file_name),
            }
            return jsonify(response_data), 200



    return jsonify({"error": "Invalid file types"}), 400

if __name__ == '__main__':
    app.run(host="0.0.0.0",port=5000)
