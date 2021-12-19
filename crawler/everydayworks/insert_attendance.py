from datetime import datetime
import firebase_admin
import re
from firebase_admin import credentials
from firebase_admin import firestore

def configurate():
    configurateDB()

def configurateDB():
    cred = credentials.Certificate("../boostattendance-firebase.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    global detailCollection
    global attendanceCollection
    detailCollection = db.collection(u'AttendanceDetail')
    attendanceCollection = db.collection(u'Attendance')

def getYYMMDD(date):
    year = str(date.year)[2:]
    month = str(date.month) if date.month >= 10 else "0" + str(date.month)
    day = str(date.day) if date.day >= 10 else "0" + str(date.day)
    return year + month + day

def getTodayAttendanceDetails():
    global todayAttendanceDetails
    today = datetime.now()
    yymmdd = getYYMMDD(today)
    todayAttendanceDetails = detailCollection.where(u'Date', u'==', yymmdd).get()

def calculateAndInsertAttendance():
    global userCount
    userCount = {}

    for detail in todayAttendanceDetails:
        dic = detail.to_dict()
        if dic["CheckInTime"] != None and dic["CheckOutTime"] != None and dic["Attendance"] == False:
            doc = detailCollection.document(detail.id)
            doc.update({
                u'Attendance': True
                })
            if dic["CamperId"] in userCount:
                userCount[dic["CamperId"]] += 1
            else:
                userCount[dic["CamperId"]] = 1

    for key in userCount:
        doc = attendanceCollection.document(key)
        snapshot = doc.get().to_dict()
        doc.update({
            u'Count': int(snapshot["Count"]) + userCount[key]
            })

configurate()
getTodayAttendanceDetails()
calculateAndInsertAttendance()

