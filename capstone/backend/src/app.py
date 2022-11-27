import pickle
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from nltk.stem import WordNetLemmatizer
from flask import Flask, request, jsonify
from flask_restful import Api, Resource
import json

stemmer = WordNetLemmatizer()

def clean(document):
    # Remove all the special characters
    document = re.sub(r'\W', ' ', document)
    
    # remove all single characters
    document = re.sub(r'\s+[a-zA-Z]\s+', ' ', document)
    
    # Remove single characters from the start
    document = re.sub(r'\^[a-zA-Z]\s+', ' ', document) 
    
    # Substituting multiple spaces with single space
    document = re.sub(r'\s+', ' ', document, flags=re.I)
    
    # Removing prefixed 'b'
    document = re.sub(r'^b\s+', '', document)
    
    # Converting to Lowercase
    document = document.lower()
    
    # Lemmatization
    document = document.split()

    document = [stemmer.lemmatize(word) for word in document]
    document = ' '.join(document)
    return document


class AudioModel:
    def __init__(self) -> None:
        self.types = ['feelings', 'questions', 'weather']
        with open("classifier.pkl", "rb") as f:
            self.classifier = pickle.load(f)
        with open("vectorizer.pkl", "rb") as f:
            self.vectorizer = pickle.load(f)
    
    def classify(self,s):
        s = clean(s)
        X = self.vectorizer.transform([s]).toarray()
        y = self.classifier.predict(X)[0]
        return self.types[y]

model = AudioModel()
#  types = ['feelings', 'questions', 'weather']

import random

responses = {
    'feelings': [0,1,4,5,6,8,9,10,17,18],
    'questions': [11,12,14,15,16],
    'weather': [2,3,7,13]
}

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
        print(request.data)
        s = json.loads(request.data.decode('utf8'))["input_text"]
        print("input_text:",s)
        tp = model.classify(s)
        index = -1
        while True:
            i = random.randint(0,len(responses[tp])-1)
            if i != prev[tp]:
                print(tp)
                index = i
                prev[tp] = i
                break
        print(index)
        index = responses[tp][index]
        resp = jsonify({"response_id":index})
        resp.status_code = 200
        return resp


app = Flask(__name__)
rest_api = Api(app)
rest_api.add_resource(Responder, "/response")