from datetime import datetime
import firebase_admin
import re
from firebase_admin import credentials
from firebase_admin import firestore

def configurate():
    configurateDB()
    configurateDateDict()

def configurateDB():
    cred = credentials.Certificate("../boostattendance-firebase.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    global detailCollection
    global attendanceCollection
    global dateCollection
    detailCollection = db.collection(u'AttendanceDetail')
    attendanceCollection = db.collection(u'Attendance')
    dateCollection = db.collection(u'Date')

def configurateDateDict():
    global dateDict
    dateDict = {}
    dates = dateCollection.get()
    for date in dates:
        dateDict[date.id] = date.to_dict()

def getAllAttendanceDetails():
    global allAttendanceDetails
    allAttendanceDetails = detailCollection.get()

def calculateAndInsertAttendance():
    global userCount
    userCount = {}

    for detail in allAttendanceDetails:
        dic = detail.to_dict()
        if (dic["CheckInTime"] != None and dic["CheckOutTime"] != None and dic["Attendance"] == False) or \
            (dic["CheckInTime"] != None and dateDict[dic["Date"]]["CheckInOnly"] == True):
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
getAllAttendanceDetails()
calculateAndInsertAttendance()

