import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from datetime import datetime
from datetime import date

def getYYMMDD(date):
    year = str(date.year)[2:]
    month = str(date.month) if date.month >= 10 else "0" + str(date.month)
    day = str(date.day) if date.day >= 10 else "0" + str(date.day)
    return year + month + day

cred = credentials.Certificate("../boostattendance-firebase.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
today = datetime.now()
collection = db.collection(u'Date')
doc = collection.document(getYYMMDD(today))
doc.set({
    u'CheckInOnly': False,
    u'Date': today,
    u'IsActive': True
    })

attendanceCountCollection = db.collection(u'AttendanceCount')
doc = attendanceCountCollection.document("1")
#snapshot = doc.get().to_dict()
doc.update({
    "Count": len(collection.get())
    })

print(today, "에 성공적으로 Date 등록 완료하였습니다.")
