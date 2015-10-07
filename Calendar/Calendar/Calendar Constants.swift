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
    
    static func areEqual(date1: dateStructure, date2: dateStructure) -> Bool {
        if date1.day == date2.day && date1.month == date2.month && date1.year == date2.year {
            return true
        }
        else {
            return false
        }
    }
    
    static func isDateInBetween(middleDate: dateStructure, lowerDate: dateStructure, higherDate: dateStructure) -> Bool {
        let middleString = String(middleDate.year) + toDateString(middleDate.month) + toDateString(middleDate.day)
        let lowerString = String(lowerDate.year) + toDateString(lowerDate.month) + toDateString(lowerDate.day)
        let higherString = String(higherDate.year) + toDateString(higherDate.month) + toDateString(higherDate.day)
        
        if Int(middleString) > Int(lowerString) && Int(middleString) < Int(higherString) {
            return true
        }
        else {
            return false
        }
    }
    
    static func toDateString(dateInt: Int) -> String {
        let dateStringInitial = String(dateInt)
        if dateStringInitial.characters.count < 2 {
            return "0" + dateStringInitial
        }
        else {
            return dateStringInitial
        }
    }
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
let defaultFontForCalendar = UIFont(name: "HelveticaNeue-Light", size: 13)

struct eventHighlightStruct {
    var highlightImage : UIImage
    var eventsList : [NSDate]
    var highlightColor : UIColor
    
    init(highlightImage: UIImage, eventsList: [NSDate], highlightColor: UIColor) {
        self.highlightImage = highlightImage
        self.eventsList = eventsList
        self.highlightColor = highlightColor
    }
}

struct continuousEventStruct {
    var startDate : NSDate
    var endDate: NSDate
    
    var isSingleDayEvent: Bool {
        return startDate == endDate
    }
    
    init(startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

struct continuousEventsSplitStruct {
    var startDate : dateStructure
    var endDate : dateStructure
    var isSingleDayEvent: Bool {
        return dateStructure.areEqual(startDate, date2: endDate)
    }
    
    init(continuousEvent: continuousEventStruct) {
        startDate = continuousEventsSplitStruct.convertDate(continuousEvent.startDate)
        endDate = continuousEventsSplitStruct.convertDate(continuousEvent.endDate)
    }
    
    static func convertDate(date: NSDate) -> dateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let localDateTime = formatter.stringFromDate(date)
        return dateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
    }
}

enum ContinuousEventHighlightType {
    case StartDate
    case IntermediateDate
    case EndDate
}

enum CalendarType {
    case ElaborateVertical
    case SimpleHorizontal
}

extension Int {
    
}