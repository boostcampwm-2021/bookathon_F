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
    @IBOutlet weak var letsGoButton: UIButton!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        letsGoButton.isEnabled = false
        letsGoButton.backgroundColor = UIColor(rgb: 0x0055FB, alpha: 0.3)
        
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
        letsGoButton.isEnabled = true
        letsGoButton.backgroundColor = UIColor(rgb: 0x0055FB, alpha: 1.0)
        camperIDPickerView.text = camperIDList[row]
        camperIDPickerView.font = UIFont.systemFont(ofSize: 17)
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        camperIDPickerView.inputView = pickerView
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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: Float) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
   }

    convenience init(rgb: Int, alpha: Float) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF,
           alpha: alpha
       )
   }
}
