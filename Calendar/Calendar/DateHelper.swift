//
//  DateHelper.swift
//  Calendar
//
//  Created by Vishal on 9/15/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class DateHelper: NSObject {
    
    func getMaxDays(year: Int, month: Int) -> Int {
        let numberOfDays : Int
        switch month {
        case 1: numberOfDays = 31
        case 2: numberOfDays = leapCheck(year)
        case 3: numberOfDays = 31
        case 4: numberOfDays = 30
        case 5: numberOfDays = 31
        case 6: numberOfDays = 30
        case 7: numberOfDays = 31
        case 8: numberOfDays = 31
        case 9: numberOfDays = 30
        case 10: numberOfDays = 31
        case 11: numberOfDays = 30
        case 12: numberOfDays = 31
        default: numberOfDays = 0
        }
        return numberOfDays
    }
    
    func getMonthString(month: Int, stringType: StringType) -> String {
        var monthString = String()
        
        switch month {
        case 1: monthString = "January"
        case 2: monthString = "February"
        case 3: monthString = "March"
        case 4: monthString = "April"
        case 5: monthString = "May"
        case 6: monthString = "June"
        case 7: monthString = "July"
        case 8: monthString = "August"
        case 9: monthString = "September"
        case 10: monthString = "October"
        case 11: monthString = "November"
        case 12: monthString = "December"
        default: monthString = "Wrong"
        }
        if stringType == StringType.FullAllButFirstLower {
            return monthString
        }
        else if stringType == StringType.FullAllUpper {
            return monthString.uppercaseString
        }
        else if stringType == StringType.ThreeLetterAllButFirstLower {
            return monthString.substringToIndex(3)
        }
        else {
            return monthString.substringToIndex(3).uppercaseString
        }
        
    }
    
    func leapCheck(year:Int) -> Int {
        if year%4 == 0 {
            if year%100 == 0 {
                if year%400 == 0 {
                    return 29
                }
                else {
                    return 28
                }
            }
            return 29
        }
        else {
            return 28
        }
    }
    
    func getDate() -> DateStructure {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let localDateTime = formatter.stringFromDate(NSDate())
        let date = DateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
        return date
    }
    
    func getDayOfWeek(today:String) -> Int? {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return nil
        }
    }

}
