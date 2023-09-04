import csv
import os
import numpy as np
from sklearn.ensemble import RandomForestClassifier
# from sklearn.
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, f1_score, precision_score, confusion_matrix
from sklearn.svm import SVC
import joblib

# eGeMAPS
egemaps_path ="P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\Efeatures.npy"
#print('egemaps',egemaps_path)
egemaps = np.load(egemaps_path)   
# text
text_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\\txtfeature.npy"
text_feature = np.load(text_path)
# wav
wav_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\wavaudio_feature.npy"
wav_feature = np.load(wav_path)

features = np.concatenate([egemaps, text_feature, wav_feature])

MODEL_PATH = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\ADReSSo\\trained_model.joblib"
loaded_model = joblib.load(MODEL_PATH)
expected_num_features = 1966

num_zeros = expected_num_features - features.shape[0]

padded_features = np.pad(features, (0, num_zeros), mode='constant')

# Reshape the padded features to match the expected input shape
input_features = padded_features.reshape(1, expected_num_features)
transformedfeatures = StandardScaler().fit_transform(input_features)
prediction = loaded_model.predict(transformedfeatures)
#print(dir(prediction))
print(prediction)