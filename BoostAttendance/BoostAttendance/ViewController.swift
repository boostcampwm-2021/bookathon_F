//
//  ViewController.swift
//  BoostAttendance
//
//  Created by 이나정 on 2021/09/23.
//

import UIKit
import FirebaseDatabase
import Firebase

class ViewController: UIViewController {

    let camperIDList = ["S013_김태훈", "S036_이나정", "S045_이지수"]
    @IBOutlet weak var camperIDPickerView: UITextField!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // picker View
        camperIDPickerView.tintColor = .clear
        createPickerView()
        dismissPickerView()

        
        ref = Database.database().reference()
        ref.child("Attendance").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                print(snap.key)
            }
        })
    }
}


extension ViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return camperIDList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return camperIDList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        camperIDPickerView.text = camperIDList[row]
        camperIDPickerView.font = UIFont.systemFont(ofSize: 17)
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        camperIDPickerView.inputView = pickerView
//        self.view.addSubview(camperIDPickerView)
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        camperIDPickerView.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        self.camperIDPickerView.endEditing(true)
    }
}
