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

struct DateStructure {
    var day : Int
    var month : Int
    var year : Int
    
    static func areEqual(date1: DateStructure, date2: DateStructure) -> Bool {
        if date1.day == date2.day && date1.month == date2.month && date1.year == date2.year {
            return true
        }
        else {
            return false
        }
    }
    
    static func isDateInBetween(middleDate: DateStructure, lowerDate: DateStructure, higherDate: DateStructure) -> Bool {
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
    
    func getNextDay() -> DateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateNS = formatter.dateFromString("\(self.year)-\(self.month)-\(self.day)")!
        let nextDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: dateNS, options: NSCalendarOptions(rawValue: 0))!.stripAttributes()
        return nextDay.convertToDateStructure()
    }
    
    func getPreviousDay() -> DateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateNS = formatter.dateFromString("\(self.year)-\(self.month)-\(self.day)")!
        let previousDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: dateNS, options: NSCalendarOptions(rawValue: 0))!.stripAttributes()
        return previousDay.convertToDateStructure()
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
    var eventDate : NSDate
    var highlightType : EventType
    
    init(eventDate: NSDate, highlightType : EventType) {
        self.eventDate = eventDate
        self.highlightType = highlightType
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
    var startDate : DateStructure
    var endDate : DateStructure
    var isSingleDayEvent: Bool {
        return DateStructure.areEqual(startDate, date2: endDate)
    }
    
    init(continuousEvent: continuousEventStruct) {
        startDate = continuousEventsSplitStruct.convertDate(continuousEvent.startDate)
        endDate = continuousEventsSplitStruct.convertDate(continuousEvent.endDate)
    }
    
    static func convertDate(date: NSDate) -> DateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let localDateTime = formatter.stringFromDate(date)
        return DateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
    }
}

enum ContinuousEventHighlightType {
    case StartDate
    case IntermediateDate
    case EndDate
}

enum CalendarType {
    case ElaborateVertical
    case SimpleVertical
    case SimpleHorizontal
}

enum StringType {
    case ThreeLetterAllUpper
    case FullAllUpper
    case ThreeLetterAllButFirstLower
    case FullAllButFirstLower
}

enum EventType {
    
    case ConfirmedEvent
    case UnconfirmedEvent
    case StartUnavailable
    case EndUnavailable
    case IntermediateUnavailable
    case SingleDayUnavailable
    
}

extension Int {
    
}

extension NSDate {
    
    func convertToDateStructure() -> DateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let localDateTime = formatter.stringFromDate(self)
        return DateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
    }
    
    func stripAttributes() -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.dateFromString(formatter.stringFromDate(self))!
    }
}

extension String
{
    func substringFromIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func substringToIndex(index: Int) -> String
    {
        if (index < 0 || index > self.characters.count)
        {
            print("index \(index) out of bounds")
            return ""
        }
        return self.substringToIndex(self.startIndex.advancedBy(index))
    }
    
    func substringWithRange(start: Int, end: Int) -> String
    {
        if (start < 0 || start > self.characters.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if end < 0 || end > self.characters.count
        {
            print("end index \(end) out of bounds")
            return ""
        }
        let range = Range(start: self.startIndex.advancedBy(start), end: self.startIndex.advancedBy(end))
        return self.substringWithRange(range)
    }
    
    func substringWithRange(start: Int, location: Int) -> String
    {
        if (start < 0 || start > self.characters.count)
        {
            print("start index \(start) out of bounds")
            return ""
        }
        else if location < 0 || start + location > self.characters.count
        {
            print("end index \(start + location) out of bounds")
            return ""
        }
        let range = Range(start: self.startIndex.advancedBy(start), end: self.startIndex.advancedBy(start + location))
        return self.substringWithRange(range)
    }
}