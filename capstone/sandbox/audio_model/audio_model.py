import numpy as np
import re
import nltk
from sklearn.datasets import load_files
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('omw-1.4')

import random
from nltk.stem import WordNetLemmatizer


import pickle
from nltk.corpus import stopwords

text_data = load_files("datasets")
sentences, target, target_names = text_data.data, text_data.target, text_data.target_names
print(target_names)
print(target)
print(len(sentences))

DATA_SIZE = 15*1000
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

data = []
cl = []
for i in range(len(sentences)):
    file_data = [s for s in sentences[i].decode("utf-8").split('\n') if len(s) < 50]
    print(len(file_data))
    random.shuffle(file_data)
    file_data = file_data[:DATA_SIZE] 
    # print(file_data)
    
    for s in file_data:
        data.append(clean(s))
        cl.append(target[i])

print(data[0], cl[0])
from sklearn.feature_extraction.text import TfidfVectorizer
tfidfconverter = TfidfVectorizer(max_features=1500, min_df=5, max_df=0.7, stop_words=stopwords.words('english'))
X = tfidfconverter.fit_transform(data).toarray() # .transform() to only transform
y = cl

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)

print("Start training")
from sklearn.ensemble import RandomForestClassifier
classifier = RandomForestClassifier(n_estimators=15, random_state=0)
classifier.fit(X_train, y_train) 
print("Done training")

y_pred = classifier.predict(X_test)

from sklearn.metrics import classification_report, confusion_matrix, accuracy_score

print(confusion_matrix(y_test,y_pred))
print(classification_report(y_test,y_pred))
print(accuracy_score(y_test, y_pred))

# Save model and vectorizer.
with open("vectorizer.pkl", "wb") as f:
    pickle.dump(tfidfconverter, f)

with open("classifier.pkl", "wb") as f:
    pickle.dump(classifier, f)
