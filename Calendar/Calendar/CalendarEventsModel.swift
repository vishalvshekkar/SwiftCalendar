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
    
    var formattedEvents = [Int: [Int: [Int: EventType]]]()
    
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
    }
}
