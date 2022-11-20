//
//  DateExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

public extension Date {
    
    /// 日期格式
    struct Formatter {
        
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// yyyy-MM-dd HH:ss:mm
        public static let dateAndTime = Formatter(rawValue: "yyyy-MM-dd HH:mm:ss")

        /// yyyy-MM-dd
        public static let date = Formatter(rawValue: "yyyy-MM-dd")
        
        /// HH:ss:mm
        public static let time = Formatter(rawValue: "HH:mm:ss")
    }
    
    /// 转成时间格式字符串(自定义格式)
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd
    /// - Returns: formater字符串
    func stringValue(_ formater: Date.Formatter = .date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater.rawValue
        return dateFormater.string(from: self)
    }
}

public extension Date {
    
    enum AppropriateDateStyle {
        case chinese
        case character(c: String)
    }
    
    /// 返回更直观的时间格式
    /// - Parameter dateStyle: 年月日格式，默认chinese（ yyyy年MM月dd日）。如果是character("-")，格式为：yyyy-MM-dd
    /// - Parameter timeValue: 时分秒格式，默认HH:mm
    /// - Returns: 时间字符串
    func appropriateValue(with dateStyle: Date.AppropriateDateStyle = .chinese, timeValue: String = "HH:mm") -> String {
        let value: String
        if isToday {
            value = "今天 \(timeValue)"
        }
        else if isYesterday {
            value = "昨天 \(timeValue)"
        }
        else if year == Date().year {
            let dateValue: String
            switch dateStyle {
            case .chinese:
                dateValue = "MM月dd日"
            case .character(let c):
                dateValue = "MM\(c)dd"
            }
            value = "\(dateValue) \(timeValue)"
        }
        else {
            let dateValue: String
            switch dateStyle {
            case .chinese:
                dateValue = "yyyy年MM月dd日"
            case .character(let c):
                dateValue = "yyyy\(c)MM\(c)dd"
            }
            value = "\(dateValue) \(timeValue)"
        }
        
        let format = Date.Formatter(rawValue: value)
        return stringValue(format)
    }
}

public let kkxCalendar = Calendar.current

/// 周日为第一天
public extension Date {

    /// 这个月第一天的日期
    var firstDayDate: Date? {
        let year = component(.year)
        let month = component(.month)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        return kkxCalendar.date(from: components)
    }
    
    /// 这个月最后一天的日期
    var lastDayDate: Date? {
        let year = component(.year)
        let month = component(.month)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = days
        return kkxCalendar.date(from: components)
    }
    
    /// 上个月第一天日期
    var previousMonth: Date? {
        var year = component(.year)
        var month = component(.month)
        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return kkxCalendar.date(from: components)
    }
    
    /// 下个月第一天日期
    var nextMonth: Date? {
        var year = component(.year)
        var month = component(.month)
        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return kkxCalendar.date(from: components)
    }
    
    func component(_ component: Calendar.Component) -> Int {
        kkxCalendar.component(component, from: self)
    }
    
    /// 当月有几天
    var days: Int? {
        if let endIndex = kkxCalendar.range(of: .day, in: .month, for: self)?.endIndex,
           endIndex > 0 {
            return endIndex - 1
        }
        return nil
    }
    
    /// 是否是同一天
    func isSameDay(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }
        let components: Set<Calendar.Component> = [.year, .month, .day]
        let dateComponents1 = kkxCalendar.dateComponents(components, from: self)
        let dateComponents2 = kkxCalendar.dateComponents(components, from: date)
        let result = (dateComponents1.year == dateComponents2.year) && (dateComponents1.month == dateComponents2.month) && (dateComponents1.day == dateComponents2.day)
        return result
    }
}

public extension Date {
    
    var year: Int {
        kkxCalendar.component(.year, from: self)
    }
    
    var month: Int {
        kkxCalendar.component(.month, from: self)
    }
    
    var day: Int {
        kkxCalendar.component(.day, from: self)
    }
    
    var hour: Int {
        kkxCalendar.component(.hour, from: self)
    }
    
    var minute: Int {
        kkxCalendar.component(.minute, from: self)
    }
    
    var second: Int {
        kkxCalendar.component(.second, from: self)
    }
    
    var nanosecond: Int {
        kkxCalendar.component(.nanosecond, from: self)
    }
    
    /// 星期几（星期日=1）
    var weekday: Int {
        kkxCalendar.component(.weekday, from: self)
    }
    
    /// 表示这个月的第几个星期几(weekday)，不一定和weekOfMonth相同。
    /// 如weekdayOrdinal=2，weekday=3，表示这个月的第二个星期二
    var weekdayOrdinal: Int {
        kkxCalendar.component(.weekdayOrdinal, from: self)
    }
    
    /// 这个月第几周
    var weekOfMonth: Int {
        kkxCalendar.component(.weekOfMonth, from: self)
    }
    
    /// 这一年月第几周
    var weekOfYear: Int {
        kkxCalendar.component(.weekOfYear, from: self)
    }
    
    /// 周编号年份
    var yearForWeekOfYear: Int {
        kkxCalendar.component(.yearForWeekOfYear, from: self)
    }
    
    var era: Int {
        kkxCalendar.component(.era, from: self)
    }
}

public extension Date {
    
    func offset(_ component: Calendar.Component, _ count: Int) -> Date {
        
        var newComponent = DateComponents(second: 0)
        switch component {
        case .era:               newComponent = DateComponents(era: count)
        case .year:              newComponent = DateComponents(year: count)
        case .month:             newComponent = DateComponents(month: count)
        case .day:               newComponent = DateComponents(day: count)
        case .hour:              newComponent = DateComponents(hour: count)
        case .minute:            newComponent = DateComponents(minute: count)
        case .second:            newComponent = DateComponents(second: count)
        case .nanosecond:        newComponent = DateComponents(nanosecond: count)
        case .weekday:           newComponent = DateComponents(weekday: count)
        case .weekdayOrdinal:    newComponent = DateComponents(weekdayOrdinal: count)
        case .quarter:           newComponent = DateComponents(quarter: count)
        case .weekOfMonth:       newComponent = DateComponents(weekOfMonth: count)
        case .weekOfYear:        newComponent = DateComponents(weekOfYear: count)
        case .yearForWeekOfYear: newComponent = DateComponents(yearForWeekOfYear: count)
        default: break
        }
        return kkxCalendar.date(byAdding: newComponent, to: self) ?? self
    }
}

public extension Date {
    
    var isToday: Bool {
        kkxCalendar.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        kkxCalendar.isDateInTomorrow(self)
    }
    
    var isYesterday: Bool {
        kkxCalendar.isDateInYesterday(self)
    }
    
    func distance(to date: Date, for component: Calendar.Component) -> Int {
        kkxCalendar.dateComponents([component], from: self, to: date).value(for: component) ?? 0
    }
}
