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
    func calendar(calendar: CustomizableCalendar, didSelectDay: dateStructure)
}

protocol CustomizableCalendarDataSource {
    
    //Pass the number of Event types to be Highlighted
    func numberOfeventTypes(calendar: CustomizableCalendar) -> Int
    
    //Pass along an array of dates and the highlight Image
    func eventDetails(calendar: CustomizableCalendar, forEventType: Int) -> eventHighlightStruct
    
    //Format for the date that needs to be returned
    func dateFormatRequired(calendar: CustomizableCalendar) -> String
}


class CustomizableCalendar: UIControl, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    private let dateHelper = DateHelper()
    var calendarTarget : NSObject!
    var delegate : CustomizableCalendarDelegate?
    var dataSource : CustomizableCalendarDataSource?
    
    var monthsInMemory = [UIView]()
    var monthsArray = [dateStructure]()
    var eventListRed = [NSDate]()
    var eventListRedStructured = [dateStructure]()
    var eventListBlue = [NSDate]()
    var eventListBlueStructured = [dateStructure]()
    
    var date = dateStructure(day: 0, month: 0, year: 0)
    
    var calendarFrame = defaultFrameForCalendar
    var calendarBackgroundColor = UIColor.blackColor()
    var dateColor = UIColor.whiteColor()
    var dateHighlightedColor = UIColor.grayColor()
    var todayColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    var todayHighlightedColor = UIColor(red: 0.698, green: 0, blue: 0, alpha: 0.5)
    var separatorColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    var daysOfWeekColor = UIColor(red: 0.698, green: 0, blue: 0, alpha: 1)
    
    var dateFont = defaultFontForCalendar
    var dayOfWeekFont = defaultFontForCalendar
    var dayFormat: daysOfWeekFormat = daysOfWeekFormat.ThreeLetters
    var needSeparator = false
    var calendarCollectionView : UICollectionView!
    var calendarDirection : UICollectionViewScrollDirection = .Horizontal
    var previousPoint : CGPoint!
    let calendarMonthCellIdentifier = "cell"
    
    var numberOfEventTypes = 0
    var events = [eventHighlightStruct]()

    
    init(frame: CGRect?, needSeparator: Bool?, dayFormat: daysOfWeekFormat?, calendarScrollDirection: UICollectionViewScrollDirection) {
        
        if let frame = frame {
            super.init(frame: frame)
            self.calendarFrame = frame
            
        } else {
            super.init(frame: defaultFrameForCalendar)
            self.calendarFrame = defaultFrameForCalendar
        }
        if let needSeparator = needSeparator {
            self.needSeparator = needSeparator
        }
        if let dayFormat = dayFormat {
            self.dayFormat = dayFormat
        }
        calendarDirection = calendarScrollDirection
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        eventListRed = []
        if let dataSource = self.dataSource {
            numberOfEventTypes = dataSource.numberOfeventTypes(self)
            for eventType in 0..<numberOfEventTypes {
                events.append(dataSource.eventDetails(self, forEventType: eventType))
            }
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
        setToday()
        setUpCollectionView()
        
    }
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = calendarDirection
        layout.itemSize = calendarFrame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        calendarCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: calendarFrame.size.width, height: calendarFrame.size.height), collectionViewLayout: layout)
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        self.backgroundColor = calendarBackgroundColor
        calendarCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: calendarMonthCellIdentifier)
        calendarCollectionView.pagingEnabled = true
        self.addSubview(calendarCollectionView)
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsInMemory.count - 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier(calendarMonthCellIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.addSubview(monthsInMemory[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let presentPoint = scrollView.contentOffset
        let presentIndex = calendarCollectionView.indexPathForItemAtPoint(scrollView.contentOffset)!
        if calendarDirection == .Horizontal {
            if scrollView.contentOffset.x <= previousPoint.x {
//                if presentIndex.item <= monthsInMemory.count/2 {
                    previousMonth(presentIndex)
//                }
            }
            else {
//                if presentIndex.item >= monthsInMemory.count/2 {
                    nextMonth(presentIndex)
//                }
            }
        }
        else if calendarDirection == .Vertical {
            if scrollView.contentOffset.y <= previousPoint.y {
//                if presentIndex.item <= monthsInMemory.count/2 {
                    previousMonth(presentIndex)
//                }
            }
            else {
//                if presentIndex.item >= monthsInMemory.count/2 {
                    nextMonth(presentIndex)
//                }
            }
        }
        previousPoint = presentPoint
    }
    
    func previousMonth(presentIndex: NSIndexPath) {
        let leastMonth = monthsArray[0]
        var month = leastMonth.month - 1
        var year = leastMonth.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray.insert(dateStructure(day: leastMonth.day, month: month, year: year), atIndex: 0)
        monthsInMemory.insert(createDateButtons(monthsArray[0]), atIndex: 0)
        calendarCollectionView.reloadData()
        print(monthsArray.count)
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: presentIndex.item + 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: presentIndex.item + 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: monthsArray[presentIndex.item + 2].month, fromMonthName: monthDictionary[monthsArray[presentIndex.item + 2].month]!, fromYear: monthsArray[presentIndex.item + 2].year, toMonth: monthsArray[presentIndex.item + 1].month, toMonthName: monthDictionary[monthsArray[presentIndex.item + 1].month]!, toYear: monthsArray[presentIndex.item + 1].year)
            delegate.calendar(self, monthChange: changesMade)
        }
        
    }
    
    func nextMonth(presentIndex: NSIndexPath) {
        let maximumMonth = monthsArray[monthsArray.count - 1]
        var month = maximumMonth.month + 1
        var year = maximumMonth.year
        if month > 12 {
            year++
            month = month % 12
        }
        monthsArray.append(dateStructure(day: maximumMonth.day, month: month, year: year))
        monthsInMemory.append(createDateButtons(monthsArray[monthsArray.count - 1]))
        calendarCollectionView.reloadData()
        print(monthsArray.count)
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: presentIndex.item, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: presentIndex.item, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: monthsArray[presentIndex.item - 1].month, fromMonthName: monthDictionary[monthsArray[presentIndex.item - 1].month]!, fromYear: monthsArray[presentIndex.item - 1].year, toMonth: monthsArray[presentIndex.item].month, toMonthName: monthDictionary[monthsArray[presentIndex.item].month]!, toYear: monthsArray[presentIndex.item].year)
            delegate.calendar(self, monthChange: changesMade)
        }
    }

    func todayButton(sender: AnyObject) {
        setToday()
        calendarCollectionView.reloadData()
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            previousPoint = CGPoint(x: calendarFrame.size.width * 2, y: 0.0)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
            previousPoint = CGPoint(x: 0.0, y: calendarFrame.size.height * 2)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
    }
    
    func setToday() {
        monthsInMemory = []
        monthsArray = []
        for _ in 1...5 {
            monthsInMemory.append(UIView(frame: CGRectMake(0, 0, calendarFrame.size.width, calendarFrame.size.height)))
            let date = dateStructure(day: 0, month: 0, year: 0)
            monthsArray.append(date)
        }
        
        date = dateHelper.getDate()
        
        var month = date.month - 2
        var year = date.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[0] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[0] = createDateButtons(monthsArray[0])
        
        month = date.month - 1
        year = date.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[1] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[1] = createDateButtons(monthsArray[1])
        
        monthsArray[2] = date
        monthsInMemory[2] = createDateButtons(date)
        
        month = date.month + 1
        year = date.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[3] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[3] = createDateButtons(monthsArray[3])
        
        month = date.month + 2
        year = date.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[4] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[4] = createDateButtons(monthsArray[4])
    }

    func createDateButtons(date1: dateStructure) -> UIView {
        let baseView = UIView(frame: CGRectMake(0, 0, calendarFrame.size.width, calendarFrame.size.height))
        baseView.backgroundColor = calendarBackgroundColor
        createLabel(baseView)
        let buttonsViewFrame = CGRectMake(0, calendarFrame.size.height*(1.0/7.0), calendarFrame.size.width, calendarFrame.size.height*(6.0/7.0))
        let buttonsView = UIView()
        buttonsView.frame = buttonsViewFrame
        buttonsView.backgroundColor = calendarBackgroundColor
        baseView.addSubview(buttonsView)
        let buttonHeight = buttonsView.frame.size.height/6
        let buttonWidth = buttonsView.frame.size.width/7
        
        var startDay = dateHelper.getDayOfWeek(String(date1.year)+"-"+String(date1.month)+"-01")! - 1
        print(startDay)
        var dateButtons = [UIButton]()
        var lines = [UIView]()
        var days = 0
        var count = 0
        
        let maxDays = dateHelper.getMaxDays(date1.year, month: date1.month)
        
        for i in 0...5 {
            for j in 0...6 {
                if startDay <= 0 && days < maxDays {
                    dateButtons.append(UIButton(frame: CGRect(x: CGFloat(j) * buttonWidth, y: CGFloat(i) * buttonHeight, width: buttonWidth, height: buttonHeight)))
                    
                    dateButtons[days].setTitle(String(days+1), forState: UIControlState.Normal)
                    dateButtons[days].titleLabel?.font = dateFont
                    dateButtons[days].setTitleColor(dateColor, forState: UIControlState.Normal)
                    dateButtons[days].setTitleColor(dateHighlightedColor, forState: UIControlState.Highlighted)
                    if date1.year == dateHelper.getDate().year && date1.month == dateHelper.getDate().month && days+1 == dateHelper.getDate().day {
                        dateButtons[days].backgroundColor = todayColor
                        dateButtons[days].layer.cornerRadius = dateButtons[days].frame.size.width/2 
                    }
                    
                    for eventType in events {
                        let highlightImage = eventType.highlightImage
                        let events = eventType.eventsList
                        for event in events {
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                            let localDateTime = formatter.stringFromDate(event)
                            let eventStructure = dateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
                            if date1.year == eventStructure.year && date1.month == eventStructure.month && days+1 == eventStructure.day {
                                dateButtons[days].setBackgroundImage(highlightImage, forState: UIControlState.Normal)
                            }
                        }
                    }
                    
                    dateButtons[days].tag = days+1
                    dateButtons[days].addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.TouchUpInside)
                    buttonsView.addSubview(dateButtons[days])
                    days++
                    
                }
                else {
                    startDay--
                }
                count++
            }
            if needSeparator{
                lines.append(UIView(frame: CGRect(x: CGFloat(0), y: buttonHeight * CGFloat(i), width: buttonsView.frame.size.width, height: CGFloat(1))))
                lines[i].backgroundColor = separatorColor
                buttonsView.addSubview(lines[i])
            }
        }
        
        return baseView
    }
    
    //Button action method
    func didSelectDate(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.calendar(self, didSelectDay: dateStructure(day: sender.tag, month: monthsArray[1].month, year: monthsArray[1].year))
        }
    }
    
    func createLabel(viewToAddOn: UIView) {
        let labelHeight = calendarFrame.size.height/6.0
        let labelWidth = calendarFrame.size.width/7.0
        var dayOfWeek = [UILabel]()
        var weekDays = [String]()
        if dayFormat == .SingleLetter {
            weekDays = ["S","M","T","W","T","F","S"]
        }
        else {
            weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        }
        for i in 0...6 {
            dayOfWeek.append(UILabel(frame: CGRect(x: CGFloat(i) * labelWidth, y: CGFloat(0) , width: labelWidth, height: labelHeight)))
            dayOfWeek[i].text = weekDays[i]
            dayOfWeek[i].textAlignment = .Center
            dayOfWeek[i].font = dayOfWeekFont
            dayOfWeek[i].textColor = daysOfWeekColor
            viewToAddOn.addSubview(dayOfWeek[i])
        }
    }
    
    
    
    func forwardMonthAction(sender: AnyObject) {
        
        //        var month = date.1 + 1
        //        var year = date.2
        //        if month > 12 {
        //            year++
        //            month = month%12
        //        }
        
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
//                if let delegate = self.delegate {
//                    delegate.calendar(self, changedFromMonth: date.1, toMonth: month, fromYear: date.2, toYear: year)
//                }
        
        
        
        //        date = (date.0,month,year)
        //        createDateButtons(date)
        
    }
    //
    func reverseMonthAction(sender: AnyObject) {
        //
        //        var month = date.1 - 1
        //        var year = date.2
        //        if month <= 0 {
        //            year--
        //            month = 12 - month
        //        }
        
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        //        if let delegate = self.delegate {
        //            delegate.calendar(self, changedFromMonth: date.1, toMonth: month, fromYear: date.2, toYear: year)
        //        }
        //        date = (date.0,month,year)
        //        createDateButtons(date)
        //
    }

}


extension CustomizableCalendar {
    
    
    
    
    
    
    
    
    
    
    
}


