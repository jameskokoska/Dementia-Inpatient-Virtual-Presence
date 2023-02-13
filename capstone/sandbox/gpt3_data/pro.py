import os
import openai
import time


openai.api_key = os.getenv("OPENAI_API_KEY")
#  print(openai.api_key)

def get_response(s):
	response = openai.Completion.create(engine="text-davinci-003",prompt=s,temperature=0.80,max_tokens=512,top_p=1.0,frequency_penalty=0.0,presence_penalty=0.0)
	return response['choices'][0]['text']

s = "Your task is to guess what Alice said in the conversation below, marked with '???'. Alice speaks first, so she is NOT responding to Bob.\n" + \
"Format your answer as a single string marked in single quotes.\n" + \
"Alice is a 80 year old woman who is sufferring from a mild case of dementia.\n" + \
"Bob is Alice's 20 year old grandson. Bob has come to visit Alice at the hospital.\n" + \
"Alice: ???\n" + \
"Bob: " 

prompts = ["How are you doing today?",
"Do you know where you are?",
"Do you know what year it is?", 
"Do you know what season it is?", 
"Do you remember the time when <insert pleasant memory cue>?",
"How many children do you have? ",
"Do you have a spouse? What is their name?", 
"Where do you live? ",
"What are your hobbies?",
"Are you feeling scared? Afraid? Tell me more about how you are feeling. ",
"Do you like to read?",
"Today is <insert date>", 
"It is the year <insert year>", 
"It is <season> now ",
"You are in <insert name of hospital> ",
"You are in the hospital because you are sick. ",
"You must be feeling very scared right now. ",
"Tell me about your friends in school.",
"Tell me about your children. ",
]

for x in range(5):
	print(x)
	time.sleep(5)


for t in prompts:
	print("XXXXXX Starting: {}".format(t))
	cur = s + t
	for _ in range(30):
		print(get_response(cur))
		time.sleep(5)

#  print(get_response("Write me a joke about horses"))

	
	
