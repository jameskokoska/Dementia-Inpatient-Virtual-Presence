from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from nltk.corpus import stopwords
import pickle
from nltk.stem import WordNetLemmatizer
import random
import numpy as np
import re
import nltk
from sklearn.datasets import load_files
nltk.download('stopwords')
nltk.download('wordnet')
nltk.download('omw-1.4')


text_data = load_files("datasets")
sentences, target, target_names = text_data.data, text_data.target, text_data.target_names
debugPrint(target_names)
debugPrint(target)
debugPrint(len(sentences))

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
    file_data = [s for s in sentences[i].decode(
        "utf-8").split('\n') if len(s) < 50]
    debugPrint(len(file_data))
    random.shuffle(file_data)
    file_data = file_data[:DATA_SIZE]
    # debugPrint(file_data)

    for s in file_data:
        data.append(clean(s))
        cl.append(target[i])

debugPrint(data[0], cl[0])
tfidfconverter = TfidfVectorizer(
    max_features=1500, min_df=5, max_df=0.7, stop_words=stopwords.words('english'))
# .transform() to only transform
X = tfidfconverter.fit_transform(data).toarray()
y = cl

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=0)

debugPrint("Start training")
classifier = RandomForestClassifier(n_estimators=15, random_state=0)
classifier.fit(X_train, y_train)
debugPrint("Done training")

y_pred = classifier.predict(X_test)


debugPrint(confusion_matrix(y_test, y_pred))
debugPrint(classification_report(y_test, y_pred))
debugPrint(accuracy_score(y_test, y_pred))

# Save model and vectorizer.
with open("vectorizer.pkl", "wb") as f:
    pickle.dump(tfidfconverter, f)

with open("classifier.pkl", "wb") as f:
    pickle.dump(classifier, f)
