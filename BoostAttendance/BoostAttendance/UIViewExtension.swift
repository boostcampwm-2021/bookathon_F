//
//  UIViewExtension.swift
//  BoostAttendance
//
//  Created by 이나정 on 2021/09/23.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            }
        }
    }
}
