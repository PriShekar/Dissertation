import os
import torch
import librosa
import numpy as np
from wav2 import WavClassifier
from transformers import Wav2Vec2Processor
from transformers import BertTokenizer
from bert import BertClassifier
#from Nets.global_clip_model import Globa_Clip


class WavFeatureExtracter(object):
    def __init__(self, fold=0):
        super().__init__()
        self.processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-base-960h")
        self.model = WavClassifier()

    
    def init_model(self, param_path):
        self.model.load_state_dict(torch.load(param_path))
    
    def draw_feature(self, file_path, save_path):
        wav_data = self.audio_func(file_path, max_len=160000)
        wav_data = wav_data.unsqueeze(dim=0)
        with torch.no_grad():
            features = self.model.extract_embeding(wav_data)
            features = features.mean(dim=0)
        features = features.detach().cpu().numpy()
        np.save(save_path, features)
    
    def audio_func(self, file_path, max_len):
        data, sr = librosa.load(file_path, sr=16000)
        N = data.shape[0]
        M = 5
        gap = (N-max_len) // M
        # M can be regarded as batch size
        ret = torch.zeros((M, max_len))
        for i in range(M):
            ret[i] = self.wav_process(data[i*gap:i*gap+max_len], sr, max_len)
        return ret
    
    def wav_process(self, data, sr, max_len):
        ret = self.processor(data,
                             sampling_rate=sr,
                             max_length=max_len,
                             padding='max_length',
                             truncation=True,
                             return_tensors="pt")
        return ret.input_values.squeeze()
    
class ScriptFeatureExtracter(object):
    def __init__(self,fold=0):
        super().__init__()
        print("Consturctor")
        self.tokenizer = BertTokenizer.from_pretrained('bert-base-uncased', do_lower_case=True)
        self.model = BertClassifier()
        #self.init_model('save_models/bert/bert-'+str(fold)+'.pth')
        #self.model.eval()
    
    def init_model(self, param_path):
        print("Init model")
        self.model.load_state_dict(torch.load(param_path))
    
    def draw_feature(self, file_path, save_path):
        print("Inside Draw_feature")
        ids, mask = self.text_func(file_path)
        features = self.model.extract_embeding(ids, mask)
        features = features.mean(dim=0)
        features = features.detach().cpu().numpy()
        np.save(save_path, features)
    
    def text_func(self, file_path):
        print("Text fun file",file_path)
        with open(file_path, 'r', encoding='utf-8') as f:
            txt = f.readlines()  # get txt information
            print('text',txt)
        encoded_dict = self.tokenizer.encode_plus(
            txt,
            add_special_tokens=True,
            max_length=256,
            truncation=True,
            padding='max_length',
            return_attention_mask=True,
            return_tensors='pt',
        )
        input_ids = encoded_dict.input_ids
        attention_mask = encoded_dict.attention_mask
        return input_ids, attention_mask

#
# txt_file_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\\recordintext.txt"
# save_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\\txtfeature.npy"
#
# textExtracter = ScriptFeatureExtracter(fold=1)
# textExtracter.draw_feature(txt_file_path, save_path)
#
# # Create an instance of WavFeatureExtracter
# wavExtracter = WavFeatureExtracter(fold=1)
#
# # Set the input audio file path and save path
# audio_file_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\Recording.wav"
# save_path = "P:\Project\MultimodalADRecognition-main\MultimodalADRecognition-main\wavaudio_feature.npy"
#
# # Draw and save features for the single audio file
# wavExtracter.draw_feature(audio_file_path, save_path)
