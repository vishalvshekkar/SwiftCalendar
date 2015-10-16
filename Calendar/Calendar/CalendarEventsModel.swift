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
    
    var formattedMonth = [Int: [Int: [Int: EventType]]]()
    
    func formatEvents(circularEvents: [eventHighlightStruct], continuousEvents: [continuousEventStruct]) {
        self.events = circularEvents
        self.continuousEvents = continuousEvents
        for contEvents in self.continuousEvents {
            self.continuousEventsFormatted.append(continuousEventsSplitStruct(continuousEvent: contEvents))
        }
        
        for event in events {
            let eventDate = event.eventDate.convertToDateStructure()
            if let month = formattedMonth[eventDate.year] {
                if let _ = month[eventDate.month] {
                    formattedMonth[eventDate.year]![eventDate.month]![eventDate.day] = event.highlightType
                }
                else {
                    formattedMonth[eventDate.year]![eventDate.month] = [eventDate.day: event.highlightType]
                }
            }
            else {
                formattedMonth[eventDate.year] = [eventDate.month: [eventDate.day: event.highlightType]]
            }
        }
        
        for contEvents in continuousEvents {
            let startDate = contEvents.startDate
            let endDate = contEvents.endDate
            
            var movingDate = startDate
            while movingDate == endDate {
                var event = EventType.StartUnavailable
                if movingDate == startDate {
                    event = EventType.StartUnavailable
                }
                else if movingDate == endDate {
                    event = EventType.EndUnavailable
                }
                else {
                    event = EventType.IntermediateUnavailable
                }
                
                if let month = formattedMonth[movingDate.convertToDateStructure().year] {
                    if let _ = month[movingDate.convertToDateStructure().month] {
                        formattedMonth[movingDate.convertToDateStructure().year]![movingDate.convertToDateStructure().month]![movingDate.convertToDateStructure().day] = event
                    }
                    else {
                        formattedMonth[movingDate.convertToDateStructure().year]![movingDate.convertToDateStructure().month] = [movingDate.convertToDateStructure().day: event]
                    }
                }
                else {
                    formattedMonth[movingDate.convertToDateStructure().year] = [movingDate.convertToDateStructure().month: [movingDate.convertToDateStructure().day: event]]
                }
                movingDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: movingDate, options: NSCalendarOptions(rawValue: 0))!
            }
            
        }
        
    }
}
