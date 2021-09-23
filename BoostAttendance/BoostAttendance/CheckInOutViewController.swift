//
//  CheckInOutViewController.swift
//  BoostAttendance
//
//  Created by 이나정 on 2021/09/23.
//

import UIKit
import FSCalendar

enum boostColor:Int {
    case main = 0x0055FB
    case back = 0x1C2137
}

class CheckInOutViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 선택날짜, 오늘 날짜 색 없애기
        calendarView.appearance.eventDefaultColor = .clear
        calendarView.appearance.eventSelectionColor = .clear
        
        // header
//        calendarView.appearance.headerTitleAlignment = .left
//        calendarView.layer.a
        
        
        calendarDateColorSetting()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        calendarView.delegate = self
        calendarView.dataSource = self
    }
    
    func beforeAfterMonth(moveUp: Bool) {
//        dateComponents.month = moveUp ? 1 : -1 self.currentPage = calendarCurrent.date(byAdding: dateComponents, to: self.currentPage ?? self.today) self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendarDateColorSetting() {
        // 배경색
        calendarView.backgroundColor = UIColor(rgb: .main, alpha: 0.05)
        calendarView.scrollEnabled = true // 스크롤
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
        calendarView.appearance.headerMinimumDissolvedAlpha = 0
    }
}
