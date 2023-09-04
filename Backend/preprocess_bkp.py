import os
import csv
import numpy as np

OPENSMILE_PATH = "/home/ec2-user/opensmile-3.0-linux-x64/bin/SMILExtract"

# Provide the path to your single audio file
SINGLE_WAVE_FILE = "/home/ec2-user/recording.wav"

# Provide the desired save path for the extracted features
SAVE_PATH = "/home/ec2-user/Efeatures.npy"

CONFIG_PATH = "/home/ec2-user/opensmile-3.0-linux-x64/config/egemaps/v01b/eGeMAPSv01b.conf"

SMILE_CMD_HEAD = OPENSMILE_PATH + " -C " + CONFIG_PATH

def Extract_From_Wav(wavfile, savepath, instname):
    print('hello')
    cmd = SMILE_CMD_HEAD + " -I " + wavfile + " -O " + savepath + " -instname " + instname
    print(cmd)
    os.system(cmd)

# Extract features from the single audio file
Extract_From_Wav(SINGLE_WAVE_FILE, "/home/ec2-user/extemp_v1.csv", 'extemp.csv')
f = open("/home/ec2-user/extemp_v1.csv", 'r')
df = list(csv.reader(f))[-1]
feature_vec = np.array(df[1:-1], np.double)
print(feature_vec)
np.save(SAVE_PATH, feature_vec)
print(feature_vec.shape, ' ', feature_vec.dtype)


