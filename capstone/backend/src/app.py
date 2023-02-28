
# set FLASK_APP=app.py
# flask run --host=0.0.0.0

import nltk
nltk.download('punkt')
nltk.download('wordnet')
from nltk.stem import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()
import pickle

from flask import Flask, request, jsonify
from flask_restful import Api, Resource
import json

import numpy as np
import keras

words = None
classes = None
with open("words.pkl", "rb") as f:
    words = pickle.load(f)

with open("classes.pkl", "rb") as f:
    classes = pickle.load(f)


def clean_up_sentence(sentence):
    sentence_words = nltk.word_tokenize(sentence)
    sentence_words = [lemmatizer.lemmatize(word.lower()) for word in sentence_words]
    return sentence_words

def bow(sentence, words, show_details=True):
    # tokenize the pattern
    sentence_words = clean_up_sentence(sentence)
    # bag of words - matrix of N words, vocabulary matrix
    bag = [0]*len(words)
    for s in sentence_words:
        for i,w in enumerate(words):
            if w == s:
                # assign 1 if current word is in the vocabulary position
                bag[i] = 1
                if show_details:
                    print ("found in bag: %s" % w)
    return(np.array(bag))

def predict_class(sentence, model):
    # filter out predictions below a threshold
    p = bow(sentence, words,show_details=False)
    res = model.predict(np.array([p]))[0]
    ERROR_THRESHOLD = -1 # change this later if we want only high confidence results
    results = [[i,r] for i,r in enumerate(res) if r>=ERROR_THRESHOLD]
    # sort by strength of probability
    results.sort(key=lambda x: x[1], reverse=True)
    return_list = []
    for r in results:
        return_list.append({"intent": classes[r[0]], "probability": str(r[1])})
    return return_list

model = keras.models.load_model("model.h5")

#   "0": "How are you doing today?",
#   "1": "Do you know where you are?",
#   "2": "Do you know what year it is? ",
#   "3": "Do you know what season it is? ",
#   "4": "Do you remember the time when <insert pleasant memory cue>?",
#   "5": "How many children do you have? ",
#   "6": "Do you have a spouse? What is their name?",
#   "7": "Where do you live? ",
#   "8": "What are your hobbies?",
#   "9":"Are you feeling scared? Afraid? Tell me more about how you are feeling.",
#   "10": "Do you like to read?",
#   "11": "Today is <insert date> ",
#   "12": "It is the year <insert year>",
#   "13": "It is <season> now",
#   "14": "You are in <insert name of hospital> ",
#   "15": "You are in the hospital because you are sick. ",
#   "16": "You must be feeling very scared right now. ",
#   "17": "Tell me about your friends in school.",
#   "18": "Tell me about your children.",

prev = {
    'feelings': -1,
    'questions': -1,
    'weather': -1
}


class Responder(Resource):
    def post(self):
        s = json.loads(request.data.decode('utf8'))["input_text"]
        resp = jsonify(predict_class(s, model))
        resp.status_code = 200
        return resp


app = Flask(__name__)
rest_api = Api(app)
rest_api.add_resource(Responder, "/response")
