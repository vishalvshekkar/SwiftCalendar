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
    
    var calendarBackgroundColor = UIColor(red:23.0/255, green:23.0/255, blue:23.0/255, alpha:1)
    var dateColor = UIColor.whiteColor()
    var dateHighlightedColor = UIColor.grayColor()
    var todayColor = UIColor(red:25/255, green:214/255, blue:189/255, alpha:1.0)
    var todayHighlightedColor = UIColor(red:25/255, green:214/255, blue:189/255, alpha:1.0)
    var separatorColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    var daysOfWeekColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    var continuousEventColor = UIColor(red: 96.0/255, green: 96.0/255, blue: 96.0/255, alpha:1)
    var continuousEventTextColor = UIColor(red: 25.0/255, green: 24.0/255, blue: 25.0/255, alpha: 1.0)
    var eventColor = UIColor(red: 10.0/100, green: 84.0/100, blue: 74.0/100, alpha: 1.0)
    var cancelledEventColor = UIColor(red: 255.0/255, green: 59.0/255, blue: 95.0/255, alpha: 1.0)
    var pastDateColor = UIColor(red: 109.0/255, green: 109.0/255, blue: 109.0/255, alpha: 1.0)
    var selectedDateColor = UIColor(red: 25.0/100, green: 24.0/100, blue: 25.0/100, alpha: 1.0)
    
    var eventCircleWidth: CGFloat = 1
    var eventFitScale: CGFloat = 0.6
    var selectedDate: DateStructure?
    
    var dateFont = defaultFontForCalendar
    var dayOfWeekFont = defaultFontForCalendar
    var dayFormat: daysOfWeekFormat = daysOfWeekFormat.SingleLetter
    var needSeparator = false
    
    let threeLetterDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    let singleLetterDays = ["S","M","T","W","T","F","S"]
}

class CustomizableCalendar: UIView {
    
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
    
    var selectedDate: DateStructure?
    var calendarType : CalendarType!
    var isEditable = false
    var lastMonth: DateStructure?
    var lastIndexPath: NSIndexPath!
    var centerPoint: CGPoint {
        return CGPoint(x: calendarCollectionView.frame.width/2, y: calendarCollectionView.frame.height/2)
    }
    
    //MARK: - Initializers
    
    init(frame: CGRect, calendarType: CalendarType) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        
        self.calendarType = calendarType
        var calendarCollectionViewFrame = CGRect()
        if calendarType == CalendarType.ElaborateVertical {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            fullFrame = frame
            calendarFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.width*6.0/7.0)
            calendarDirection = .Vertical
            cellItemSize = CGSize(width: fullFrame.width, height: fullFrame.width*6.0/7.0)
            layout.itemSize = cellItemSize
            layout.minimumInteritemSpacing = 20.0
            layout.minimumLineSpacing = 20.0
            calendarCollectionViewFrame = CGRect(x: 0, y: self.frame.size.height/13.0, width: fullFrame.width, height: fullFrame.height - self.frame.size.height/13.0)
        }
        else if calendarType == CalendarType.SimpleHorizontal {
            fullFrame = frame
            calendarFrame = frame
            calendarDirection = .Horizontal
            cellItemSize = calendarFrame.size
            layout.itemSize = cellItemSize
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            calendarCollectionViewFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.height)
        }
        else if calendarType == CalendarType.CalendarFeed {
            fullFrame = frame
            calendarFrame = frame
            calendarDirection = .Horizontal
            cellItemSize = calendarFrame.size
            layout.itemSize = cellItemSize
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            calendarCollectionViewFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.height)
        }
        else if calendarType == CalendarType.SimpleDateSelection {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            fullFrame = frame
            calendarFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: frame.height)
            calendarDirection = .Vertical
            cellItemSize = CGSize(width: fullFrame.width, height: fullFrame.width*6.0/7.0)
            layout.itemSize = cellItemSize
            layout.minimumInteritemSpacing = 20.0
            layout.minimumLineSpacing = 20.0
            calendarCollectionViewFrame = CGRect(x: 0, y: self.frame.size.height/13.0, width: fullFrame.width, height: fullFrame.height - self.frame.size.height/13.0)
        }
        layout.scrollDirection = calendarDirection
        calendarCollectionView = UICollectionView(frame: calendarCollectionViewFrame, collectionViewLayout: layout)
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit()
    {
        
    }
    
    //MARK: - Set Up
    
    func setEditableStateTo(state: Bool)
    {
        isEditable = state
        self.calendarCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if calendarType == CalendarType.ElaborateVertical || calendarType == CalendarType.SimpleDateSelection
        {
            if calendarCollectionView.layer.mask == nil
            {
                let maskLayer: CAGradientLayer = CAGradientLayer()
                maskLayer.locations = [NSNumber(float: 0.0), NSNumber(float: 0.2), NSNumber(float: 0.8), NSNumber(float: 1.0)]
                maskLayer.bounds = CGRect(x: 0, y: 0, width: calendarCollectionView.frame.size.width, height: calendarCollectionView.frame.size.height)
                maskLayer.anchorPoint = CGPoint.zero
                calendarCollectionView.layer.mask = maskLayer
            }
            scrollViewDidScroll(calendarCollectionView)
        }
        
        if let dataSource = self.dataSource {
            dateFormat = dataSource.dateFormatRequired(self)
            eventsModel.formatEvents(dataSource.eventDetails(self), continuousEvents: dataSource.continuousEvent(self))
        }
        
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: DateHelper.getDate().month, fromMonthName: monthDictionary[DateHelper.getDate().month]!, fromYear: DateHelper.getDate().year, toMonth: DateHelper.getDate().month, toMonthName: monthDictionary[DateHelper.getDate().month]!, toYear: DateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.backgroundColor = UIColor.clearColor()
        let date = DateHelper.getDate()
        calendarCollectionView.pagingEnabled = false
        if calendarDirection == .Horizontal {
            let indexpath = calendarType == CalendarType.CalendarFeed ? NSIndexPath(forItem: 0, inSection: 0) : NSIndexPath(forItem: date.month - 1, inSection: defaultCalendarProperties.presentYearSectionIndex)
            calendarCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            lastIndexPath = indexpath
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            let indexpath = calendarType == CalendarType.CalendarFeed ? NSIndexPath(forItem: 0, inSection: 0) : NSIndexPath(forItem: date.month - 1, inSection: defaultCalendarProperties.presentYearSectionIndex)
            calendarCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            lastIndexPath = indexpath
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        if calendarType == CalendarType.SimpleHorizontal || calendarType == CalendarType.CalendarFeed
        {
            calendarCollectionView.pagingEnabled = true
        }
        self.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
        calendarCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: calendarMonthCellIdentifier)
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.addSubview(calendarCollectionView)
        if calendarType == CalendarType.ElaborateVertical || calendarType == CalendarType.SimpleDateSelection {
            createLabel(self)
        }
    }
    
    func createLabel(viewToAddOn: UIView) {
        let labelHeight = self.frame.size.height/13.0
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
            dayOfWeek[i].textColor = UIColor.whiteColor()
            dayOfWeek[i].backgroundColor = UIColor.clearColor()
            viewToAddOn.addSubview(dayOfWeek[i])
            viewToAddOn.bringSubviewToFront(dayOfWeek[i])
        }
    }

    private func provideMonths(indexPath: NSIndexPath) -> DateStructure {
        var dateToReturn: DateStructure
        if calendarType == CalendarType.CalendarFeed
        {
            dateToReturn = DateStructure(day: 1, month: indexPath.item + 1, year: DateHelper.getDate().year + indexPath.section)
        }
        else
        {
            if indexPath.section == defaultCalendarProperties.presentYearSectionIndex {
                dateToReturn = DateStructure(day: 1, month: indexPath.item + 1, year: DateHelper.getDate().year)
            }
            else if indexPath.section < defaultCalendarProperties.presentYearSectionIndex {
                dateToReturn = DateStructure(day: 1, month: indexPath.item + 1, year: DateHelper.getDate().year - (10 - indexPath.section))
            }
            else {
                dateToReturn = DateStructure(day: 1, month: indexPath.item + 1, year: DateHelper.getDate().year + (indexPath.section - 10))
            }
        }
        return dateToReturn
    }
    
    private func getNumberOfSections() -> Int {
        if calendarType == CalendarType.CalendarFeed
        {
            return 11
        }
        else
        {
            return (defaultCalendarProperties.presentYearSectionIndex * 2) + 1
        }
    }
    
}

extension CustomizableCalendar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return getNumberOfSections()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let monthCell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier(calendarMonthCellIdentifier, forIndexPath: indexPath)
        monthCell.backgroundColor = UIColor.clearColor()
        
        let monthView = MonthView(
            frame: CGRect(x: 0, y: 0, width: cellItemSize.width, height: cellItemSize.height),
            dateStruct: provideMonths(indexPath),
            eventsModel: self.eventsModel,
            delegate: self,
            calendarType: self.calendarType,
            selectedDate: self.selectedDate,
            superView: self,
            isEditable: self.isEditable,
            defaultCalendarProperties: self.defaultCalendarProperties
        )
        let subViews = monthCell.subviews
        for sVs in subViews {
            sVs.removeFromSuperview()
        }
        monthCell.addSubview(monthView)
        return monthCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Tapped")
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
        calendarCollectionView.reloadData()
    }
    
}

extension CustomizableCalendar: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if calendarType == CalendarType.SimpleHorizontal || calendarType == CalendarType.CalendarFeed
        {
            if let delegate = self.delegate {
                let presentCenterPoint = calendarCollectionView.contentOffset.addPoint(centerPoint)
                let indexPath = calendarCollectionView.indexPathForItemAtPoint(presentCenterPoint)
                lastIndexPath = indexPath
                if let indexPath = indexPath
                {
                    let presentDate = provideMonths(indexPath)
                    let lastDateStructure = lastMonth == nil ? presentDate : lastMonth!
                    let changesMade = monthYearStructure(fromMonth: lastDateStructure.month, fromMonthName: monthDictionary[lastDateStructure.month]!, fromYear: lastDateStructure.year, toMonth: presentDate.month, toMonthName: monthDictionary[presentDate.month]!, toYear: presentDate.year)
                    delegate.calendar(self, monthChange: changesMade)
                    lastMonth = presentDate
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if calendarType == CalendarType.ElaborateVertical || calendarType == CalendarType.SimpleDateSelection
        {
            if let _ = scrollView.layer.mask
            {
                let outerColor: CGColorRef = UIColor(white: 1.0, alpha: 0.0).CGColor
                let innerColor: CGColorRef = UIColor(white: 1.0, alpha: 1.0).CGColor
                var colors: [AnyObject]
                
                if scrollView.contentOffset.y + scrollView.contentInset.top <= 0
                {
                    colors = [innerColor, innerColor, innerColor, outerColor]
                }
                else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height
                {
                    colors = [outerColor, innerColor, innerColor, innerColor]
                }
                else
                {
                    colors = [outerColor, innerColor, innerColor, outerColor]
                }
                
                let gradientLayer = scrollView.layer.mask as! CAGradientLayer
                gradientLayer.colors = colors
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                scrollView.layer.mask!.position = CGPoint(x: 0, y: scrollView.contentOffset.y)
                CATransaction.commit()
            }
        }
    }
    
}

extension CustomizableCalendar {
    
    func todayButton(sender: AnyObject) {
        let date = DateHelper.getDate()
        let indexPath = calendarType == CalendarType.CalendarFeed ? NSIndexPath(forItem: 0, inSection: 0) : NSIndexPath(forItem: date.month - 1, inSection: defaultCalendarProperties.presentYearSectionIndex)
        lastIndexPath = indexPath
        calendarCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        if let delegate = self.delegate {
            let presentDate = provideMonths(indexPath)
            let lastDateStructure = lastMonth == nil ? presentDate : lastMonth!
            let changesMade = monthYearStructure(fromMonth: lastDateStructure.month, fromMonthName: monthDictionary[lastDateStructure.month]!, fromYear: lastDateStructure.year, toMonth: presentDate.month, toMonthName: monthDictionary[presentDate.month]!, toYear: presentDate.year)
            delegate.calendar(self, monthChange: changesMade)
            lastMonth = presentDate
        }
    }
    
    func forwardMonthAction(sender: AnyObject) {
        let indexPathToMoveTo = getNextIndexPath(lastIndexPath)
        lastIndexPath = indexPathToMoveTo
        calendarCollectionView.scrollToItemAtIndexPath(indexPathToMoveTo, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        if let delegate = self.delegate {
            let presentDate = provideMonths(indexPathToMoveTo)
            let lastDateStructure = lastMonth == nil ? presentDate : lastMonth!
            let changesMade = monthYearStructure(fromMonth: lastDateStructure.month, fromMonthName: monthDictionary[lastDateStructure.month]!, fromYear: lastDateStructure.year, toMonth: presentDate.month, toMonthName: monthDictionary[presentDate.month]!, toYear: presentDate.year)
            delegate.calendar(self, monthChange: changesMade)
            lastMonth = presentDate
        }
    }
    
    func reverseMonthAction(sender: AnyObject) {
        let indexPathToMoveTo = getPreviousIndexPath(lastIndexPath)
        lastIndexPath = indexPathToMoveTo
        calendarCollectionView.scrollToItemAtIndexPath(indexPathToMoveTo, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        if let delegate = self.delegate {
            let presentDate = provideMonths(indexPathToMoveTo)
            let lastDateStructure = lastMonth == nil ? presentDate : lastMonth!
            let changesMade = monthYearStructure(fromMonth: lastDateStructure.month, fromMonthName: monthDictionary[lastDateStructure.month]!, fromYear: lastDateStructure.year, toMonth: presentDate.month, toMonthName: monthDictionary[presentDate.month]!, toYear: presentDate.year)
            delegate.calendar(self, monthChange: changesMade)
            lastMonth = presentDate
        }
    }
    
    func getNextIndexPath(indexPath: NSIndexPath) -> NSIndexPath
    {
        let lastSectionIndex = calendarType == CalendarType.CalendarFeed ? 10 : (defaultCalendarProperties.presentYearSectionIndex * 2)
        let lastItemIndex = 11
        
        var nextIndexPath = indexPath
        
        if indexPath.item + 1 > lastItemIndex
        {
            if indexPath.section + 1 <= lastSectionIndex
            {
                nextIndexPath = NSIndexPath(forItem: 0, inSection: indexPath.section + 1)
            }
        }
        else
        {
            nextIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
        }
        return nextIndexPath
    }
    
    func getPreviousIndexPath(indexPath: NSIndexPath) -> NSIndexPath
    {
        let firstSectionIndex = 0
        let firstItemIndex = 0
        let lastItemIndex = 11
        
        var previousIndexPath = indexPath
        
        if indexPath.item - 1 < firstItemIndex
        {
            if indexPath.section - 1 >= firstSectionIndex
            {
                previousIndexPath = NSIndexPath(forItem: lastItemIndex, inSection: indexPath.section - 1)
            }
        }
        else
        {
            previousIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
        }
        return previousIndexPath
    }
    
    func savePresentState(sender: AnyObject) -> (removedUnavailability: [NSDate], addedUnavailability: [NSDate]) {
        return eventsModel.saveEvents()
    }
    
    func getPresentState(sender: AnyObject) -> [[[String : Double]]]
    {
        return eventsModel.saveAllEvents()
    }
    
}

