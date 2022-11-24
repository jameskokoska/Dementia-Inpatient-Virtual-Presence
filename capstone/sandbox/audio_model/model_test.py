import pickle
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from nltk.stem import WordNetLemmatizer

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
        print(y)
        return self.types[y]

model = AudioModel()

while True:
    s = input()
    print(model.classify(s))
