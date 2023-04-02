import openai
import os
import time
import json

openai.api_key = "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"
print(openai.api_key)

relevant = [[] for _ in range(21)]

for rep in range(180):
    print("starting: {}".format(rep))
    s = '''
    simulate a conversation between a late stage dimentia patient and a family member that comes to visit them in the hospital. However, the family member is only allowed to respond with one of the following phrases:

(0) How are you doing today? 
(1) Do you know where you are? 
(2) Do you know what year it is? 
(3) Do you know what season it is? 
(4) Do you remember the time when <insert pleasant memory cue>?
(5) How many children do you have? 
(6) Do you have a spouse? What is their name? 
(7) Where do you live? 
(8) What are your hobbies?
(9) Are you feeling scared? Afraid? Tell me more about how you are feeling. 
(10) Do you like to read?
(11) Today is <insert date> 
(12) It is the year <insert year> 
(13) It is <season> now 
(14) You are in <insert name of hospital> 
(15) You are in the hospital because you are sick. 
(16) You must be feeling very scared right now. 
(17) Tell me about your friends in school.
(18) Tell me about your children. 
(19) Okay.
(20) Mhhm

When acting as the family member, please indicate which phrase you are using to respond with using the number in parenthesis for the given phrase.
    '''

    msg = {"role": "system", "content": s}
    chat = openai.ChatCompletion.create(model="gpt-3.5-turbo", messages = [msg])

    reply = chat.choices[0].message.content

    conv = []
    for line in reply.splitlines():
        if line:
            conv.append(line)
    
    for i in range(len(conv)):
        for j in range(21):
            s = "(" + str(j) + ")"
            if s in conv[i]:
                if i > 0:
                    relevant[j].append(conv[i-1])
                #if i + 1 < len(conv):
                 #   relevant[j].append(conv[i + 1])
    
    time.sleep(3.1) # 20 requests per minute

intents_list = []

def get_json(id, phrases):
    tags = [
    "(0) How are you doing today? ",
    "(1) Do you know where you are? ",
    "(2) Do you know what year it is? ",
    "(3) Do you know what season it is? ",
    "(4) Do you remember the time when <insert pleasant memory cue>?",
    "(5) How many children do you have?",
    "(6) Do you have a spouse? What is their name? ",
    "(7) Where do you live? ",
    "(8) What are your hobbies?",
    "(9) Are you feeling scared? Afraid? Tell me more about how you are feeling. ",
    "(10) Do you like to read?",
    "(11) Today is <insert date> ",
    "(12) It is the year <insert year> ",
    "(13) It is <season> now ",
    "(14) You are in <insert name of hospital>",
    "(15) You are in the hospital because you are sick.",
    "(16) You must be feeling very scared right now. ",
    "(17) Tell me about your friends in school.",
    "(18) Tell me about your children. ",
    "(19) Okay.",
    "(20) Mhhm"
    ]
    intent = {}
    intent["tag"] = tags[id]
    intent["patterns"] = phrases
    intent["repsonses"] = [tags[id]]
    intent["context"] = [""]
    return intent

for i in range(21):
    intents_list.append(get_json(i, relevant[i]))

intents = {"intents": intents_list}

with open('intents.json', 'w') as f:
    json.dump(intents, f, indent=4)