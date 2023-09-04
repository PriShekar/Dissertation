import os
import speech_recognition as sr


def transcribe_audio(audio_file_path):
    recognizer = sr.Recognizer()

    with sr.AudioFile(audio_file_path) as source:
        audio_data = recognizer.record(source)

        try:
            text = recognizer.recognize_google(audio_data)
            return text
        except sr.UnknownValueError:
            # return "Could not understand audio"
            return None
        except sr.RequestError as e:
            # return "Could not request results; {0}".format(e)
            return None


def save_transcription_to_file(audio_file_path):
    base_filename = os.path.splitext(audio_file_path)[0]

    output_file_path = base_filename + ".txt"

    transcription = transcribe_audio(audio_file_path)

    if transcription == None:
        return None
    else:
        with open(output_file_path, 'w') as output_file:
            output_file.write(transcription)
            return output_file_path
        




