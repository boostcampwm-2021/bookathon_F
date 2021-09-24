//
//  CheckInOutViewController.swift
//  BoostAttendance
//
//  Created by 이나정 on 2021/09/23.
//

import UIKit
import FSCalendar
import FirebaseFirestore

enum boostColor:Int {
    case main = 0x0055FB
    case back = 0x1C2137
}

class CheckInOutViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var myAttendance: UILabel?
    @IBOutlet weak var totalAttendance: UILabel?
    @IBOutlet weak var myAbsence: UILabel?
    
    private var camperId: String? = nil
    private var rollBook: [QueryDocumentSnapshot]? = nil
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarDateColorSetting()
        deselectDate()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendarView.rowHeight = 50
        calendarView.delegate = self
        calendarView.dataSource = self
        self.camperId = UserDefaults.standard.value(forKey: "myId") as? String
        checkAttendance()
        bringCalender()
        
//        todo - remove back text
//        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    @IBAction func resetButtonTouched(sender: Any?){
        guard let camperId = camperId else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let today = dateFormatter.string(from: Date())
        if let date = dateFormatter.calendar.date(byAdding: DateComponents(day: -1), to: Date()){
            let yesterday = dateFormatter.string(from: date)
            self.db.collection("AttendanceDetail").whereField("CamperId", isEqualTo: camperId).whereField("Date", in : [today, yesterday])
                .getDocuments(completion: { (querySnapshot, err) in
                self.drawCalender(data: querySnapshot?.documents, reset: true)
            })
        }
    }
    
    private func checkAttendance() -> Void {
        guard let camperId = camperId else { return }
        
        self.db.collection("Attendance").document(camperId).getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                let count = document.data()?["Count"] as? Int ?? 0
                if let text = self.totalAttendance?.text,
                   let totalCount = Int(text){
                    self.myAbsence?.text = "\(totalCount - count)"
                }
                self.myAttendance?.text = "\(count)"
            } else {
                print("Document does not exist")
            }
        })
        
        self.db.collection("AttendanceCount").document("1").getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                let totalCount = document.data()?["Count"] as? Int ?? 0
                if let text = self.myAttendance?.text,
                   let count = Int(text){
                    self.myAbsence?.text = "\(totalCount - count)"
                }
                self.totalAttendance?.text = "\(totalCount)"
            } else {
                print("Document does not exist")
            }
        })
    }
    
    private func bringCalender() -> Void {
        guard let camperId = camperId else { return }
        
        if self.rollBook != nil {
            self.drawCalender(data: self.rollBook)
        } else {
            self.db.collection("AttendanceDetail").whereField("CamperId", isEqualTo: camperId).getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.rollBook = querySnapshot!.documents
                    self.drawCalender(data: self.rollBook)
                }
            })
        }
    }
    
    private func drawCalender(data: [QueryDocumentSnapshot]?, reset: Bool = false){
        guard let rollBook = data else { return }
        for snapshot in rollBook {
            let data:[String:Any] = snapshot.data()
            if let date = data["Date"] as? String {
                var day: Date? = nil
                self.db.collection("Date").document(date).getDocument(completion: { (document, error) in
                    var isCheckInOnly = false
                    if let document = document, document.exists {
                        day = (document.data()?["Date"] as? Timestamp)?.dateValue()
                        isCheckInOnly = (document.data()?["CheckInOnly"] as? Bool) ?? false
                    }
                    if let day = day,
                       let cell = self.calendarView.cell(for: day, at: .current) {
                        if reset { self.removeIcons(cell: cell) }
                        var check = true
                        if ((data["CheckInTime"]) is Timestamp) {
                            self.drawDate(cell: cell, image: "checkin")
                        }else{
                            check = false
                        }
                        if (data["CheckOutTime"] is Timestamp) {
                            self.drawDate(cell: cell, image: "checkout")
                        }else if(!isCheckInOnly){
                            check = false
                        }
                        if check == false {
                            self.drawDate(cell: cell, image: "absent")
                        }
                    }
                })
            }
        }
    }
    
    
    private func drawDate(cell: FSCalendarCell, image: String){
        var frame = CGRect.zero
        frame.size = CGSize(width: 35, height: 35)
        var x:CGFloat = 8
        var y: CGFloat = 3
        switch image {
        case "checkin":
            x += 0
            y += -3
        case "checkout":
            x += 4
            y += 3
        default:
            x += 2
            y += 0
        }
        frame.origin = CGPoint(x: frame.origin.x + x, y: frame.origin.y + y)
        let checkInView = UIImageView(frame: frame)
        if let image = UIImage(named: image){
            checkInView.image = image
        }
        cell.addSubview(checkInView)
    }
    
    private func removeIcons(cell: FSCalendarCell){
        if cell.subviews.count > 1 {
            for (index, view) in cell.subviews.enumerated() where index != 0 {
                view.removeFromSuperview()
            }
        }
    }
    
    func calendarDateColorSetting() {
        calendarView.backgroundColor = UIColor(rgb: .main, alpha: 0.05)
        calendarView.scrollDirection = .horizontal // 가로 스크롤
        calendarView.appearance.titleDefaultColor = UIColor(rgb: .back, alpha: 1.0) // 평일 날짜색
        calendarView.appearance.titleWeekendColor = UIColor(rgb: .back, alpha: 0.5) // 주말 날짜색
        calendarView.appearance.titleFont = UIFont.boldSystemFont(ofSize: 15)
        // 2021년 9월
        calendarView.appearance.headerDateFormat = "YYYY년 M월"
        calendarView.appearance.headerTitleColor = UIColor(rgb: .back, alpha: 1.0)
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18)
        calendarView.appearance.weekdayTextColor = UIColor(rgb: .main, alpha: 1.0) // Sun, Mon...
        // 년월에 흐릿하게 보이는 애들 없애기
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.2
    }
    
    func deselectDate() {
        calendarView.today = nil
        calendarView.allowsSelection = false
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.removeIcons(cell: cell)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.drawCalender(data: self.rollBook)
    }
}
