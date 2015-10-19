//
//  CustomCalendar.swift
//  Calendar
//
//  Created by Vishal on 9/10/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

protocol CustomizableCalendarDelegate {
    
    //It is triggered whenever the month changes. You can retrieve the previous state month and year and the present state month and year.
    func calendar(calendar: CustomizableCalendar, monthChange: monthYearStructure)
    
    //It is triggered whenever a "touchUp Inside" event occurs on any day. You can retrieve the date corresponding to the tap.
    func calendar(calendar: CustomizableCalendar, didSelectDay: NSDate, formattedDateString: String)
}

protocol CustomizableCalendarDataSource {
    
    //Pass along an array of dates and the highlight Image
    func eventDetails(calendar: CustomizableCalendar) -> [eventHighlightStruct]
    
    //Format for the date that needs to be returned
    func dateFormatRequired(calendar: CustomizableCalendar) -> String
    
    //Range of dates for continuous blocked state in calendar
    func continuousEvent(calendar: CustomizableCalendar) -> [continuousEventStruct]
}

struct DefaultCalendarProperties {
    
    let presentYearSectionIndex = 10
    
    var calendarBackgroundColor = UIColor.blackColor()
    var dateColor = UIColor.whiteColor()
    var dateHighlightedColor = UIColor.grayColor()
    var todayColor = UIColor(red:25/255, green:214/255, blue:189/255, alpha:1.0)
    var todayHighlightedColor = UIColor(red:25/255, green:214/255, blue:189/255, alpha:1.0)
    var separatorColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    var daysOfWeekColor = UIColor(red: 0.698, green: 0, blue: 0, alpha: 1)
    var continuousEventColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    var eventColor = UIColor(red: 10/100, green: 84/100, blue: 74/100, alpha: 1.0)
    
    var eventCircleWidth: CGFloat = 1
    var eventFitScale: CGFloat = 0.6
    
    
    var dateFont = defaultFontForCalendar
    var dayOfWeekFont = defaultFontForCalendar
    var dayFormat: daysOfWeekFormat = daysOfWeekFormat.SingleLetter
    var needSeparator = false
    
    let threeLetterDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    let singleLetterDays = ["S","M","T","W","T","F","S"]
}

class CustomizableCalendar: UIView {
    
    private let dateHelper = DateHelper()
    let eventsModel = CalendarEventsModel()
    
    var defaultCalendarProperties = DefaultCalendarProperties()
    var events = CalendarEventsModel()
    var dateFormat = String()
    
    var calendarTarget : NSObject!
    var delegate : CustomizableCalendarDelegate?
    var dataSource : CustomizableCalendarDataSource?
    
    var monthsInMemory = [UIView]()
    var monthsArray = [DateStructure]()
    var cellItemSize = CGSize()
    
    var date = DateStructure(day: 0, month: 0, year: 0)
    
    var calendarFrame = defaultFrameForCalendar
    var fullFrame: CGRect!
    
    let calendarMonthCellIdentifier = "CalendarMonthCell"
    
    var calendarCollectionView : UICollectionView!
    var calendarDirection : UICollectionViewScrollDirection = .Vertical
    var previousPoint : CGPoint!
    
    var presentMonth = Int()
    
    var presentDate : DateStructure!
    
    var calendarType : CalendarType!
    
    
    //MARK: - Initializers
    
    init(frame: CGRect, calendarType: CalendarType) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        self.calendarType = calendarType
        if calendarType == CalendarType.ElaborateVertical {
            fullFrame = frame
            calendarFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.width*6.0/7.0)
            calendarDirection = .Vertical
            cellItemSize = CGSize(width: fullFrame.width, height: fullFrame.width*6.0/7.0)
            layout.itemSize = cellItemSize
            layout.minimumInteritemSpacing = 20.0
            layout.minimumLineSpacing = 20.0
        }
        else if calendarType == CalendarType.SimpleHorizontal {
            fullFrame = frame
            calendarFrame = frame
            calendarDirection = .Horizontal
            cellItemSize = calendarFrame.size
            layout.itemSize = cellItemSize
        }
        else {
            fullFrame = frame
            calendarFrame = frame
            calendarDirection = .Vertical
            cellItemSize = calendarFrame.size
            layout.itemSize = cellItemSize
        }
        layout.scrollDirection = calendarDirection
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
        calendarCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.height), collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set Up
    
    override func layoutSubviews() {
        
        if let dataSource = self.dataSource {
            dateFormat = dataSource.dateFormatRequired(self)
            eventsModel.formatEvents(dataSource.eventDetails(self), continuousEvents: dataSource.continuousEvent(self))
        }
        
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = UIColor.clearColor()
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: dateHelper.getDate().month - 1, inSection: defaultCalendarProperties.presentYearSectionIndex), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: dateHelper.getDate().month - 1, inSection: defaultCalendarProperties.presentYearSectionIndex), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        self.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
        calendarCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: calendarMonthCellIdentifier)
        calendarCollectionView.pagingEnabled = false
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.addSubview(calendarCollectionView)
    }
    
    func createLabel(viewToAddOn: UIView) {
        let labelHeight = self.frame.size.height/6.0
        let labelWidth = self.frame.size.width/7.0
        var dayOfWeek = [UILabel]()
        var weekDays = [String]()
        if defaultCalendarProperties.dayFormat == .SingleLetter {
            weekDays = defaultCalendarProperties.singleLetterDays
        }
        else {
            weekDays = defaultCalendarProperties.threeLetterDays
        }
        for i in 0...6 {
            dayOfWeek.append(UILabel(frame: CGRect(x: CGFloat(i) * labelWidth, y: CGFloat(0) , width: labelWidth, height: labelHeight)))
            dayOfWeek[i].text = weekDays[i]
            dayOfWeek[i].textAlignment = .Center
            dayOfWeek[i].font = defaultCalendarProperties.dayOfWeekFont
            dayOfWeek[i].textColor = defaultCalendarProperties.daysOfWeekColor
            viewToAddOn.addSubview(dayOfWeek[i])
        }
    }

    func provideMonths(indexPath: NSIndexPath) -> DateStructure {
        if indexPath.section == defaultCalendarProperties.presentYearSectionIndex {
            return DateStructure(day: 1, month: indexPath.item + 1, year: dateHelper.getDate().year)
        }
        else if indexPath.section < defaultCalendarProperties.presentYearSectionIndex {
            return DateStructure(day: 1, month: indexPath.item + 1, year: dateHelper.getDate().year - (10 - indexPath.section))
        }
        else {
            return DateStructure(day: 1, month: indexPath.item + 1, year: dateHelper.getDate().year + (indexPath.section - 10))
        }
    }
    
}

extension CustomizableCalendar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (defaultCalendarProperties.presentYearSectionIndex * 2) + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier(calendarMonthCellIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let monthView = MonthView(frame: CGRect(x: 0, y: 0, width: cellItemSize.width, height: cellItemSize.height), dateStruct: provideMonths(indexPath), eventsModel: self.eventsModel, delegate: self, calendarType: self.calendarType)
        
        let subViews = cell.subviews
        for sVs in subViews {
            sVs.removeFromSuperview()
        }
        cell.addSubview(monthView)
        return cell
    }
    
}

extension CustomizableCalendar: MonthsViewDelegate {
    
    func didUpdateEvents() {
        calendarCollectionView.reloadData()
    }
    
    func didSelectDate(date: NSDate) {
        if let delegate = delegate {
            let formatter = NSDateFormatter()
            formatter.dateFormat = self.dateFormat
            delegate.calendar(self, didSelectDay: date, formattedDateString: formatter.stringFromDate(date))
        }
    }
    
}

extension CustomizableCalendar: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
       
    }
    
}

extension CustomizableCalendar {
    
    func todayButton(sender: AnyObject) {
        for indexOfCalendar in 0..<monthsInMemory.count {
            if monthsInMemory[indexOfCalendar].tag == 22 {
                calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexOfCalendar, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
            }
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
    }
    
    func forwardMonthAction(sender: AnyObject) {
        
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        
    }
    
    func reverseMonthAction(sender: AnyObject) {
        
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    }
    
    func savePresentState(sender: AnyObject) -> (removedUnavailability: [NSDate], addedUnavailability: [NSDate]) {
        
        return eventsModel.saveEvents()
        
    }
    
}

