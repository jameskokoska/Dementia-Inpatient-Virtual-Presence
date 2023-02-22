from ast import expr_context
from math import ceil
import sounddevice as sd
from scipy.io.wavfile import write
import speech_recognition as sr

# magic line of code to make sd and google work together
sd.default.dtype = 'int32', 'int32'


class SpeechRecognizer:
    def __init__(self) -> None:
        self.freq = 44100
        self.period = 3.0
        self.rec = sr.Recognizer()

    def record_snippet(self):
        recording = sd.rec(int(self.period * self.freq),
                           samplerate=self.freq, channels=2)
        sd.wait()
        FILENAME = "snippet.wav"
        write(FILENAME, self.freq, recording)
        with sr.AudioFile(FILENAME) as src:
            return self.rec.record(src)

    def recognize_speech(self, audio):
        return self.rec.recognize_google(audio)

    def run(self, duration):
        debugPrint("All good to start talking: ")
        for _ in range(int(ceil(duration/self.period))):
            try:
                audio = self.record_snippet()
                debugPrint(self.recognize_speech(audio), end=" ", flush=True)
            except sr.UnknownValueError:
                debugPrint("{sorry I don't understand}", end=" ", flush=True)

        debugPrint("")


speech_recognizer = SpeechRecognizer()
speech_recognizer.run(20)
