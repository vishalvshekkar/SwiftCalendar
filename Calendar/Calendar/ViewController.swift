//
//  ViewController.swift
//  Calendar
//
//  Created by Vishal on 9/10/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CustomizableCalendarDelegate, CustomizableCalendarDataSource {
    
    @IBOutlet weak var didSelect: UILabel!
    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var orangeView: UIView!
    var myCalendar : CustomizableCalendar!
    var eventsForRed = [NSDate]()
    var eventsForBlue = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.view.backgroundColor = UIColor.blackColor()
        doDate()
        calendarSetup()
    }
    
    func calendarSetup() {
        let button = UIButton(frame: CGRect(x: 100, y: 0, width: 100, height: 50))
        button.setTitle("Save", forState: UIControlState.Normal)
        button.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)
        let calendarFrame = CGRect(x: 0, y: 50, width: 375, height: 375)
        //        let color = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        //        let calendarFrame = CGRect(origin: CGPointZero, size: orangeView.frame.size)
        myCalendar = CustomizableCalendar(frame: calendarFrame, calendarType: CalendarType.ElaborateVertical)
        myCalendar.calendarTarget = self
        let calendarFont = UIFont(name: "HelveticaNeue-Light", size: 12) // AppleSDGothicNeo-Light ArialMT  Avenir-Oblique HelveticaNeue-UltraLight MarkerFelt-Thin AmericanTypewriter HelveticaNeue-Light
        myCalendar.defaultCalendarProperties.dateFont = calendarFont
        myCalendar.defaultCalendarProperties.dayOfWeekFont = calendarFont
        myCalendar.defaultCalendarProperties.calendarBackgroundColor = UIColor.blackColor()
        myCalendar.defaultCalendarProperties.dateColor = UIColor.whiteColor()
        myCalendar.defaultCalendarProperties.daysOfWeekColor = UIColor.grayColor()
        myCalendar.delegate = self
        myCalendar.dataSource = self
        view.addSubview(myCalendar)
    }
    
    func save(sender: AnyObject) {
        let x = myCalendar.savePresentState(sender)
        
        print(x.0)
        print(x.1)
    }
    
    
    func doDate() {
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
    
    //Sending actions/triggers to the calendar
    
    @IBAction func button(sender: AnyObject) {
        myCalendar.todayButton(sender)
    }
    
    
    func eventDetails(calendar: CustomizableCalendar) -> [eventHighlightStruct] {
        var arrayOfred : [eventHighlightStruct] = []
        for events in eventsForRed {
            arrayOfred.append(eventHighlightStruct(eventDate: events, highlightType: EventType.ConfirmedEvent))
        }
        
        for events in eventsForBlue {
            arrayOfred.append(eventHighlightStruct(eventDate: events, highlightType: EventType.UnconfirmedEvent))
        }
        
        return arrayOfred
    }
    
    
    
    func dateFormatRequired(calendar: CustomizableCalendar) -> String {
        return "dd/MM/yyyy"
    }
    
    func continuousEvent(calendar: CustomizableCalendar) -> [continuousEventStruct] {
        return [continuousEventStruct(startDate: createNSDate("1/9/2015"), endDate: createNSDate("5/9/2015")), continuousEventStruct(startDate: createNSDate("7/09/2015"), endDate:                         createNSDate("09/09/2015")), continuousEventStruct(startDate: createNSDate("29/09/2015"), endDate: createNSDate("30/9/2015")), continuousEventStruct(startDate: createNSDate("5/10/2015"), endDate: createNSDate("8/10/2015"))]
    }
    
    func createNSDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.dateFromString(dateString)!
    }
    
    
    //Calendar Delegates
    
    func calendar(calendar: CustomizableCalendar, monthChange: monthYearStructure) {
        print("Month changed from \(monthChange.fromMonthName) \(monthChange.fromYear) to \(monthChange.toMonthName) \(monthChange.toYear)")
        monthAndYear.text = "\(monthChange.toMonthName) \(monthChange.toYear)"
    }
    
    func calendar(calendar: CustomizableCalendar, didSelectDay: DateStructure) {
        print("Date selected is \(didSelectDay.day)/\(didSelectDay.month)/\(didSelectDay.year)")
        didSelect.text = "\(didSelectDay.day)/\(didSelectDay.month)/\(didSelectDay.year)"
    }
    
    func calendar(calendar: CustomizableCalendar, didSelectDay: NSDate, formattedDateString: String) {
        print(formattedDateString)
    }
    
    
    //Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

