//
//  CalendarEventsModel.swift
//  Calendar
//
//  Created by Vishal on 10/16/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class CalendarEventsModel: NSObject
{

    var numberOfEventTypes = 0
    var events = [eventHighlightStruct]()
    var continuousEvents = [continuousEventStruct]()
    var continuousEventsFormatted = [continuousEventsSplitStruct]()
    
    var initialEvents = [Int: [Int: [Int: EventType]]]()
    var formattedEvents = [Int: [Int: [Int: EventType]]]() {
        didSet {
            
        }
    }
    
    func formatEvents(circularEvents: [eventHighlightStruct], continuousEvents: [continuousEventStruct]) {
        self.events = circularEvents
        self.continuousEvents = continuousEvents
        for contEvents in self.continuousEvents {
            self.continuousEventsFormatted.append(continuousEventsSplitStruct(continuousEvent: contEvents))
        }
        
        for event in events {
            let eventDate = event.eventDate.convertToDateStructure()
            if let month = formattedEvents[eventDate.year] {
                if let _ = month[eventDate.month] {
                    formattedEvents[eventDate.year]![eventDate.month]![eventDate.day] = event.highlightType
                }
                else {
                    formattedEvents[eventDate.year]![eventDate.month] = [eventDate.day: event.highlightType]
                }
            }
            else {
                formattedEvents[eventDate.year] = [eventDate.month: [eventDate.day: event.highlightType]]
            }
        }
        
        for contEvents in continuousEvents {
            let startDate = contEvents.startDate.stripAttributes()
            let endDate = contEvents.endDate.stripAttributes()
            
            let event = EventType.SingleDayUnavailable
            if DateStructure.areEqual(startDate.convertToDateStructure(), date2: endDate.convertToDateStructure()) {
                if let month = formattedEvents[startDate.convertToDateStructure().year] {
                    if let _ = month[startDate.convertToDateStructure().month] {
                        formattedEvents[startDate.convertToDateStructure().year]![startDate.convertToDateStructure().month]![startDate.convertToDateStructure().day] = event
                    }
                    else {
                        formattedEvents[startDate.convertToDateStructure().year]![startDate.convertToDateStructure().month] = [startDate.convertToDateStructure().day: event]
                    }
                }
                else {
                    formattedEvents[startDate.convertToDateStructure().year] = [startDate.convertToDateStructure().month: [startDate.convertToDateStructure().day: event]]
                }
            }
            else {
                var movingDate = startDate
                while movingDate != endDate {
                    var movingEvent = EventType.StartUnavailable
                    if movingDate == startDate {
                        movingEvent = EventType.StartUnavailable
                    }
                    else if movingDate == endDate {
                        movingEvent = EventType.EndUnavailable
                    }
                    else {
                        movingEvent = EventType.IntermediateUnavailable
                    }
                    
                    let movingDateFormatted = movingDate.convertToDateStructure()
                    if let month = formattedEvents[movingDateFormatted.year] {
                        if let _ = month[movingDateFormatted.month] {
                            formattedEvents[movingDateFormatted.year]![movingDateFormatted.month]![movingDateFormatted.day] = movingEvent
                        }
                        else {
                            formattedEvents[movingDateFormatted.year]![movingDateFormatted.month] = [movingDateFormatted.day: movingEvent]
                        }
                    }
                    else {
                        formattedEvents[movingDateFormatted.year] = [movingDateFormatted.month: [movingDateFormatted.day: movingEvent]]
                    }
                    movingDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: movingDate, options: NSCalendarOptions(rawValue: 0))!.stripAttributes()
                }
                let endDateFormatted = endDate.convertToDateStructure()
                let endEvent = EventType.EndUnavailable
                if let month = formattedEvents[endDateFormatted.year] {
                    if let _ = month[endDateFormatted.month] {
                        formattedEvents[endDateFormatted.year]![endDateFormatted.month]![endDateFormatted.day] = endEvent
                    }
                    else {
                        formattedEvents[endDateFormatted.year]![endDateFormatted.month] = [endDateFormatted.day: endEvent]
                    }
                }
                else {
                    formattedEvents[endDateFormatted.year] = [endDateFormatted.month: [endDateFormatted.day: endEvent]]
                }
            }
        }
        
        manageMismatchedUnavailability()
        manageWeekWiseUnavailability()
        manageMonthWiseUnavailability()
        initialEvents = formattedEvents
    }
    
    private func manageMismatchedUnavailability()
    {
        let yearOrderedArray = formattedEvents.sort({ (first, second) -> Bool in
            return first.0 < second.0
        })
        for (year, monthStructure) in yearOrderedArray
        {
            for (month, dayStructure) in monthStructure
            {
                var previousEnd: (day: Int, eventType: EventType) = (-2, EventType.EndUnavailable)
                let dayStructArray = dayStructure.sort({ (first, second) -> Bool in
                    return first.0 < second.0
                })
                for (day, eventType) in dayStructArray
                {
                    if (day - previousEnd.day) == 1
                    {
                        if eventType == EventType.StartUnavailable
                        {
                            if previousEnd.eventType == EventType.EndUnavailable
                            {
                                formattedEvents[year]![month]![previousEnd.day] = EventType.IntermediateUnavailable
                            }
                            else if previousEnd.eventType == EventType.SingleDayUnavailable
                            {
                                formattedEvents[year]![month]![previousEnd.day] = EventType.StartUnavailable
                            }
                            formattedEvents[year]![month]![day] = EventType.IntermediateUnavailable
                        }
                        else if eventType == EventType.SingleDayUnavailable
                        {
                            if let nextDayEvent = formattedEvents[year]?[month]?[day + 1]
                            {
                                if previousEnd.eventType == EventType.EndUnavailable || nextDayEvent == EventType.StartUnavailable
                                {
                                    formattedEvents[year]![month]![previousEnd.day] = EventType.IntermediateUnavailable
                                    formattedEvents[year]![month]![day] = EventType.IntermediateUnavailable
                                    formattedEvents[year]![month]![day + 1] = EventType.IntermediateUnavailable
                                }
                            }
                            else if previousEnd.eventType == EventType.EndUnavailable
                            {
                                formattedEvents[year]![month]![previousEnd.day] = EventType.IntermediateUnavailable
                                formattedEvents[year]![month]![day] = EventType.EndUnavailable
                            }
                            else if previousEnd.eventType == EventType.SingleDayUnavailable
                            {
                                formattedEvents[year]![month]![previousEnd.day] = EventType.StartUnavailable
                                formattedEvents[year]![month]![day] = EventType.EndUnavailable
                            }
                            
                        }
                    }
                    
                    if eventType == EventType.EndUnavailable || eventType == EventType.SingleDayUnavailable
                    {
                        previousEnd = (day, formattedEvents[year]![month]![day]!)
                    }
                }
            }
        }
    }
    
    private func manageWeekWiseUnavailability()
    {
        let yearOrderedArray = formattedEvents.sort({ (first, second) -> Bool in
            return first.0 < second.0
        })
        for (year, monthStructure) in yearOrderedArray
        {
            for (month, dayStructure) in monthStructure
            {
                var previousSaturday: (day: Int, eventType: EventType) = (-2, EventType.EndUnavailable)
                let dayStructArray = dayStructure.sort({ (first, second) -> Bool in
                    return first.0 < second.0
                })
                for (day, eventType) in dayStructArray
                {
                    let date = DateStructure(day: day, month: month, year: year).getNSDate()
                    let weekDay = DateHelper.getDayOfWeek(date)
                    if weekDay == 1
                    {
                        if eventType == EventType.EndUnavailable
                        {
                            if previousSaturday.eventType == EventType.IntermediateUnavailable
                            {
                                formattedEvents[year]![month]![previousSaturday.day] = EventType.EndUnavailable
                            }
                            else if previousSaturday.eventType == EventType.StartUnavailable
                            {
                                formattedEvents[year]![month]![previousSaturday.day] = EventType.SingleDayUnavailable
                            }
                            formattedEvents[year]![month]![day] = EventType.SingleDayUnavailable
                        }
                        else if eventType == EventType.IntermediateUnavailable
                        {
                            if previousSaturday.eventType == EventType.IntermediateUnavailable
                            {
                                formattedEvents[year]![month]![previousSaturday.day] = EventType.EndUnavailable
                            }
                            else if previousSaturday.eventType == EventType.StartUnavailable
                            {
                                formattedEvents[year]![month]![previousSaturday.day] = EventType.SingleDayUnavailable
                            }
                            formattedEvents[year]![month]![day] = EventType.StartUnavailable
                        }
                    }
                    if weekDay == 7
                    {
                        previousSaturday = (day, eventType)
                    }
                }
            }
        }
    }
    
    private func manageMonthWiseUnavailability()
    {
        let yearOrderedArray = formattedEvents.sort({ (first, second) -> Bool in
            return first.0 < second.0
        })
        for (year, monthStructure) in yearOrderedArray
        {
            let monthOrderedArray = monthStructure.sort({ (first, second) -> Bool in
                return first.0 < second.0
            })
            for (month, dayStructure) in monthOrderedArray
            {
                let daysOrderedArray = dayStructure.sort({ (first, second) -> Bool in
                    return first.0 < second.0
                })
                for (day, eventType) in daysOrderedArray
                {
                    let lastDay = DateHelper.getMaxDays(year, month: month)
                    if day == lastDay
                    {
                        if eventType == EventType.IntermediateUnavailable
                        {
                            formattedEvents[year]![month]![day] = EventType.EndUnavailable
                        }
                        else if eventType == EventType.StartUnavailable
                        {
                            formattedEvents[year]![month]![day] = EventType.SingleDayUnavailable
                        }
                    }
                    else if day == 1
                    {
                        if eventType == EventType.IntermediateUnavailable
                        {
                            formattedEvents[year]![month]![day] = EventType.StartUnavailable
                        }
                        else if eventType == EventType.EndUnavailable
                        {
                            formattedEvents[year]![month]![day] = EventType.SingleDayUnavailable
                        }
                    }
                }
            }
        }
    }
    
    func getEventTypeForDate(dateStruct: DateStructure) -> EventType? {
        return self.formattedEvents[dateStruct.year]?[dateStruct.month]?[dateStruct.day]
    }
    
    func saveAllEvents() -> [[[String: Double]]] {
//        manageTimeZoneChange()
        var arrayOfMonths = [(DateStructure, [[String: Double]])]()
        let yearOrderedArray = formattedEvents.sort({ (first, second) -> Bool in
            return first.0 < second.0
        })
        for (year, monthsDictionary) in yearOrderedArray {
            let monthOrderedArray = monthsDictionary.sort({ (first, second) -> Bool in
                return first.0 < second.0
            })
            for (month, daysDictionary) in monthOrderedArray {
                let dayOrderedArray = daysDictionary.sort({ (first, second) -> Bool in
                    return first.0 < second.0
                })
                var thisMonthDictionary = [[String: Double]]()
                let thisMonthDateStructure = DateStructure(day: 1, month: month, year: year)
                var tempArray = [Double]()
                for (day, event) in dayOrderedArray {
                    if event == EventType.SingleDayUnavailable
                    {
                        let startDate = DateStructure(day: day, month: month, year: year).getUTCNSDate()
                        let endDate = DateStructure(day: day, month: month, year: year).getUTCEndNSDate()
                        thisMonthDictionary.append(["from": startDate, "to": endDate])
                    }
                    else if event == EventType.StartUnavailable
                    {
                        let date = DateStructure(day: day, month: month, year: year).getUTCNSDate()
                        tempArray.append(date)
                    }
                    else if event == EventType.EndUnavailable
                    {
                        let date = DateStructure(day: day, month: month, year: year).getUTCEndNSDate()
                        tempArray.append(date)
                        thisMonthDictionary.append(["from": tempArray[0], "to": tempArray[1]])
                        tempArray = []
                    }
                }
                if thisMonthDictionary.count > 0
                {
                    arrayOfMonths.append((thisMonthDateStructure, thisMonthDictionary))
                }
            }
        }
        
        return manageTimeZoneChanges(arrayOfMonths)
    }
    
    private func manageTimeZoneChanges(eventsStructure: [(DateStructure, [[String: Double]])]) -> [[[String: Double]]]
    {
        var eventsData = eventsStructure
        var indexToRemove = [(Int, Int)]()
        var arrayOfDatesToReorder = [Double]()
        for indexOfMonth in 0..<eventsData.count
        {
            let (dateStructure, events) = eventsData[indexOfMonth]
            for indexOfEvent in 0..<events.count
            {
                let continuousEvent = events[indexOfEvent]
                let fromDate = continuousEvent["from"]!
                let toDate = continuousEvent["to"]!
                
                let fromDateStructure = getUTCDateStructureFor(fromDate/1000)
                let toDateStructure = getUTCDateStructureFor(toDate/1000)
                
                if fromDateStructure.month != dateStructure.month || fromDateStructure.year != dateStructure.year
                {
                    if fromDate == toDate
                    {
                        indexToRemove.append((indexOfMonth, indexOfEvent))
                    }
                    else
                    {
                        eventsData[indexOfMonth].1[indexOfEvent]["from"] = getNextDay(fromDate)
                    }
                    arrayOfDatesToReorder.append(fromDate)
                }
                if toDateStructure.month != dateStructure.month || toDateStructure.year != dateStructure.year
                {
                    if fromDate == toDate
                    {
                        indexToRemove.append((indexOfMonth, indexOfEvent))
                    }
                    else
                    {
                        eventsData[indexOfMonth].1[indexOfEvent]["to"] = getPreviousDay(fromDate)
                    }
                    arrayOfDatesToReorder.append(fromDate)
                }
            }
        }
        
        for (monthIndex, eventIndex) in indexToRemove
        {
            eventsData[monthIndex].1.removeAtIndex(eventIndex)
        }
        
        for date in arrayOfDatesToReorder
        {
            let dateStructureToReorder = getUTCDateStructureFor(date/1000)
            var isDataSet = false
            for indexOfMonth in 0..<eventsData.count
            {
                let (dateStructure, _) = eventsData[indexOfMonth]
                if dateStructure.month == dateStructureToReorder.month && dateStructure.year == dateStructureToReorder.year
                {
                    eventsData[indexOfMonth].1.append(["from": date, "to": date])
                    isDataSet = true
                    break
                }
            }
            if !isDataSet
            {
                eventsData.append((dateStructureToReorder, [["from": date, "to": date]]))
            }
        }
        
        var arrayToReturn = [[[String: Double]]]()
        for (_, events) in eventsData
        {
            arrayToReturn.append(events)
        }
        return arrayToReturn
    }
    
    private func getUTCDateStructureFor(date: NSTimeInterval) -> DateStructure
    {
        let anotherFormatter = NSDateFormatter()
        anotherFormatter.dateFormat = "yyyy"
        anotherFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let year = Int(anotherFormatter.stringFromDate(NSDate(timeIntervalSince1970: date)))!
        anotherFormatter.dateFormat = "MM"
        let month = Int(anotherFormatter.stringFromDate(NSDate(timeIntervalSince1970: date)))!
        anotherFormatter.dateFormat = "dd"
        let day = Int(anotherFormatter.stringFromDate(NSDate(timeIntervalSince1970: date)))!
        return DateStructure(day: day, month: month, year: year)
    }
    
    private func getNextDay(date: Double) -> Double
    {
        return date + 86400000
    }
    
    private func getPreviousDay(date: Double) -> Double
    {
        return date - 86400000
    }
    
    private func manageTimeZoneChange() -> () {
        let yearOrderedArray = formattedEvents.sort({ (first, second) -> Bool in
            return first.0 < second.0
        })
        for (year, monthsDictionary) in yearOrderedArray {
            let monthOrderedArray = monthsDictionary.sort({ (first, second) -> Bool in
                return first.0 < second.0
            })
            for (month, daysDictionary) in monthOrderedArray {
                let dayOrderedArray = daysDictionary.sort({ (first, second) -> Bool in
                    return first.0 < second.0
                })
                for (day, event) in dayOrderedArray {
                    if let shouldCorrectTimeZoneForFirstDay = shouldCorrectTimeZoneForFirstDay()
                    {
                        if shouldCorrectTimeZoneForFirstDay
                        {
                            if day == 1 && (event == EventType.StartUnavailable || event == EventType.SingleDayUnavailable)
                            {
                                formattedEvents[year]![month]![day] = nil
                                if event == EventType.StartUnavailable
                                {
                                    formattedEvents[year]![month]![day + 1] = EventType.StartUnavailable
                                }
                                let presentDate = DateStructure(day: day, month: month, year: year)
                                let previousDate = presentDate.getPreviousDay()
                                if let month = formattedEvents[previousDate.year] {
                                    if let _ = month[previousDate.month] {
                                        formattedEvents[previousDate.year]![previousDate.month]![previousDate.day] = EventType.SingleDayUnavailable
                                    }
                                    else {
                                        formattedEvents[previousDate.year]![previousDate.month] = [previousDate.day: EventType.SingleDayUnavailable]
                                    }
                                }
                                else {
                                    formattedEvents[previousDate.year] = [previousDate.month: [previousDate.day: EventType.SingleDayUnavailable]]
                                }
                            }
                        }
                        else
                        {
                            if day == DateHelper.getMaxDays(year, month: month) && (event == EventType.EndUnavailable || event == EventType.SingleDayUnavailable)
                            {
                                formattedEvents[year]![month]![day] = nil
                                if event == EventType.EndUnavailable
                                {
                                    formattedEvents[year]![month]![day - 1] = EventType.EndUnavailable
                                }
                                let presentDate = DateStructure(day: day, month: month, year: year)
                                let nextDate = presentDate.getPreviousDay()
                                if let month = formattedEvents[nextDate.year] {
                                    if let _ = month[nextDate.month] {
                                        formattedEvents[nextDate.year]![nextDate.month]![nextDate.day] = EventType.SingleDayUnavailable
                                    }
                                    else {
                                        formattedEvents[nextDate.year]![nextDate.month] = [nextDate.day: EventType.SingleDayUnavailable]
                                    }
                                }
                                else {
                                    formattedEvents[nextDate.year] = [nextDate.month: [nextDate.day: EventType.SingleDayUnavailable]]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shouldCorrectTimeZoneForFirstDay() -> Bool?
    {
        var boolToReturn: Bool?
        if DateHelper.localTimeZoneOffset() < 0
        {
            boolToReturn = false
        }
        else if DateHelper.localTimeZoneOffset() > 0
        {
            boolToReturn = true
        }
        return boolToReturn
    }
    
    func saveEvents() -> (removedUnavailability: [NSDate], addedUnavailability: [NSDate]) {
        var initialUnavailableDates = [NSDate]()
        
        for (year, monthsDictionary) in initialEvents {
            for (month, daysDictionary) in monthsDictionary {
                for (day, event) in daysDictionary {
                    if (event == EventType.StartUnavailable || event == EventType.IntermediateUnavailable || event == EventType.EndUnavailable || event == EventType.SingleDayUnavailable) {
                        initialUnavailableDates.append(DateStructure(day: day, month: month, year: year).getNSDate())
                    }
                }
            }
        }
        
        var finalUnavailableDates = [NSDate]()
        
        for (year, monthsDictionary) in formattedEvents {
            for (month, daysDictionary) in monthsDictionary {
                for (day, event) in daysDictionary {
                    if (event == EventType.StartUnavailable || event == EventType.IntermediateUnavailable || event == EventType.EndUnavailable || event == EventType.SingleDayUnavailable) {
                        finalUnavailableDates.append(DateStructure(day: day, month: month, year: year).getNSDate())
                    }
                }
            }
        }
        
        var initialDatesRemoveArray = [Int]()
        var finalDatesRemoveArray = [Int]()
        
        var i = 0
        
        
        for initialDate in initialUnavailableDates {
            var j = 0
            for finalDate in finalUnavailableDates {
                if initialDate == finalDate {
                    initialDatesRemoveArray.append(i)
                    finalDatesRemoveArray.append(j)
                }
                j++
            }
            i++
        }
        
        for var i = initialDatesRemoveArray.count - 1; i >= 0; i-- {
            initialUnavailableDates.removeAtIndex(initialDatesRemoveArray[i])
        }
        
        for var j = finalDatesRemoveArray.count - 1; j >= 0; j-- {
            finalUnavailableDates.removeAtIndex(finalDatesRemoveArray[j])
        }
        
        initialEvents = formattedEvents
        
        for var i = 0; i < initialUnavailableDates.count; i++ {
            let item = initialUnavailableDates[i]
            initialUnavailableDates[i] = item.getNextDay()
        }
        
        for var i = 0; i < finalUnavailableDates.count; i++ {
            let item = finalUnavailableDates[i]
            finalUnavailableDates[i] = item.getNextDay()
        }

        return(initialUnavailableDates, finalUnavailableDates)
    }
}
