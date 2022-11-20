//
//  TimeIntervalExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension Int {
    public static let aSecond: Int = 1
    public static let aMinute: Int = 60
    public static let aHour: Int   = 3600
    public static let aDay: Int    = 86400
    public static let aWeek: Int   = 604800
}

extension Double {
    
    /// 时间戳（毫秒）转成时间格式字符串(自定义格式)
    ///
    ///     let millisecond = 3_600_000
    ///     let string1 = millisecond.convertToString()
    ///     // string1 = "01:00:00"
    ///
    ///     let string2 = millisecond.convertToString("HH时mm分")
    ///     // string2 = "01时00分
    ///
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd HH:mm:ss
    /// - Parameter timeZone: 时区，默认为nil，即系统时区
    /// - Returns: formater格式字符串
    public func convertToString(_ formater: Date.Formatter = .dateAndTime, timeZone: TimeZone? = nil) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater.rawValue
        if timeZone != nil {
            dateFormater.timeZone = timeZone
        }
        let date = Date(timeIntervalSince1970: self/1000.0)
        return dateFormater.string(from: date)
    }
}

extension Double {
    
    /// 返回更直观的时间格式
    /// - Parameter dateStyle: 年月日格式，默认chinese（ yyyy年MM月dd日）。如果是character("-")，格式为：yyyy-MM-dd
    /// - Parameter timeValue: 时分秒格式，默认HH:mm
    /// - Returns: 时间字符串
    func appropriateValue(with dateStyle: Date.AppropriateDateStyle = .chinese, timeValue: String = "HH:mm") -> String {
        let date = Date(timeIntervalSince1970: self / 1000)
        return date.appropriateValue(with: dateStyle, timeValue: timeValue)
    }
}
