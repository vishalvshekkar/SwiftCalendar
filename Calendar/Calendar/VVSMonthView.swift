//
//  MonthView.swift
//  Calendar
//
//  Created by Vishal on 10/16/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit

protocol MonthsViewDelegate {
    
    func didUpdateEvents()
    func didSelectDate(date: NSDate)
    
}

class MonthView: UIView {
    
    var isEditable: Bool = false
    var delegate : MonthsViewDelegate!
    var defaultCalendarProperties: DefaultCalendarProperties!
    
    var dateStruct : DateStructure!
    var eventsModel : CalendarEventsModel!
    let buttonsView = UIView()
    var calendarType : CalendarType!
    var dateSelectionBackGroundView: UIView?
    var selectedDate: DateStructure?
    var customizableCalendar: CustomizableCalendar!
    
    init(frame: CGRect, dateStruct : DateStructure, eventsModel : CalendarEventsModel, delegate: MonthsViewDelegate, calendarType: CalendarType, selectedDate: DateStructure?, superView: CustomizableCalendar, isEditable: Bool, defaultCalendarProperties: DefaultCalendarProperties) {
        super.init(frame: frame)
        for subView in self.subviews
        {
            subView.removeFromSuperview()
        }
        self.dateStruct = dateStruct
        self.defaultCalendarProperties = defaultCalendarProperties
        self.eventsModel = eventsModel
        self.delegate = delegate
        self.calendarType = calendarType
        self.selectedDate = selectedDate
        self.customizableCalendar = superView
        self.isEditable = isEditable
        self.addSubview(createDateButtons(self.dateStruct))
    }
    
//    init(frame: CGRect, dateStruct : DateStructure, eventsModel : CalendarEventsModel, delegate: MonthsViewDelegate, calendarType: CalendarType, selectedDate: DateStructure?, superView: CustomizableCalendar) {
//        self.dateStruct = dateStruct
//        self.eventsModel = eventsModel
//        self.delegate = delegate
//        super.init(frame: frame)
//        self.calendarType = calendarType
//        self.addSubview(createDateButtons(self.dateStruct))
//    }
//
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createDateButtons(date1: DateStructure) -> UIView {
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        baseView.backgroundColor = UIColor.clearColor()
        baseView.tag = Int(String(date1.month) + String(date1.year))!
        if calendarType == CalendarType.SimpleHorizontal || calendarType == CalendarType.CalendarFeed {
            createLabel(baseView)
        }
        let buttonsViewFrame: CGRect
        
        if calendarType == CalendarType.ElaborateVertical || calendarType == CalendarType.SimpleDateSelection {
            buttonsViewFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        else {
            buttonsViewFrame = CGRect(x: 0, y: self.frame.size.height*(1.0/7.0), width: self.frame.size.width, height: self.frame.size.height*(6.0/7.0))
        }
        
        buttonsView.frame = buttonsViewFrame
        buttonsView.backgroundColor = UIColor.clearColor()
        baseView.addSubview(buttonsView)
        let buttonHeight = buttonsView.frame.size.height/6
        let buttonWidth = buttonsView.frame.size.width/7
        
        var startDay = DateHelper.getDayOfWeek(String(date1.year)+"-"+String(date1.month)+"-01")! - 1
        var dateButtons = [UIButton]()
        var lines = [UIView]()
        var days = 0
        var count = 0
        
        let maxDays = DateHelper.getMaxDays(date1.year, month: date1.month)
        
        for i in 0...5 {
            for j in 0...6 {
                if startDay <= 0 && days < maxDays {
                    dateButtons.append(UIButton(frame: CGRect(x: CGFloat(j) * buttonWidth, y: CGFloat(i) * buttonHeight, width: buttonWidth, height: buttonHeight)))
                    
                    dateButtons[days].setTitle(String(days+1), forState: UIControlState.Normal)
                    dateButtons[days].titleLabel?.font = defaultCalendarProperties.dateFont
                    let now = DateStructure(day: days+1, month: date1.month, year: date1.year)
                    if calendarType == CalendarType.SimpleDateSelection
                    {
                        if now.getNSDate().timeIntervalSince1970 < DateHelper.getDate().getNSDate().timeIntervalSince1970
                        {
                            dateButtons[days].setTitleColor(defaultCalendarProperties.pastDateColor, forState: UIControlState.Normal)
                            dateButtons[days].userInteractionEnabled = false
                        }
                        else
                        {
                            dateButtons[days].setTitleColor(defaultCalendarProperties.dateColor, forState: UIControlState.Normal)
                            dateButtons[days].setTitleColor(defaultCalendarProperties.dateHighlightedColor, forState: UIControlState.Highlighted)
                            dateButtons[days].userInteractionEnabled = true
                            dateButtons[days].tag = days + 1
                            dateButtons[days].addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.TouchUpInside)
                        }
                    }
                    else
                    {
                        dateButtons[days].setTitleColor(defaultCalendarProperties.dateColor, forState: UIControlState.Normal)
                        dateButtons[days].setTitleColor(defaultCalendarProperties.dateHighlightedColor, forState: UIControlState.Highlighted)
                        if calendarType == CalendarType.ElaborateVertical
                        {
                            if now.getNSDate().timeIntervalSince1970 < DateHelper.getDate().getNSDate().timeIntervalSince1970
                            {
                                dateButtons[days].setTitleColor(defaultCalendarProperties.pastDateColor, forState: UIControlState.Normal)
                                dateButtons[days].userInteractionEnabled = false
                            }
                            else
                            {
                                dateButtons[days].userInteractionEnabled = isEditable
                            }
                        }
                        else
                        {
                            dateButtons[days].userInteractionEnabled = true
                        }
                        dateButtons[days].tag = days + 1
                        dateButtons[days].addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    
                    if calendarType == CalendarType.SimpleDateSelection || calendarType == CalendarType.ElaborateVertical
                    {
                        if days + 1 == 1 {
                            let monthLabel = UILabel(frame: CGRect(x: 0, y: -dateButtons[days].frame.size.height/5, width: dateButtons[days].frame.size.width, height: dateButtons[days].frame.size.height/3))
                            monthLabel.text = DateHelper.getMonthString(date1.month, stringType: StringType.ThreeLetterAllButFirstLower)
                            monthLabel.textAlignment = .Center
                            monthLabel.font = defaultCalendarProperties.dayOfWeekFont
                            monthLabel.backgroundColor = UIColor.clearColor()
                            if now.year == DateHelper.getDate().year && now.month == DateHelper.getDate().month
                            {
                                monthLabel.textColor = UIColor.greenColor()
                            }
                            else
                            {
                                monthLabel.textColor = UIColor.whiteColor()
                            }
                            dateButtons[days].addSubview(monthLabel)
                        }
                    }
                    
//                    if now.month == 1 {
//                        let yearLabel = UILabel(frame: CGRect(x: 0, y: -dateButtons[days].frame.size.height/4, width: buttonsView.frame.size.width, height: dateButtons[days].frame.size.height/3))
//                        yearLabel.text = "\(now.year)"
//                        yearLabel.textAlignment = .Center
//                        yearLabel.font = defaultCalendarProperties.dayOfWeekFont
//                        yearLabel.textColor = UIColor.whiteColor()
//                        buttonsView.addSubview(yearLabel)
//                    }
                    if calendarType != CalendarType.SimpleDateSelection
                    {
                        if let eventType = eventsModel.formattedEvents[now.year]?[now.month]?[now.day] {
                            addEventHighlights(dateButtons[days], highlightType: eventType)
                        }
                        
                        if now.year == DateHelper.getDate().year && now.month == DateHelper.getDate().month && now.day == DateHelper.getDate().day {
                            
                            //                            let todayHighlightShapeLayer = CAShapeLayer()
                            //                            todayHighlightShapeLayer.frame = CGRect(x: dateButtons[days].center.x - dateButtons[days].frame.size.height*0.075, y: dateButtons[days].frame.size.height*0.7, width: dateButtons[days].frame.size.height*0.15, height: dateButtons[days].frame.size.height*0.15)
                            //                            todayHighlightShapeLayer.zPosition = -1
                            //                            dateButtons[days].layer.addSublayer(todayHighlightShapeLayer)
                            dateButtons[days].setTitleColor(defaultCalendarProperties.todayColor, forState: UIControlState.Normal)
                            //                            todayHighlightShapeLayer.fillColor = defaultCalendarProperties.todayColor.CGColor
                            //                            todayHighlightShapeLayer.path = UIBezierPath(roundedRect: todayHighlightShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: todayHighlightShapeLayer.frame.size.height/2, height: todayHighlightShapeLayer.frame.size.height/2)).CGPath
                            
                            let todayHighlightShapeLayer = CAShapeLayer()
                            todayHighlightShapeLayer.frame = CGRect(
                                x: dateButtons[days].frame.size.width/2 - dateButtons[days].frame.size.width*0.070,
                                y: dateButtons[days].frame.size.height*0.85,
                                width: dateButtons[days].frame.size.width*0.15,
                                height: dateButtons[days].frame.size.width*0.15
                            )
                            todayHighlightShapeLayer.zPosition = -1
                            dateButtons[days].layer.addSublayer(todayHighlightShapeLayer)
                            todayHighlightShapeLayer.fillColor = defaultCalendarProperties.todayColor.CGColor
                            todayHighlightShapeLayer.path = UIBezierPath(roundedRect: todayHighlightShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: todayHighlightShapeLayer.frame.size.height/2, height: todayHighlightShapeLayer.frame.size.height/2)).CGPath
                        }
                    }
                    buttonsView.addSubview(dateButtons[days])
                    if calendarType == CalendarType.SimpleDateSelection
                    {
                        if let selectedDate = selectedDate where DateStructure.areEqual(selectedDate, date2: now)
                        {
                            manageDateSelection(dateButtons[days].tag)
                        }
                    }
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
            (viewToAddOn as! UIButton).setTitleColor(defaultCalendarProperties.continuousEventTextColor, forState: UIControlState.Normal)
        }
        else if highlightType == EventType.IntermediateUnavailable {
            let rectangleShapeLayer = CAShapeLayer()
            rectangleShapeLayer.frame = CGRect(x: 0, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width+1, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            rectangleShapeLayer.zPosition = -2
            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
            (viewToAddOn as! UIButton).setTitleColor(defaultCalendarProperties.continuousEventTextColor, forState: UIControlState.Normal)
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
            (viewToAddOn as! UIButton).setTitleColor(defaultCalendarProperties.continuousEventTextColor, forState: UIControlState.Normal)
        }
        else if highlightType == EventType.SingleDayUnavailable {
            let circleShapeLayer = CAShapeLayer()
            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
            circleShapeLayer.zPosition = -2
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
            (viewToAddOn as! UIButton).setTitleColor(defaultCalendarProperties.continuousEventTextColor, forState: UIControlState.Normal)
        }
            
        if highlightType == EventType.UnconfirmedEvent {
            let circleShapeLayer = CAShapeLayer()
            let dimension = viewToAddOn.frame.size.height < viewToAddOn.frame.size.width ? viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2 : viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2
            circleShapeLayer.frame = CGRect(x: (viewToAddOn.frame.size.width - dimension)/2, y: (viewToAddOn.frame.size.height - dimension)/2, width: dimension, height: dimension)
            circleShapeLayer.zPosition = -1
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: circleShapeLayer.frame.size), cornerRadius: circleShapeLayer.frame.width/2).CGPath
            circleShapeLayer.lineDashPattern = [4,3]
            circleShapeLayer.fillColor = UIColor.clearColor().CGColor
            circleShapeLayer.strokeColor = defaultCalendarProperties.eventColor.CGColor
            circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
   
        }
        if highlightType == EventType.ConfirmedEvent {
            let circleShapeLayer = CAShapeLayer()
            let dimension = viewToAddOn.frame.size.height < viewToAddOn.frame.size.width ? viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2 : viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2
            circleShapeLayer.frame = CGRect(x: (viewToAddOn.frame.size.width - dimension)/2, y: (viewToAddOn.frame.size.height - dimension)/2, width: dimension, height: dimension)
            circleShapeLayer.zPosition = -1
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = UIColor.clearColor().CGColor
            circleShapeLayer.strokeColor = defaultCalendarProperties.eventColor.CGColor
            circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        }
        if highlightType == EventType.CancelledDay {
            let circleShapeLayer = CAShapeLayer()
            let dimension = viewToAddOn.frame.size.height < viewToAddOn.frame.size.width ? viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2 : viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2
            circleShapeLayer.frame = CGRect(x: (viewToAddOn.frame.size.width - dimension)/2, y: (viewToAddOn.frame.size.height - dimension)/2, width: dimension, height: dimension)
            circleShapeLayer.zPosition = -1
            viewToAddOn.layer.addSublayer(circleShapeLayer)
            circleShapeLayer.fillColor = UIColor.clearColor().CGColor
            circleShapeLayer.strokeColor = defaultCalendarProperties.cancelledEventColor.CGColor
            circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        }
    }
    
    func degreeToRadian(degree: CGFloat) -> CGFloat
    {
        return (CGFloat(degree) * CGFloat(M_PI)) / CGFloat(180.0)
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
            dayOfWeek[i].backgroundColor = UIColor.clearColor()
            viewToAddOn.addSubview(dayOfWeek[i])
        }
    }
    
    func didSelectDate(sender: UIButton)
    {
        if calendarType == CalendarType.SimpleDateSelection
        {
            manageDateSelection(sender.tag)
            if let delegate = delegate {
                var dateTapped = self.dateStruct
                dateTapped.day = sender.tag
                delegate.didSelectDate(dateTapped.getNSDate())
            }
        }
        else
        {
            if let delegate = delegate {
                var dateTapped = self.dateStruct
                dateTapped.day = sender.tag
                delegate.didSelectDate(dateTapped.getNSDate())
            }
            if calendarType == CalendarType.ElaborateVertical
            {
                manageEvents(sender.tag)
            }
        }
    }
    
    private func manageDateSelection(buttonTag: Int)
    {
        let buttonTapped = buttonsView.viewWithTag(buttonTag)!
        var dateTapped = self.dateStruct
        dateTapped.day = buttonTag
        if dateSelectionBackGroundView == nil
        {
            dateSelectionBackGroundView = buttonTapped
            addSelectionShape(dateSelectionBackGroundView!)
        }
        else
        {
            removeSelectionShape(dateSelectionBackGroundView!)
            dateSelectionBackGroundView = buttonTapped
            addSelectionShape(dateSelectionBackGroundView!)
        }
        customizableCalendar.selectedDate = dateTapped
    }
    
    private func addSelectionShape(viewToAddOn: UIView)
    {
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.frame = CGRect(
            x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2),
            y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2),
            width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale,
            height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale
        )
        circleShapeLayer.zPosition = -2
        viewToAddOn.layer.addSublayer(circleShapeLayer)
        circleShapeLayer.fillColor = UIColor.greenColor().CGColor
        circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
        (viewToAddOn as! UIButton).setTitleColor(defaultCalendarProperties.selectedDateColor, forState: UIControlState.Normal)
    }
    
    private func removeSelectionShape(fromView: UIView)
    {
        if let drawingLayers = fromView.layer.sublayers {
            for layer in drawingLayers {
                if layer is CAShapeLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        (fromView as! UIButton).setTitleColor(defaultCalendarProperties.dateColor, forState: UIControlState.Normal)
    }
    
    func manageEvents(buttonTag: Int) {
        let buttonTapped = buttonsView.viewWithTag(buttonTag)!
        var dateTapped = self.dateStruct
        dateTapped.day = buttonTag
        if let tappedEventType = eventsModel.getEventTypeForDate(dateTapped) {
            if tappedEventType == EventType.EndUnavailable {
                if let drawingLayers = buttonTapped.layer.sublayers {
                    for layer in drawingLayers {
                        if layer is CAShapeLayer {
                            layer.removeFromSuperlayer()
                        }
                    }
                    
                    let previousDay = dateTapped.getPreviousDay()
                    
                    if let month = eventsModel.formattedEvents[dateTapped.year]
                    {
                        if let _ = month[dateTapped.month]
                        {
                            eventsModel.formattedEvents[dateTapped.year]![dateTapped.month]![dateTapped.day] = nil
                        }
                        else {
                        }
                    }
                    else {
                    }
                    let previousDayEventType = eventsModel.getEventTypeForDate(previousDay)
                    if let month = eventsModel.formattedEvents[previousDay.year] {
                        if let day = month[previousDay.month] {
                            if day[previousDay.day] == EventType.StartUnavailable {
                                eventsModel.formattedEvents[previousDay.year]![previousDay.month]![previousDay.day] = EventType.SingleDayUnavailable
                            }
                            else if day[previousDay.day] == EventType.IntermediateUnavailable {
                                eventsModel.formattedEvents[previousDay.year]![previousDay.month]![previousDay.day] = EventType.EndUnavailable
                            }
                        }
                    }
                    
                    if dateTapped.month == previousDay.month {
                        let previousButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        
                        if previousDayEventType == EventType.StartUnavailable {
                            addEventHighlights(previousButton, highlightType: EventType.SingleDayUnavailable)
                        }
                        else if previousDayEventType == EventType.IntermediateUnavailable {
                            addEventHighlights(previousButton, highlightType: EventType.EndUnavailable)
                        }
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            else if tappedEventType == EventType.IntermediateUnavailable {
                if let drawingLayers = buttonTapped.layer.sublayers {
                    for layer in drawingLayers {
                        if layer is CAShapeLayer {
                            layer.removeFromSuperlayer()
                        }
                    }
                    let nextDay = dateTapped.getNextDay()
                    let previousDay = dateTapped.getPreviousDay()
                    
                    if let month = eventsModel.formattedEvents[dateTapped.year]
                    {
                        if let _ = month[dateTapped.month]
                        {
                            eventsModel.formattedEvents[dateTapped.year]![dateTapped.month]![dateTapped.day] = nil
                        }
                        else {
                        }
                    }
                    else {
                    }
                    
                    let previousDayEventType = eventsModel.getEventTypeForDate(previousDay)
                    if let month = eventsModel.formattedEvents[previousDay.year] {
                        if let day = month[previousDay.month] {
                            if day[previousDay.day] == EventType.StartUnavailable {
                                eventsModel.formattedEvents[previousDay.year]![previousDay.month]![previousDay.day] = EventType.SingleDayUnavailable
                            }
                            else if day[previousDay.day] == EventType.IntermediateUnavailable {
                                eventsModel.formattedEvents[previousDay.year]![previousDay.month]![previousDay.day] = EventType.EndUnavailable
                            }
                        }
                    }
                    
                    let nextDayEventType = eventsModel.getEventTypeForDate(nextDay)
                    if let month = eventsModel.formattedEvents[nextDay.year] {
                        if let day = month[nextDay.month] {
                            if day[nextDay.day] == EventType.EndUnavailable {
                                eventsModel.formattedEvents[nextDay.year]![nextDay.month]![nextDay.day] = EventType.SingleDayUnavailable
                            }
                            else if day[nextDay.day] == EventType.IntermediateUnavailable {
                                eventsModel.formattedEvents[nextDay.year]![nextDay.month]![nextDay.day] = EventType.StartUnavailable
                            }
                        }
                    }
                    
                    if dateTapped.month == nextDay.month {
                        let nextButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        
                        if nextDayEventType == EventType.EndUnavailable {
                            addEventHighlights(nextButton, highlightType: EventType.SingleDayUnavailable)
                        }
                        else if nextDayEventType == EventType.IntermediateUnavailable {
                            addEventHighlights(nextButton, highlightType: EventType.StartUnavailable)
                        }
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                    
                    if dateTapped.month == previousDay.month {
                        let previousButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        
                        if previousDayEventType == EventType.StartUnavailable {
                            addEventHighlights(previousButton, highlightType: EventType.SingleDayUnavailable)
                        }
                        else if previousDayEventType == EventType.IntermediateUnavailable {
                            addEventHighlights(previousButton, highlightType: EventType.EndUnavailable)
                        }
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            else if tappedEventType == EventType.StartUnavailable {
                if let drawingLayers = buttonTapped.layer.sublayers {
                    for layer in drawingLayers {
                        if layer is CAShapeLayer {
                            layer.removeFromSuperlayer()
                        }
                    }
                    
                    let nextDay = dateTapped.getNextDay()
                    
                    if let month = eventsModel.formattedEvents[dateTapped.year]
                    {
                        if let _ = month[dateTapped.month]
                        {
                            eventsModel.formattedEvents[dateTapped.year]![dateTapped.month]![dateTapped.day] = nil
                        }
                        else {
                        }
                    }
                    else {
                    }
                    
                    let nextDayEventType = eventsModel.getEventTypeForDate(nextDay)
                    if let month = eventsModel.formattedEvents[nextDay.year] {
                        if let day = month[nextDay.month] {
                            if day[nextDay.day] == EventType.EndUnavailable {
                                eventsModel.formattedEvents[nextDay.year]![nextDay.month]![nextDay.day] = EventType.SingleDayUnavailable
                            }
                            else if day[nextDay.day] == EventType.IntermediateUnavailable {
                                eventsModel.formattedEvents[nextDay.year]![nextDay.month]![nextDay.day] = EventType.StartUnavailable
                            }
                        }
                    }
                    
                    
                    if dateTapped.month == nextDay.month {
                        let nextButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        
                        if nextDayEventType == EventType.EndUnavailable {
                            addEventHighlights(nextButton, highlightType: EventType.SingleDayUnavailable)
                        }
                        else if nextDayEventType == EventType.IntermediateUnavailable {
                            addEventHighlights(nextButton, highlightType: EventType.StartUnavailable)
                        }
                        
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            else if tappedEventType == EventType.SingleDayUnavailable {
                if let drawingLayers = buttonTapped.layer.sublayers {
                    for layer in drawingLayers {
                        if layer is CAShapeLayer {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                
                if let month = eventsModel.formattedEvents[dateTapped.year]
                {
                    if let _ = month[dateTapped.month]
                    {
                        eventsModel.formattedEvents[dateTapped.year]![dateTapped.month]![dateTapped.day] = nil
                    }
                    else {
                    }
                }
                else {
                }
            }
        }
        else {
            let nextDay = dateTapped.getNextDay()
            let previousDay = dateTapped.getPreviousDay()
            
            let nextDayEvent = eventsModel.getEventTypeForDate(nextDay)
            let previousDayEvent = eventsModel.getEventTypeForDate(previousDay)
            
            let weekDay = DateHelper.getDayOfWeek(dateTapped.getNSDate())
            let lastDay = DateHelper.getMaxDays(dateTapped.year, month: dateTapped.month)
            
            if (nextDayEvent == nil || nextDayEvent == EventType.ConfirmedEvent || nextDayEvent == EventType.UnconfirmedEvent) && (previousDayEvent == nil || previousDayEvent == EventType.ConfirmedEvent || previousDayEvent == EventType.UnconfirmedEvent) {
                addEventHighlights(buttonTapped, highlightType: EventType.SingleDayUnavailable)
                updateModel(dateTapped, eventType: EventType.SingleDayUnavailable)
            }
            else if weekDay == 1 || dateTapped.day == 1 {
                if (nextDayEvent == nil || nextDayEvent == EventType.ConfirmedEvent || nextDayEvent == EventType.UnconfirmedEvent) {
                    addEventHighlights(buttonTapped, highlightType: EventType.SingleDayUnavailable)
                    updateModel(dateTapped, eventType: EventType.SingleDayUnavailable)
                }
                else if nextDayEvent == EventType.StartUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.StartUnavailable)
                    updateModel(dateTapped, eventType: EventType.StartUnavailable)
                    updateModel(nextDay, eventType: EventType.IntermediateUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent == EventType.SingleDayUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.StartUnavailable)
                    updateModel(dateTapped, eventType: EventType.StartUnavailable)
                    updateModel(nextDay, eventType: EventType.EndUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.EndUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            else if weekDay == 7 || dateTapped.day == lastDay {
                if (previousDayEvent == nil || previousDayEvent == EventType.ConfirmedEvent || previousDayEvent == EventType.UnconfirmedEvent) {
                    addEventHighlights(buttonTapped, highlightType: EventType.SingleDayUnavailable)
                    updateModel(dateTapped, eventType: EventType.SingleDayUnavailable)
                }
                else if previousDayEvent == EventType.EndUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.EndUnavailable)
                    updateModel(dateTapped, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.IntermediateUnavailable)
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if previousDayEvent == EventType.SingleDayUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.EndUnavailable)
                    updateModel(dateTapped, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.StartUnavailable)
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.StartUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            else
            {
                if nextDayEvent == EventType.StartUnavailable && previousDayEvent == EventType.EndUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.IntermediateUnavailable)
                    updateModel(dateTapped, eventType: EventType.IntermediateUnavailable)
                    updateModel(nextDay, eventType: EventType.IntermediateUnavailable)
                    updateModel(previousDay, eventType: EventType.IntermediateUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if (nextDayEvent == nil || nextDayEvent == EventType.ConfirmedEvent || nextDayEvent == EventType.UnconfirmedEvent) && previousDayEvent == EventType.EndUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.EndUnavailable)
                    updateModel(dateTapped, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.IntermediateUnavailable)
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent == EventType.StartUnavailable && (previousDayEvent == nil || previousDayEvent == EventType.ConfirmedEvent || previousDayEvent == EventType.UnconfirmedEvent) {
                    addEventHighlights(buttonTapped, highlightType: EventType.StartUnavailable)
                    updateModel(dateTapped, eventType: EventType.StartUnavailable)
                    updateModel(nextDay, eventType: EventType.IntermediateUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent == EventType.SingleDayUnavailable && previousDayEvent == EventType.SingleDayUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.IntermediateUnavailable)
                    updateModel(dateTapped, eventType: EventType.IntermediateUnavailable)
                    updateModel(nextDay, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.StartUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.EndUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.StartUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if (nextDayEvent == nil || nextDayEvent == EventType.ConfirmedEvent || nextDayEvent == EventType.UnconfirmedEvent) && previousDayEvent == EventType.SingleDayUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.EndUnavailable)
                    updateModel(dateTapped, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.StartUnavailable)
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.StartUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent ==  EventType.SingleDayUnavailable && (previousDayEvent == nil || previousDayEvent == EventType.ConfirmedEvent || previousDayEvent == EventType.UnconfirmedEvent) {
                    addEventHighlights(buttonTapped, highlightType: EventType.StartUnavailable)
                    updateModel(dateTapped, eventType: EventType.StartUnavailable)
                    updateModel(nextDay, eventType: EventType.EndUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.EndUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent == EventType.SingleDayUnavailable && previousDayEvent == EventType.EndUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.IntermediateUnavailable)
                    updateModel(dateTapped, eventType: EventType.IntermediateUnavailable)
                    updateModel(nextDay, eventType: EventType.EndUnavailable)
                    updateModel(previousDay, eventType: EventType.IntermediateUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.EndUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
                else if nextDayEvent == EventType.StartUnavailable && previousDayEvent == EventType.SingleDayUnavailable {
                    addEventHighlights(buttonTapped, highlightType: EventType.IntermediateUnavailable)
                    updateModel(dateTapped, eventType: EventType.IntermediateUnavailable)
                    updateModel(nextDay, eventType: EventType.IntermediateUnavailable)
                    updateModel(previousDay, eventType: EventType.StartUnavailable)
                    
                    if nextDay.month == dateTapped.month {
                        let nextDayButton = buttonsView.viewWithTag(nextDay.day)!
                        if let drawingLayers = nextDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(nextDayButton, highlightType: EventType.IntermediateUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                    
                    if previousDay.month == dateTapped.month {
                        let previousDayButton = buttonsView.viewWithTag(previousDay.day)!
                        if let drawingLayers = previousDayButton.layer.sublayers {
                            for layer in drawingLayers {
                                if layer is CAShapeLayer {
                                    layer.removeFromSuperlayer()
                                }
                            }
                        }
                        addEventHighlights(previousDayButton, highlightType: EventType.StartUnavailable)
                    }
                    else {
                        if let delegate = delegate {
                            delegate.didUpdateEvents()
                        }
                    }
                }
            }
            
        }
        
    }

    
    func updateModel(dateStructure: DateStructure, eventType: EventType) {
        
        if let month = eventsModel.formattedEvents[dateStructure.year] {
            if let _ = month[dateStructure.month] {
                eventsModel.formattedEvents[dateStructure.year]![dateStructure.month]![dateStructure.day] = eventType
            }
            else {
                eventsModel.formattedEvents[dateStructure.year]![dateStructure.month] = [dateStructure.day: eventType]
            }
        }
        else {
            eventsModel.formattedEvents[dateStructure.year] = [dateStructure.month: [dateStructure.day: eventType]]
        }
    }
    
}
