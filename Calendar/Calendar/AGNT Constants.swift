//
//  File.swift
//  Calendar
//
//  Created by Vishal on 9/15/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit

enum daysOfWeekFormat {
    case SingleLetter
    case ThreeLetters
    case FullName
}

enum monthOfYear: String {
    case January = "January"
    case February = "February"
    case March = "March"
    case April = "April"
    case May = "May"
    case June = "June"
    case July = "July"
    case August = "August"
    case September = "September"
    case October = "October"
    case November = "November"
    case December = "December"
}

struct dateStructure {
    var day : Int
    var month : Int
    var year : Int
}

struct monthYearStructure {
    var fromMonth : Int
    var fromMonthName : String
    var fromYear : Int
    var toMonth : Int
    var toMonthName : String
    var toYear : Int
}

let monthDictionary = [1:"January",2:"February",3:"March",4:"April",5:"May",6:"June",7:"July",8:"August",9:"September",10:"October",11:"November",12:"December"]
let defaultFrameForCalendar = CGRect(x: 0, y: 0, width: 375, height: 299)
let defaultFontForCalendar = UIFont(name: "HelveticaNeue-Light", size: 16)