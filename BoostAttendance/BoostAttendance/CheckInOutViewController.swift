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
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarDateColorSetting()
        deselectDate()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendarView.delegate = self
        calendarView.dataSource = self
        self.camperId = UserDefaults.standard.value(forKey: "myId") as? String
        checkAttendance()
        
//        todo - remove back text
//        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func checkAttendance() -> Void {
        guard let camperId = camperId else { return }
        
        Firestore.firestore().collection("Attendance").document(camperId).getDocument(completion: { (document, error) in
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
        
        Firestore.firestore().collection("AttendanceCount").document("1").getDocument(completion: { (document, error) in
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
}
