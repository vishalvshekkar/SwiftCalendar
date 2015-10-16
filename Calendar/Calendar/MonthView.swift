////
////  MonthView.swift
////  Calendar
////
////  Created by Vishal on 10/16/15.
////  Copyright © 2015 Y Media Labs. All rights reserved.
////
//
//import UIKit
//
//class MonthView: UICollectionViewCell {
//    
//    var defaultCalendarProperties = DefaultCalendarProperties()
//    
//    let dateHelper = DateHelper()
//    
//    
//    
//    
//    
//    func createDateButtons(date1: dateStructure) -> UIView {
//        let baseView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
//        baseView.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
//        baseView.tag = Int(String(date1.month) + String(date1.year))!
//        print("tag is")
//        print(baseView.tag)
//        createLabel(baseView)
//        let buttonsViewFrame = CGRectMake(0, self.frame.size.height*(1.0/7.0), self.frame.size.width, self.frame.size.height*(6.0/7.0))
//        let buttonsView = UIView()
//        buttonsView.frame = buttonsViewFrame
//        buttonsView.backgroundColor = defaultCalendarProperties.calendarBackgroundColor
//        baseView.addSubview(buttonsView)
//        let buttonHeight = buttonsView.frame.size.height/6
//        let buttonWidth = buttonsView.frame.size.width/7
//        
//        
//        var startDay = dateHelper.getDayOfWeek(String(date1.year)+"-"+String(date1.month)+"-01")! - 1
//        print(startDay)
//        var dateButtons = [UIButton]()
//        var lines = [UIView]()
//        var days = 0
//        var count = 0
//        
//        let maxDays = dateHelper.getMaxDays(date1.year, month: date1.month)
//        
//        for i in 0...5 {
//            for j in 0...6 {
//                if startDay <= 0 && days < maxDays {
//                    dateButtons.append(UIButton(frame: CGRect(x: CGFloat(j) * buttonWidth, y: CGFloat(i) * buttonHeight, width: buttonWidth, height: buttonHeight)))
//                    
//                    dateButtons[days].setTitle(String(days+1), forState: UIControlState.Normal)
//                    dateButtons[days].titleLabel?.font = defaultCalendarProperties.dateFont
//                    dateButtons[days].setTitleColor(defaultCalendarProperties.dateColor, forState: UIControlState.Normal)
//                    dateButtons[days].setTitleColor(defaultCalendarProperties.dateHighlightedColor, forState: UIControlState.Highlighted)
//                    
//                    let now = dateStructure(day: days+1, month: date1.month, year: date1.year)
//                    if now.year == dateHelper.getDate().year && now.month == dateHelper.getDate().month && now.day == dateHelper.getDate().day {
//                        let todayHighlightShapeLayer = CAShapeLayer()
//                        todayHighlightShapeLayer.frame = CGRect(x: dateButtons[days].frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, y: dateButtons[days].frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, width: dateButtons[days].frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2, height: dateButtons[days].frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2)
//                        todayHighlightShapeLayer.zPosition = -1
//                        dateButtons[days].layer.addSublayer(todayHighlightShapeLayer)
//                        todayHighlightShapeLayer.fillColor = defaultCalendarProperties.todayColor.CGColor
//                        todayHighlightShapeLayer.path = UIBezierPath(roundedRect: todayHighlightShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: todayHighlightShapeLayer.frame.size.height/2, height: todayHighlightShapeLayer.frame.size.height/2)).CGPath
//                    }
//                    
//                    for eventType in events.events {
//                        let highlightImage = eventType.highlightImage
//                        let events = eventType.eventsList
//                        for event in events {
//                            let formatter = NSDateFormatter()
//                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//                            let localDateTime = formatter.stringFromDate(event)
//                            let eventStructure = dateStructure(day: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(8), end: localDateTime.startIndex.advancedBy(10))))!, month: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(5), end: localDateTime.startIndex.advancedBy(7))))!, year: Int(localDateTime.substringWithRange(Range<String.Index>(start: localDateTime.startIndex.advancedBy(0), end: localDateTime.startIndex.advancedBy(4))))!)
//                            if date1.year == eventStructure.year && date1.month == eventStructure.month && days+1 == eventStructure.day {
//                                //                                dateButtons[days].setBackgroundImage(highlightImage, forState: UIControlState.Normal)
//                                let circleShapeLayer = CAShapeLayer()
//                                circleShapeLayer.frame = CGRect(x: dateButtons[days].frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, y: dateButtons[days].frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2) + defaultCalendarProperties.eventCircleWidth/2, width: dateButtons[days].frame.size.width*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2, height: dateButtons[days].frame.size.height*defaultCalendarProperties.eventFitScale - defaultCalendarProperties.eventCircleWidth/2)
//                                circleShapeLayer.zPosition = -1
//                                dateButtons[days].layer.addSublayer(circleShapeLayer)
//                                circleShapeLayer.fillColor = UIColor.clearColor().CGColor
//                                circleShapeLayer.strokeColor = defaultCalendarProperties.eventColor.CGColor
//                                circleShapeLayer.lineWidth = defaultCalendarProperties.eventCircleWidth
//                                circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
//                            }
//                        }
//                    }
//                    
//                    for contEvent in events.continuousEventsFormatted {
//                        
//                        if contEvent.isSingleDayEvent {
//                            if dateStructure.areEqual(now, date2: contEvent.startDate) {
//                                let circleShapeLayer = CAShapeLayer()
//                                circleShapeLayer.frame = CGRect(x: dateButtons[days].frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: dateButtons[days].frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: dateButtons[days].frame.size.width*defaultCalendarProperties.eventFitScale, height: dateButtons[days].frame.size.height*defaultCalendarProperties.eventFitScale)
//                                circleShapeLayer.zPosition = -2
//                                dateButtons[days].layer.addSublayer(circleShapeLayer)
//                                circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//                                circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
//                            }
//                        }
//                        else {
//                            if dateStructure.areEqual(now, date2: contEvent.startDate) {
//                                print("Start Date")
//                                addContinuousEventHighlight(dateButtons[days], highlightType: ContinuousEventHighlightType.StartDate)
//                            }
//                            else if dateStructure.isDateInBetween(now, lowerDate: contEvent.startDate, higherDate: contEvent.endDate) {
//                                print("Middle Date")
//                                addContinuousEventHighlight(dateButtons[days], highlightType: ContinuousEventHighlightType.IntermediateDate)
//                            }
//                            else if dateStructure.areEqual(now, date2: contEvent.endDate) {
//                                print("End Date")
//                                addContinuousEventHighlight(dateButtons[days], highlightType: ContinuousEventHighlightType.EndDate)
//                            }
//                        }
//                        
//                    }
//                    
//                    dateButtons[days].tag = days + 1
//                    dateButtons[days].addTarget(self, action: "didSelectDate:", forControlEvents: UIControlEvents.TouchUpInside)
//                    buttonsView.addSubview(dateButtons[days])
//                    days++
//                    
//                }
//                else {
//                    startDay--
//                }
//                count++
//            }
//            if defaultCalendarProperties.needSeparator{
//                lines.append(UIView(frame: CGRect(x: CGFloat(0), y: buttonHeight * CGFloat(i), width: buttonsView.frame.size.width, height: CGFloat(1))))
//                lines[i].backgroundColor = defaultCalendarProperties.separatorColor
//                buttonsView.addSubview(lines[i])
//            }
//        }
//        
//        return baseView
//    }
//    
//    func addContinuousEventHighlight(viewToAddOn: UIView, highlightType: ContinuousEventHighlightType) {
//        if highlightType == ContinuousEventHighlightType.StartDate {
//            let circleShapeLayer = CAShapeLayer()
//            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
//            circleShapeLayer.zPosition = -2
//            viewToAddOn.layer.addSublayer(circleShapeLayer)
//            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
//            
//            let rectangleShapeLayer = CAShapeLayer()
//            rectangleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width/2, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width/2+2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
//            rectangleShapeLayer.zPosition = -2
//            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
//            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
//            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//        }
//        else if highlightType == ContinuousEventHighlightType.IntermediateDate {
//            let rectangleShapeLayer = CAShapeLayer()
//            rectangleShapeLayer.frame = CGRect(x: 0, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width+1, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
//            rectangleShapeLayer.zPosition = -2
//            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
//            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
//            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//        }
//        else {
//            let circleShapeLayer = CAShapeLayer()
//            circleShapeLayer.frame = CGRect(x: viewToAddOn.frame.size.width*((1 - defaultCalendarProperties.eventFitScale)/2), y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width*defaultCalendarProperties.eventFitScale, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
//            circleShapeLayer.zPosition = -2
//            viewToAddOn.layer.addSublayer(circleShapeLayer)
//            circleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//            circleShapeLayer.path = UIBezierPath(roundedRect: circleShapeLayer.bounds, byRoundingCorners: UIRectCorner.AllCorners, cornerRadii: CGSize(width: circleShapeLayer.frame.size.height/2, height: circleShapeLayer.frame.size.height/2)).CGPath
//            
//            let rectangleShapeLayer = CAShapeLayer()
//            rectangleShapeLayer.frame = CGRect(x: 0, y: viewToAddOn.frame.size.height*((1 - defaultCalendarProperties.eventFitScale)/2), width: viewToAddOn.frame.size.width/2+2, height: viewToAddOn.frame.size.height*defaultCalendarProperties.eventFitScale)
//            rectangleShapeLayer.zPosition = -2
//            rectangleShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: rectangleShapeLayer.frame.size.width, height: rectangleShapeLayer.frame.size.height)).CGPath
//            viewToAddOn.layer.addSublayer(rectangleShapeLayer)
//            rectangleShapeLayer.fillColor = defaultCalendarProperties.continuousEventColor.CGColor
//        }
//    }
//    
//    func createLabel(viewToAddOn: UIView) {
//        let labelHeight = self.frame.size.height/6.0
//        let labelWidth = self.frame.size.width/7.0
//        var dayOfWeek = [UILabel]()
//        var weekDays = [String]()
//        if defaultCalendarProperties.dayFormat == .SingleLetter {
//            weekDays = defaultCalendarProperties.singleLetterDays
//        }
//        else {
//            weekDays = defaultCalendarProperties.threeLetterDays
//        }
//        for i in 0...6 {
//            dayOfWeek.append(UILabel(frame: CGRect(x: CGFloat(i) * labelWidth, y: CGFloat(0) , width: labelWidth, height: labelHeight)))
//            dayOfWeek[i].text = weekDays[i]
//            dayOfWeek[i].textAlignment = .Center
//            dayOfWeek[i].font = defaultCalendarProperties.dayOfWeekFont
//            dayOfWeek[i].textColor = defaultCalendarProperties.daysOfWeekColor
//            viewToAddOn.addSubview(dayOfWeek[i])
//        }
//    }
//    
//}
