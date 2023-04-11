# Virtual Presence Software for Agitated Inpatients with Dementia
Project completed by: James Kokoska, Yash Vardhan, Matt Agar

Completed for ECE496 Final Year Design Project at the University of Toronto

## Virtual Presence Software for Agitated Inpatients with Dementia

This project provides the code of the Dementia Assistant Application, which is developed as part of the final year design project course ECE496. The application aims to provide a familiar face and voice for dementia patients in hospitals to reduce agitation and improve their quality of life. The application runs using Flutter and allows patients to have video-call like conversations with virtual guardian recordings.

The system consists of two main components: a Python Backend Server and a Flutter iPad Application frontend interface. The frontend interface runs on an iPad using the Flutter SDK, which allows access to the device's hardware inputs such as the microphone and camera. The backend server is responsible for processing patient inputs, predicting the best response using a machine learning (ML) model, and managing the user database. The frontend interface communicates with the backend server to create guardian user accounts, capture patient inputs, and play pre-recorded videos from guardians as responses.

![image](https://user-images.githubusercontent.com/50821962/230512983-b0574fd1-793d-4f6c-8222-779291329027.png)

## Frontend
The frontend application runs on an iPad using the Flutter SDK, which provides out-of-the-box frontend libraries and allows for native functionality. The hardware inputs of the iPad, including the microphone and camera, are used to capture information about the guardian for creating pre-recorded video and audio recordings. The user database is stored on the device using SQL, and each user entry contains the file path to the pre-recorded videos, name, and related notes. The user profile is loaded when a call is initiated by the patient, and the information is retrieved from the corresponding guardian's entry in the SQL database. The frontend manages the user database, which stores information about guardian users and their pre-recorded videos. The database is implemented using SQL, which provides data integrity and efficient lookups compared to non-relational database solutions. The user entries in the database contain information such as name, file path to the pre-recorded videos, and related notes.

## Backend: AI Response Model
The AI response model is responsible for predicting the best response for a given patient input. The input to the model goes through an input preprocessing phase using Python's Natural Language Toolkit (NLTK). The raw input text is sent to the backend using Flask, and an NLTK tokenizer is used to split the input sentences into a list of words. Each word is lemmatized using an NLTK lemmatizer to extract the root word from each token. The response model is designed as a Bag of Words model, which treats each sentence as a multiset of keywords and attempts to match the set of input keywords to a response from the training dataset. The model is built as a 3-layer neural network with 128 neurons in the input layer, 64 neurons in the middle layer, and 21 neurons in the output layer, each corresponding to a single response phrase. The smaller size of the model, with approximately 213 total neurons and under 10,000 total weights, balances the trade-off between latency and accuracy. The training dataset is tailored to focus on conversations related to health and family, which are common topics for dementia patients.

The backend server communicates with the frontend interface to provide the best response given the patients input list of words.
