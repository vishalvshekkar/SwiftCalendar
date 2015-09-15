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
    
    //Pass along an array of dates that need to be highlighted in Red
    func calendarEventsForRedRing(calendar: CustomizableCalendar) -> [NSDate]
    
    //Pass along an array of dates that need to be highlighted in Blue
    func calendarEventsForBlueRing(calendar: CustomizableCalendar) -> [NSDate]
    
    //Format for the date that needs to be returned
    func dateFormatRequired(calendar: CustomizableCalendar) -> String
}


class CustomizableCalendar: UIControl, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let dateHelper = DateHelper()
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
    var calendarDirection : UICollectionViewScrollDirection = .Vertical

    
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
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        for _ in 1...3 {
            monthsInMemory.append(UIView(frame: CGRectMake(0, 0, calendarFrame.size.width, calendarFrame.size.height)))
            let date = dateStructure(day: 0, month: 0, year: 0)
            monthsArray.append(date)
        }
        eventListRed = []
        if let dataSource = self.dataSource {
            eventListRed = dataSource.calendarEventsForRedRing(self)
            eventListBlue = dataSource.calendarEventsForBlueRing(self)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
        formatEvents()
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
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        }
        self.backgroundColor = calendarBackgroundColor
        calendarCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        calendarCollectionView.pagingEnabled = true
        self.addSubview(calendarCollectionView)
    }
    
    func formatEvents() {
        for event in eventListRed {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            let localDateTime = formatter.stringFromDate(event)
            let eventStructure = dateStructure(day: Int(localDateTime[advance(localDateTime.startIndex, 8)...advance(localDateTime.startIndex, 9)])!, month: Int(localDateTime[advance(localDateTime.startIndex, 5)...advance(localDateTime.startIndex, 6)])!, year: Int(localDateTime[advance(localDateTime.startIndex, 0)...advance(localDateTime.startIndex, 3)])!)
            eventListRedStructured.append(eventStructure)
        }
        
        for event in eventListBlue {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            let localDateTime = formatter.stringFromDate(event)
            let eventStructure = dateStructure(day: Int(localDateTime[advance(localDateTime.startIndex, 8)...advance(localDateTime.startIndex, 9)])!, month: Int(localDateTime[advance(localDateTime.startIndex, 5)...advance(localDateTime.startIndex, 6)])!, year: Int(localDateTime[advance(localDateTime.startIndex, 0)...advance(localDateTime.startIndex, 3)])!)
            eventListBlueStructured.append(eventStructure)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.addSubview(monthsInMemory[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let presentPoint = scrollView.contentOffset
        print(presentPoint.x)
        if calendarDirection == .Horizontal {
            if presentPoint.x < calendarFrame.size.width && presentPoint.x >= 0.0 {
                previousMonth()
            }
            else if presentPoint.x >= calendarFrame.size.width && presentPoint.x < calendarFrame.size.width * 2 {
                
            }
            else {
                nextMonth()
            }
        }
        else if calendarDirection == .Vertical {
            if presentPoint.y < calendarFrame.size.height && presentPoint.y >= 0.0 {
                previousMonth()
            }
            else if presentPoint.y >= calendarFrame.size.height && presentPoint.y < calendarFrame.size.height * 2 {
                
            }
            else {
                nextMonth()
            }
        }
    }
    
    func nextMonth() {
        let holdingView = monthsInMemory[2]
        monthsInMemory[0] = monthsInMemory[1]
        monthsInMemory[1] = holdingView
        let holdingDate = monthsArray[2]
        monthsArray[0] = monthsArray[1]
        monthsArray[1] = holdingDate
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: monthsArray[0].month, fromMonthName: monthDictionary[monthsArray[0].month]!, fromYear: monthsArray[0].year, toMonth: holdingDate.month, toMonthName: monthDictionary[holdingDate.month]!, toYear: holdingDate.year)
            delegate.calendar(self, monthChange: changesMade)
        }
        var month = holdingDate.month + 1
        var year = holdingDate.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[2] = dateStructure(day: holdingDate.day, month: month, year: year)
        monthsInMemory[2] = createDateButtons(monthsArray[2])
    }
    
    func previousMonth() {
        let holdingView = monthsInMemory[0]
        monthsInMemory[2] = monthsInMemory[1]
        monthsInMemory[1] = holdingView
        let holdingDate = monthsArray[0]
        monthsArray[2] = monthsArray[1]
        monthsArray[1] = holdingDate
        if calendarDirection == .Horizontal {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
        else {
            calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: false)
        }
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: monthsArray[2].month, fromMonthName: monthDictionary[monthsArray[2].month]!, fromYear: monthsArray[2].year, toMonth: holdingDate.month, toMonthName: monthDictionary[holdingDate.month]!, toYear: holdingDate.year)
            delegate.calendar(self, monthChange: changesMade)
        }
        var month = holdingDate.month - 1
        var year = holdingDate.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[0] = dateStructure(day: holdingDate.day, month: month, year: year)
        monthsInMemory[0] = createDateButtons(monthsArray[0])
    }
    

    func todayButton(sender: AnyObject) {
        setToday()
        calendarCollectionView.reloadData()
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
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
                    
                    for event in eventListRedStructured {
                        if date1.year == event.year && date1.month == event.month && days+1 == event.day {
                            dateButtons[days].setBackgroundImage(UIImage(named: "perfectorangecircle"), forState: UIControlState.Normal)
                        }
                    }
                    
                    for event in eventListBlueStructured {
                        if date1.year == event.year && date1.month == event.month && days+1 == event.day {
                            dateButtons[days].setBackgroundImage(UIImage(named: "bluering"), forState: UIControlState.Normal)
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
    
    func setToday() {
        date = dateHelper.getDate()
        monthsInMemory[1] = createDateButtons(date)
        monthsArray[1] = date
        var month = date.month - 1
        var year = date.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[0] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[0] = createDateButtons(monthsArray[0])
        month = date.month + 1
        year = date.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[2] = dateStructure(day: date.day, month: month, year: year)
        monthsInMemory[2] = createDateButtons(monthsArray[2])
    }
    
    func forwardMonthAction(sender: AnyObject) {
        
        //        var month = date.1 + 1
        //        var year = date.2
        //        if month > 12 {
        //            year++
        //            month = month%12
        //        }
        
        calendarCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 2, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        //        if let delegate = self.delegate {
        //            delegate.calendar(self, changedFromMonth: date.1, toMonth: month, fromYear: date.2, toYear: year)
        //        }
        
        
        
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


