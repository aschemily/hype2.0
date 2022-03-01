//
//  DateFormatter.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/1/22.
//

import Foundation

extension Date{
    func formatDate() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = . short
        
        return formatter.string(from: self)
    }
}
