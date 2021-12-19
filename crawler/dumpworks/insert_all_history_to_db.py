from slack_sdk import WebClient
from datetime import datetime
import firebase_admin
import re
from firebase_admin import credentials
from firebase_admin import firestore

def configurate():
    reader = open("slack-token.txt", 'r')
    token = reader.read().strip()
    reader.close()
    global client
    client = WebClient(token)
    configurateUserList()
    configurateDB()

def configurateDB():
    cred = credentials.Certificate("../boostattendance-firebase.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    global collection
    collection = db.collection(u'AttendanceDetail')

def configurateUserList():
    global user_dict
    user_dict = {}
    api_response = client.users_list()

    for user in api_response["members"]:
        username = user["profile"]["display_name"]
        res = re.search("^[a-zA-Z][0-9]{1,3}", username)
        if res == None:
            username = user["profile"]["real_name"]
        user_dict[user["id"]] = username


def getChannelID():
    global channel_id
    api_response = client.conversations_list()
    for i in api_response["channels"]:
        if i["name"] == "check_in_check_out":
            channel_id = i["id"]

def getConversations():
    api_response = client.conversations_history(channel=channel_id)
    global messages
    messages = api_response["messages"]

def getThreads():
    api_response = client.conversations_replies(channel=channel_id, ts=ts_response)
    global threads
    threads = api_response["messages"]


def getYYMMDD(date):
    year = str(date.year)[2:]
    month = str(date.month) if date.month >= 10 else "0" + str(date.month)
    day = str(date.day) if date.day >= 10 else "0" + str(date.day)
    return year + month + day

def getAlphaName(username):
    return username[0:4]


def getAttendenceDetails2():
    #print(collection.get()[0].to_dict())
    yymmdd = "210917"
    document = collection.where(u'Date', u'==', yymmdd).get()[0].to_dict()
    print(document)
    return
    for idx, thread in enumerate(threads):
        if idx == 0: continue
        timedate = datetime.fromtimestamp(float(thread["ts"]))
        yymmdd = getYYMMDD(timedate)
        alpha_name = getAlphaName(user_dict[thread["user"]])
        document = collection.where(u'Date', u'==', yymmdd).where(u'CamperId', u'==', alpha_name).get()

        if len(document) > 0:
            doc = collection.document(document[0].id)
            if thread["text"].find("체크인") != -1 and document[0].to_dict()["CheckInTime"] == None:
                doc.update({
                    u'CheckInTime': timedate
                })
            elif thread["text"].find("체크아웃") != -1 and document[0].to_dict()["CheckOutTime"] == None:
                doc.update({
                    u'CheckOutTime': timedate
                })
        else:
            doc = collection.document()
            if thread["text"].find("체크인") != -1:
                doc.set({
                    u'Attendance': False,
                    u'CamperId': alpha_name,
                    u'CheckInTime': timedate,
                    u'CheckOutTime': None,
                    u'Date': yymmdd
                    })
            elif thread["text"].find("체크아웃") != -1:
                doc.set({
                    u'Attendance': False,
                    u'CamperId': alpha_name,
                    u'CheckInTime': None,
                    u'CheckOutTime': timedate,
                    u'Date': yymmdd
                    })

def getAttendenceDetails():
    timedate = datetime.fromtimestamp(float(threads[0]["ts"]))
    yymmdd = getYYMMDD(timedate)
    document = collection.where(u'Date', u'==', yymmdd).get()
    data = {}
    for index, datas in enumerate(document) :
        detailData = datas.to_dict()
        detailData["id"] = datas.id
        data[detailData["CamperId"]] = detailData

    camperIds = []
    for idx, thread in enumerate(threads):
        if idx == 0: continue
        alpha_name = getAlphaName(user_dict[thread["user"]])
        if alpha_name in camperIds : continue
        if alpha_name in data:
            peice = data[alpha_name]
            doc = collection.document(peice["id"])
            if thread["text"].find("체크인") != -1 and peice["CheckInTime"] == None:
                camperIds.append(alpha_name)
                doc.update({
                    u'CheckInTime': timedate
                })
            elif thread["text"].find("체크아웃") != -1 and peice["CheckOutTime"] == None:
                camperIds.append(alpha_name)
                doc.update({
                    u'CheckOutTime': timedate
                })
        else:
            doc = collection.document()
            if thread["text"].find("체크인") != -1:
                camperIds.append(alpha_name)
                doc.set({
                    u'Attendance': False,
                    u'CamperId': alpha_name,
                    u'CheckInTime': timedate,
                    u'CheckOutTime': None,
                    u'Date': yymmdd
                    })
            elif thread["text"].find("체크아웃") != -1:
                camperIds.append(alpha_name)
                doc.set({
                    u'Attendance': False,
                    u'CamperId': alpha_name,
                    u'CheckInTime': None,
                    u'CheckOutTime': timedate,
                    u'Date': yymmdd
                    })

configurate()
getChannelID()
getConversations()
for message in messages:
    global ts_response
    ts_response = message["ts"]
    getThreads()
    getAttendenceDetails()
