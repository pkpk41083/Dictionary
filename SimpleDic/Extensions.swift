//
//  Extension.swift
//  SimpleDic
//
//  Created by Yukai Chang on 2021/6/22.
//

import UIKit

enum UserDefaultsKey: String {
    case allVocs = "allVocs"
    case longTermVocs = "longTermVocs"
}

extension Date {
    func getString () -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd"
        
        return formatter.string(from: self)
    }
}

extension String {
    enum Bound {
        case upper
        case lower
    }
    
    func estimateDays () -> Int {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd"
        
        guard let date = formatter.date(from: self) else {
            return 0
        }
        
        let todayTimestamp = formatter.date(from: Date().getString())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        let dateTimestamp = date.timeIntervalSince1970
        
        return Int((todayTimestamp - dateTimestamp) / 86400)
    }
    
    func indicesOf(string: String, bound: Bound) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex, let range = self.range(of: string, range: searchStartIndex..<self.endIndex), !range.isEmpty {
            let index = distance(from: self.startIndex, to: bound == .lower ? range.lowerBound : range.upperBound)
            
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

extension UIView {
    func rotate (angle: CGFloat) {
        let radians = angle / 180 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        
        self.transform = rotation
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func removeRoundCorner () {
        self.layer.mask = nil
    }
}

extension UIColor {
    convenience init (hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIViewController {
    func tapAnywhereToHideKeyboard () {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
}

extension Dictionary {
    func getNumberOfValues () -> Int {
        var count = 0
        
        for (_, values) in self {
            if let values = values as? Array<Any> {
                count += values.count
            } else {
                count += 1
            }
        }
        
        return count
    }
}

extension UITextField {
    func dropLastSpace () {
        if let text = self.text {
            while self.text?.last == " " {
                self.text = String(text.dropLast())
            }
        }
    }
}
