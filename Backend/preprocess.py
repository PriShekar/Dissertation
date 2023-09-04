import os
import csv
import numpy as np
import pretrain
from ml import ml_process


# cmd format: SMILE_CMD_HEAD + " -I " + "example.wav" + " -O " + "filename.csv"
def Extract_From_Wav(SMILE_CMD_HEAD, wavfile, savepath, instname):
    print('helo')
    print("Smile_cmd {} , wavfile= {} , savepath= {}, instname={}".format(SMILE_CMD_HEAD,wavfile,savepath,instname))
    cmd = SMILE_CMD_HEAD + " -I " + wavfile + " -O " + savepath + " -instname " + instname
    print(cmd)
    os.system(cmd)

def preprocess_function(OPENSMILE_PATH,SINGLE_WAVE_FILE,SINGLE_TEXT_FILE,CONFIG_PATH):
    # OPENSMILE_PATH = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\opensmile-3.0.1-win-x64\opensmile-3.0.1-win-x64\\bin\SMILExtract"
    #
    #
    # # Provide the path to your single audio file
    # SINGLE_WAVE_FILE = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\Recording.wav"
    #
    # # Provide the desired save path for the extracted features
    SAVE_PATH = "Efeatures.npy"
    #
    #
    # CONFIG_PATH = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\opensmile-3.0.1-win-x64\opensmile-3.0.1-win-x64\config\egemaps\\v01b\eGeMAPSv01b.conf"
    #
    print("configuration",CONFIG_PATH)
    SMILE_CMD_HEAD = OPENSMILE_PATH + " -C " + CONFIG_PATH
    print("smile_command_head",SMILE_CMD_HEAD)

    # Extract features from the single audio file
    Extract_From_Wav(SMILE_CMD_HEAD,SINGLE_WAVE_FILE, "extemp_v1.csv", 'extemp.csv')
    f = open("extemp_v1.csv", 'r')
    df = list(csv.reader(f))[-1]
    feature_vec = np.array(df[1:-1], np.double)
    print(feature_vec)
    np.save(SAVE_PATH, feature_vec)
    print(feature_vec.shape, ' ', feature_vec.dtype)


    #Importing pretrain process for the testing

    txt_file_path = SINGLE_TEXT_FILE
    print("Text_file_path=",txt_file_path)
    text_file_save_path = "txtfeature.npy"
    print("Starting Text Extractor")
    textExtracter = pretrain.ScriptFeatureExtracter(fold=1)
    textExtracter.draw_feature(txt_file_path, text_file_save_path)

    # Create an instance of WavFeatureExtracter
    wavExtracter = pretrain.WavFeatureExtracter(fold=1)

    print("Starting Text Extractor")

    # Set the input audio file path and save path
    audio_file_path = SINGLE_WAVE_FILE
    audio_file_save_path = "wavaudio_feature.npy"

    # Draw and save features for the single audio file
    wavExtracter.draw_feature(audio_file_path, audio_file_save_path)

    result=ml_process(SAVE_PATH,text_file_save_path,audio_file_save_path)

    return result






