//
//  ViewController.swift
//  BoostAttendance
//
//  Created by 이나정 on 2021/09/23.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {

    var camperIDList = [String]()
    @IBOutlet weak var camperIDPickerView: UITextField!
    @IBOutlet weak var letsGoButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bringCampers()
        letsGoButton.isEnabled = false
        letsGoButton.backgroundColor = UIColor(rgb: .main, alpha: 0.3)
        
        // picker View
        camperIDPickerView.tintColor = .clear
        createPickerView()
        dismissPickerView()
        
        if UserDefaults.standard.value(forKey: "myId") != nil {
            self.moveToCalender()
        }
    }
    
    private func bringCampers() {
        if let campers = UserDefaults.standard.stringArray(forKey: "campers"),
           !campers.isEmpty {
            self.camperIDList = campers
        }else{
            self.bringCampersFromDB()
        }
    }
    
    private func bringCampersFromDB(){
        db.collection("CamperId").getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var campers = [String]()
                for document in querySnapshot!.documents {
                    campers.append(document.documentID)
                }
                self.camperIDList = campers
                UserDefaults.standard.set(self.camperIDList, forKey: "campers")
            }
        })
    }
    
    @IBAction func letsGoTouched(_ sender: Any) {
        guard let text = camperIDPickerView.text else { return }
        UserDefaults.standard.setValue(text, forKey: "myId")
        self.moveToCalender()
    }
    
    private func moveToCalender(){
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckInOutViewController") as? CheckInOutViewController else { return }
        vc.navigationController?.navigationBar.topItem?.title = ""
        show(vc, sender: self)
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
        letsGoButton.backgroundColor = UIColor(rgb: .main, alpha: 1.0)
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

    convenience init(rgb: boostColor, alpha: Float) {
       self.init(
        red: (rgb.rawValue >> 16) & 0xFF,
           green: (rgb.rawValue >> 8) & 0xFF,
           blue: rgb.rawValue & 0xFF,
           alpha: alpha
       )
   }
}
