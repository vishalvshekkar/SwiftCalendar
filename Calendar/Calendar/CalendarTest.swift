//
//  ViewController.swift
//  Calendar
//
//  Created by Vishal on 9/10/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class CalendarTest : UIViewController, CustomizableCalendarDataSource, CustomizableCalendarDelegate
{
    
    @IBOutlet weak var customCalendar: UIView!
    var customCalendarView : CustomizableCalendar!
    var eventsForRed = [NSDate]()
    var eventsForBlue = [NSDate]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let calendarFrame = customCalendar.bounds
        customCalendarView = CustomizableCalendar(frame: calendarFrame, calendarType: CalendarType.ElaborateVertical)
        customCalendarView.calendarTarget = self
        customCalendarView.defaultCalendarProperties.dateColor = UIColor.whiteColor()
        customCalendarView.defaultCalendarProperties.daysOfWeekColor = UIColor.grayColor()
        customCalendarView.defaultCalendarProperties.dayFormat = daysOfWeekFormat.ThreeLetters
        customCalendarView.isEditable = true
        customCalendarView.dataSource = self
        customCalendarView.delegate = self
        customCalendar.addSubview(customCalendarView)
        
        let dates = ["22/08/2015","16/09/2015","2/09/2015", "23/10/2015", "1/11/2015", "5/12/2015"]
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        for date in dates {
            eventsForRed.append(formatter.dateFromString(date)!)
        }
        let dates2 = ["24/08/2015","26/09/2015","5/09/2015", "23/10/2015", "18/11/2015", "28/09/2015"]
        for date in dates2 {
            eventsForBlue.append(formatter.dateFromString(date)!)
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func eventDetails(calendar: CustomizableCalendar) -> [eventHighlightStruct] {
        var arrayOfred : [eventHighlightStruct] = []
        for events in eventsForRed {
            arrayOfred.append(eventHighlightStruct(eventDate: events, highlightType: EventType.ConfirmedEvent))
        }
        
        for events in eventsForBlue {
            arrayOfred.append(eventHighlightStruct(eventDate: events, highlightType: EventType.UnconfirmedEvent))
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        for date in ["24/1/2016","26/1/2016","5/1/2016", "23/1/2016", "18/1/2016", "28/1/2016", "8/1/2016"] {
            arrayOfred.append(eventHighlightStruct(eventDate: formatter.dateFromString(date)!, highlightType: EventType.CancelledDay))
        }
        
        return arrayOfred
    }
    
    
    func dateFormatRequired(calendar: CustomizableCalendar) -> String {
        return "dd/MM/yyyy"
    }
    
    func continuousEvent(calendar: CustomizableCalendar) -> [continuousEventStruct] {
        return [
            continuousEventStruct(startDate: createNSDate("1/9/2015"), endDate: createNSDate("4/9/2015")),
            continuousEventStruct(startDate: createNSDate("11/09/2015"), endDate: createNSDate("14/09/2015")),
            continuousEventStruct(startDate: createNSDate("10/09/2015"), endDate: createNSDate("10/09/2015")),
            continuousEventStruct(startDate: createNSDate("29/09/2015"), endDate: createNSDate("30/9/2015")),
            continuousEventStruct(startDate: createNSDate("5/1/2016"), endDate: createNSDate("8/1/2016"))
        ]
    }
    
    func createNSDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.dateFromString(dateString)!
    }
    
    //Delegate
    func calendar(calendar: CustomizableCalendar, monthChange: monthYearStructure)
    {
        print("From \(monthChange.fromMonthName) \(monthChange.fromYear) TO \(monthChange.toMonthName) \(monthChange.toYear)")
    }
    
    func calendar(calendar: CustomizableCalendar, didSelectDay: NSDate, formattedDateString: String)
    {
        print(formattedDateString)
    }
    
    @IBAction func previous(sender: AnyObject) {
        customCalendarView.reverseMonthAction(self)
    }
    
    @IBAction func today(sender: AnyObject) {
        customCalendarView.todayButton(self)
    }
    
    @IBAction func next(sender: AnyObject) {
        customCalendarView.forwardMonthAction(self)
    }
    
}

