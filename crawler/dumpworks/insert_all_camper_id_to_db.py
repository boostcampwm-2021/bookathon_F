from slack_sdk import WebClient
import firebase_admin
import re
from firebase_admin import credentials
from firebase_admin import firestore

def parseDisplayName(name):
    splited = name.split('_')
    print(splited)
    alpha_name = splited[0]
    hangul_name = splited[1]
    student_type = alpha_name[0]
    camper_number = int(alpha_name[1:])
    return [alpha_name, camper_number, hangul_name, student_type]

def getDisplayName(user):
    username = user["profile"]["display_name"]
    res = re.search("^[a-zA-Z][0-9]{1,3}", username)
    if res == None:
        username = user["profile"]["real_name"]
    if re.search("^[a-zA-Z][0-9]{1,3}", username) == None:
        return None
    return username


reader = open("slack-token.txt", 'r')
token = reader.read().strip()
reader.close()
client = WebClient(token)
api_response = client.users_list()
cred = credentials.Certificate("../boostattendance-firebase.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

for user in api_response["members"]:
    displayName = getDisplayName(user)
    if displayName == None:
        continue
    parsed = parseDisplayName(displayName)
    doc = db.collection(u'CamperId').document(parsed[0])
    doc.set({
        u'CamperId': parsed[1],
        u'Name': parsed[2],
        u'Type': parsed[3]
    })

