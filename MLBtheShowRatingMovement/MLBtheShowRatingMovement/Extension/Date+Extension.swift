//
//  Date+Extension.swift
//  MLBtheShowRatingMovement
//
//  Created by eddiecheng on 2023/9/11.
//

import Foundation

extension Date {
    
    static let dateFormatter = DateFormatter()
    
    init?(string: String) {
        Date.dateFormatter.dateFormat = "yyyy/MM/dd"
        if let date = Date.dateFormatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    func toString() -> String {
        Date.dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        Date.dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        return Date.dateFormatter.string(from: self)
    }
}
