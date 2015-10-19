//
//  CalendarEventsModel.swift
//  Calendar
//
//  Created by Vishal on 10/16/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class CalendarEventsModel: NSObject {

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
        initialEvents = formattedEvents
    }
    
    func getEventTypeForDate(dateStruct: DateStructure) -> EventType? {
        return self.formattedEvents[dateStruct.year]?[dateStruct.month]?[dateStruct.day]
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
