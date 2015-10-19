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
    func calendar(calendar: CustomizableCalendar, didSelectDay: DateStructure)
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
    var todayColor = UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1.0)
    var todayHighlightedColor = UIColor(red: 0.698, green: 0, blue: 0, alpha: 0.5)
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

class CustomizableCalendar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    private let dateHelper = DateHelper()
    let eventsModel = CalendarEventsModel()
    
    var defaultCalendarProperties = DefaultCalendarProperties()
    var events = CalendarEventsModel()
    
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
    
    init(frame: CGRect, calendarType: CalendarType) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout()
        if calendarType == CalendarType.ElaborateVertical {
            fullFrame = frame
            calendarFrame = CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.width)
            calendarDirection = .Vertical
            cellItemSize = CGSize(width: fullFrame.width, height: fullFrame.width)
            layout.itemSize = cellItemSize
            
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
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        calendarCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: fullFrame.width, height: fullFrame.height), collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        
        if let dataSource = self.dataSource {
            eventsModel.formatEvents(dataSource.eventDetails(self), continuousEvents: dataSource.continuousEvent(self))
        }
        
        if let delegate = self.delegate {
            let changesMade = monthYearStructure(fromMonth: dateHelper.getDate().month, fromMonthName: monthDictionary[dateHelper.getDate().month]!, fromYear: dateHelper.getDate().year, toMonth: dateHelper.getDate().month, toMonthName: monthDictionary[dateHelper.getDate().month]!, toYear: dateHelper.getDate().year)
            delegate.calendar(self, monthChange: changesMade)
        }
//        setToday()
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        
//        calendarCollectionView.frame = CGRect(x: 0, y: 0, width: calendarFrame.size.width, height: calendarFrame.size.height)
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
//        calendarCollectionView.registerClass(MonthView.self, forCellWithReuseIdentifier: calendarMonthCellIdentifier)
        calendarCollectionView.pagingEnabled = false
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.addSubview(calendarCollectionView)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (defaultCalendarProperties.presentYearSectionIndex * 2) + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = calendarCollectionView.dequeueReusableCellWithReuseIdentifier(calendarMonthCellIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        let monthView = MonthView(frame: CGRect(x: 0, y: 0, width: cellItemSize.width, height: cellItemSize.height), dateStruct: provideMonths(indexPath), eventsModel: self.eventsModel)
        
        let subViews = cell.subviews
        for sVs in subViews {
            sVs.removeFromSuperview()
        }
        cell.addSubview(monthView)
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
//        findOutFrame(calendarCollectionView.indexPathsForVisibleItems())
//        checkForCalendarScroll(scrollView)
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
    
    func findOutFrame(indexPathOfCell: [NSIndexPath]) {
        print(indexPathOfCell.count)
        let cell = calendarCollectionView.cellForItemAtIndexPath(indexPathOfCell[0])!
        let subViews = cell.contentView.subviews
        let subviewsOfSubview = subViews[0].subviews
        var requiredView = UIView()
        for views in subviewsOfSubview {
            if views is UILabel {
                
            }
            else {
                requiredView = views
            }
        }
        let sVs2 = requiredView.subviews
        var maxTag = 0
        for dateView in sVs2 {
            if dateView.tag > maxTag {
                maxTag = dateView.tag
            }
        }
        for dateView in sVs2 {
            if dateView.tag == maxTag {
                if let dateButton = dateView as? UIButton {
                    let frameOfLastButton = dateView.frame
                    if frameOfLastButton.origin.y == 5 * calendarFrame.size.height*(6.0/7.0)/6 {
                        print("Larger Frame")
                    }
                    else {
                        print("Smaller Frame")
                    }
                }
                else {
                    print("Not a button!!!")
                }
            }
        }
    }
    
    func checkForCalendarScroll(scrollView: UIScrollView) {
        let presentPoint = scrollView.contentOffset
        print(scrollView.contentOffset)
        if calendarDirection == .Horizontal {
            if let presentIndex = calendarCollectionView.indexPathForItemAtPoint(scrollView.contentOffset) {
                print("Present Index: \(presentIndex.item)")
                if scrollView.contentOffset.x <= previousPoint.x {
                    presentMonth = presentIndex.item
                    previousMonth(presentIndex)
                }
                else {
                    presentMonth = presentIndex.item
                    nextMonth(presentIndex)
                }
                previousPoint = presentPoint
                print("MonthsArray Count = \(monthsArray.count)")
            }
        }
        else if calendarDirection == .Vertical {
            if let presentIndex = calendarCollectionView.indexPathForItemAtPoint(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + fullFrame.height/2)) {
                if scrollView.contentOffset.y <= previousPoint.y {
                    presentMonth = presentIndex.item
                    previousMonth(presentIndex)
                }
                else {
                    presentMonth = presentIndex.item
                    nextMonth(presentIndex)
                }
                previousPoint = presentPoint
                print("MonthsArray Count = \(monthsArray.count)")
            }
        }
    }
    
    func previousMonth(presentIndex: NSIndexPath) {
        if presentIndex.item < 2 {
            let leastMonth = monthsArray[0]
            var month = leastMonth.month - 1
            var year = leastMonth.year
            if month <= 0 {
                year--
                month = 12 - month
            }
            monthsArray.insert(DateStructure(day: leastMonth.day, month: month, year: year), atIndex: 0)
            monthsInMemory.insert(createDateButtons(monthsArray[0]), atIndex: 0)
            calendarCollectionView.reloadData()
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
            presentDate = DateStructure(day: presentDate.day, month: monthsArray[presentIndex.item + 1].month, year: monthsArray[presentIndex.item + 1].year)
        }
        else {
            if let delegate = self.delegate {
                let changesMade = monthYearStructure(fromMonth: monthsArray[presentIndex.item + 1].month, fromMonthName: monthDictionary[monthsArray[presentIndex.item + 1].month]!, fromYear: monthsArray[presentIndex.item + 1].year, toMonth: monthsArray[presentIndex.item].month, toMonthName: monthDictionary[monthsArray[presentIndex.item ].month]!, toYear: monthsArray[presentIndex.item].year)
                delegate.calendar(self, monthChange: changesMade)
            }
            presentDate = DateStructure(day: presentDate.day, month: monthsArray[presentIndex.item].month, year: monthsArray[presentIndex.item].year)
        }
    }
    
    func nextMonth(presentIndex: NSIndexPath) {
        print(presentIndex.item)
        print(monthsArray.count - 2)
        if presentIndex.item > monthsArray.count - 3 {
            let maximumMonth = monthsArray[monthsArray.count - 1]
            var month = maximumMonth.month + 1
            var year = maximumMonth.year
            if month > 12 {
                year++
                month = month % 12
            }
            monthsArray.append(DateStructure(day: maximumMonth.day, month: month, year: year))
            monthsInMemory.append(createDateButtons(monthsArray[monthsArray.count - 1]))
            calendarCollectionView.reloadData()
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
            presentDate = DateStructure(day: presentDate.day, month: monthsArray[presentIndex.item].month, year: monthsArray[presentIndex.item].year)
        }
        else {
            if let delegate = self.delegate {
                let changesMade = monthYearStructure(fromMonth: monthsArray[presentIndex.item - 1].month, fromMonthName: monthDictionary[monthsArray[presentIndex.item - 1].month]!, fromYear: monthsArray[presentIndex.item - 1].year, toMonth: monthsArray[presentIndex.item].month, toMonthName: monthDictionary[monthsArray[presentIndex.item].month]!, toYear: monthsArray[presentIndex.item].year)
                delegate.calendar(self, monthChange: changesMade)
            }
            presentDate = DateStructure(day: presentDate.day, month: monthsArray[presentIndex.item].month, year: monthsArray[presentIndex.item].year)
        }
    }
    
//    func adjustFrame(presentIndex: NSIndexPath) {
//        print(presentIndex.item)
//        print(presentIndex.section)
//        let cellToAdjust = calendarCollectionView
//        let sVs = cellToAdjust?.contentView.subviews
//        
//    }
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        let sVs = cell.contentView.subviews
//        
//        let sVs1 = sVs[0].subviews
//        var requiredView = UIView()
//        for views in sVs1 {
//            if views is UILabel {
//                
//            }
//            else {
//                requiredView = views
//            }
//        }
//        let sVs2 = requiredView.subviews
////        print(sVs2.count)
//        var maxTag = 0
//        for dateView in sVs2 {
//            if dateView.tag > maxTag {
//                maxTag = dateView.tag
//            }
//        }
//        print(maxTag)
//    }

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
    
    func setToday() {
        monthsInMemory = []
        monthsArray = []
        for _ in 1...5 {
            monthsInMemory.append(UIView(frame: CGRectMake(0, 0, calendarFrame.size.width, calendarFrame.size.height)))
            let date = DateStructure(day: 0, month: 0, year: 0)
            monthsArray.append(date)
        }
        
        date = dateHelper.getDate()
        
        var month = date.month - 2
        var year = date.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[0] = DateStructure(day: date.day, month: month, year: year)
        monthsInMemory[0] = createDateButtons(monthsArray[0])
        
        month = date.month - 1
        year = date.year
        if month <= 0 {
            year--
            month = 12 - month
        }
        monthsArray[1] = DateStructure(day: date.day, month: month, year: year)
        monthsInMemory[1] = createDateButtons(monthsArray[1])
        
        
        monthsArray[2] = date
        monthsInMemory[2] = createDateButtons(date)
        presentMonth = 2
        presentDate = date
        monthsInMemory[2].tag = 22
        
        month = date.month + 1
        year = date.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[3] = DateStructure(day: date.day, month: month, year: year)
        monthsInMemory[3] = createDateButtons(monthsArray[3])
        
        month = date.month + 2
        year = date.year
        if month > 12 {
            year++
            month = month%12
        }
        monthsArray[4] = DateStructure(day: date.day, month: month, year: year)
        monthsInMemory[4] = createDateButtons(monthsArray[4])
    }


    func createDateButtons(date1: DateStructure) -> UIView {
        let baseView = UIView(frame: CGRectMake(0, 0, calendarFrame.size.width, calendarFrame.size.height))
        baseView.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
        baseView.tag = Int(String(date1.month) + String(date1.year))!
        print("tag is")
        print(baseView.tag)
        createLabel(baseView)
        let buttonsViewFrame = CGRectMake(0, calendarFrame.size.height*(1.0/7.0), calendarFrame.size.width, calendarFrame.size.height*(6.0/7.0))
        let buttonsView = UIView()
        buttonsView.frame = buttonsViewFrame
        buttonsView.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
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
                    dateButtons[days].titleLabel?.font = defaultCalendarProperties.dateFont
                    dateButtons[days].setTitleColor(defaultCalendarProperties.dateColor, forState: UIControlState.Normal)
                    dateButtons[days].setTitleColor(defaultCalendarProperties.dateHighlightedColor, forState: UIControlState.Highlighted)
                    
                    let now = DateStructure(day: days+1, month: date1.month, year: date1.year)
                    if now.year == dateHelper.getDate().year && now.month == dateHelper.getDate().month && now.day == dateHelper.getDate().day {
                        let todayHighlightShapeLayer = CAShapeLayer()
                        todayHighlightShapeLayer.frame = CGRect(x: dateButtons[days].frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, y: dateButtons[days].frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, width: dateButtons[days].frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2, height: dateButtons[days].frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2)
                        todayHighlightShapeLayer.zPosition = -1
                        dateButtons[days].layer.addSublayer(todayHighlightShapeLayer)
                        todayHighlightShapeLayer.fillColor = defaultCalendarProperties.todayColor.CGColor
                        todayHighlightShapeLayer.path = UIBezierPath(roundedRect: todayHighlightShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: todayHighlightShapeLayer.frame.size.height/2, height: todayHighlightShapeLayer.frame.size.height/2)).CGPath
                    }
                    
                    if days + 1 == 1 {
                        let monthLabel = UILabel(frame: CGRect(x: 0, y: -dateButtons[days].frame.size.height/5, width: dateButtons[days].frame.size.width, height: dateButtons[days].frame.size.height/3))
                        monthLabel.text = dateHelper.getMonthString(date1.month, stringType: StringType.ThreeLetterAllButFirstLower)
                        monthLabel.textAlignment = .Center
                        monthLabel.font = defaultCalendarProperties.dayOfWeekFont
                        monthLabel.textColor = UIColor.whiteColor()
                        dateButtons[days].addSubview(monthLabel)
                    }
                    
                    if now.month == 1 {
                        let yearLabel = UILabel(frame: CGRect(x: 0, y: -dateButtons[days].frame.size.height/4, width: buttonsView.frame.size.width, height: dateButtons[days].frame.size.height/3))
                        yearLabel.text = "\(now.year)"
                        yearLabel.textAlignment = .Center
                        yearLabel.font = defaultCalendarProperties.dayOfWeekFont
                        yearLabel.textColor = UIColor.whiteColor()
                        buttonsView.addSubview(yearLabel)
                    }
                    
                    if let eventType = eventsModel.formattedEvents[now.year]?[now.month]?[now.day] {
                        addEventHighlights(dateButtons[days], highlightType: eventType)
                    }
                    
                    dateButtons[days].tag = days + 1
                    dateButtons[days].addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.TouchUpInside)
                    buttonsView.addSubview(dateButtons[days])
                    days++
                    
                }
                else {
                    startDay--
                }
                count++
            }
            if defaultCalendarProperties.needSeparator{
                lines.append(UIView(frame: CGRect(x: CGFloat(0), y: buttonHeight * CGFloat(i), width: buttonsView.frame.size.width, height: CGFloat(1))))
                lines[i].backgroundColor = defaultCalendarProperties.separatorColor
                buttonsView.addSubview(lines[i])
            }
        }
        
        return baseView
    }
    
    func addEventHighlights(viewToAddOn: UIView, highlightType: EventType) {
        if highlightType == EventType.StartUnavailable {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            circleShapeLayer.zPosition = -2
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
            
            let rectangleShapeLayer = CAShapeLayer()
            rectangleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width/2, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width/2+2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            rectangleShapeLayer.zPosition = -2
            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
        }
        else if highlightType == EventType.IntermediateUnavailable {
            let rectangleShapeLayer = CAShapeLayer()
            rectangleShapeLayer.frame = CGRect(x: 0, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width+1, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            rectangleShapeLayer.zPosition = -2
            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
        }
        else if highlightType == EventType.EndUnavailable {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            circleShapeLayer.zPosition = -2
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
            
            let rectangleShapeLayer = CAShapeLayer()
            rectangleShapeLayer.frame = CGRect(x: 0, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width/2+2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            rectangleShapeLayer.zPosition = -2
            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
        }
        else if highlightType == EventType.SingleDayUnavailable {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            circleShapeLayer.zPosition = -2
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        }
        else if highlightType == EventType.UnconfirmedEvent {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2)
            circleShapeLayer.zPosition = -1
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = UIColor.clearColor().CGColor
            circleShapeLayer.strokeColor = UIColor.redColor().CGColor
            circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        }
        else if highlightType == EventType.ConfirmedEvent {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2)
            circleShapeLayer.zPosition = -1
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = UIColor.clearColor().CGColor
            circleShapeLayer.strokeColor = defaultCalendarProperties.eventColor.CGColor
            circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        }
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
//            viewToAddOn.addSubview(dayOfWeek[i])
        }
    }
    
    
    
    //Button action method
    func didSelectDate(sender: UIButton) {
        presentDate.day = sender.tag
        if let delegate = self.delegate {
            delegate.calendar(self, didSelectDay: DateStructure(day: presentDate.day, month: presentDate.month, year: presentDate.year))
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


