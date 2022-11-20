//
//  StringExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import CommonCrypto

extension String {

    /// 生成SHA256，如需大写将 %02x 改成 %02X
    public var SHA256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        
        return digest.reduce("") {  $0 + String(format: "%02x", $1) }
    }
    
    /// 手机号中间四位隐藏 由 “*****” 代替
    public var phoneNumberValue: String? {
        if count <= 11 {
            var index = self.index(startIndex, offsetBy: 3)
            let left = self[startIndex..<index]
            
            index = self.index(endIndex, offsetBy: -4)
            let right = self[index..<endIndex]
            
            return left + "****" + right
        }
        return nil
    }
    
    /// 身份证号中间隐藏 由 “******” 代替,前后留四位
    public var idCardValue: String? {
        if count > 8 {
            var index = self.index(startIndex, offsetBy: 4)
            let left = self[startIndex..<index]
            
            index = self.index(endIndex, offsetBy: -4)
            let right = self[index..<endIndex]
            
            return left + "******" + right
        }
        return nil
    }
    
    /// 手机尾号(四位)
    public var tail: String {
        if count > 4 {
            let index = self.index(endIndex, offsetBy: -4)
            let mobileTail = self[index..<endIndex]
            return String(mobileTail)
        }
        return ""
    }
    
    /// 是否是数字
    public func isDigit() -> Bool {
        let scanner = Scanner(string: self)
        var value: Int = 0
        let isdigit = scanner.scanInt(&value) && scanner.isAtEnd
        return isdigit
    }
    
    private func isValidateByRegex(_ regex: String) -> Bool {
        if self.count == 0 { return false }
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// 是否正确的手机号
    public func isMobile() -> Bool {
        self.count == 11
    }
    
    /// 是否正确的邮箱
    public func isEmail() -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return isValidateByRegex(emailRegex)
    }
    
    /// 是否正确的密码格式(字母和数字且长度在[8,16])
    public func isPassword() -> Bool {
        let pwdRegex = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$" // //是否都是字母和数字且长度在[8,16]
        return isValidateByRegex(pwdRegex)
    }
    
    /// 简单身份证过滤
    public func isIdNumber() -> Bool {
        let idCardRegex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        return isValidateByRegex(idCardRegex)
    }
    
    /// 身份证出生年月日 yyyyMMdd
    public func birth() -> String?  {
        let value = self.trimmingCharacters(in: CharacterSet.whitespaces)
        if value.count < 6 { return nil }
        var birth: String?
        let start6Index = value.index(value.startIndex, offsetBy: 6)
        if value.count == 15 {
            let index = value.index(start6Index, offsetBy: 6)
            birth = "19" + String(value[start6Index..<index])
        } else if value.count == 18 {
            let index = value.index(start6Index, offsetBy: 8)
            birth = String(value[start6Index..<index])
        }
        
        return birth
    }
    
    /// 精准身份证过滤
    public func isRealIDNumber() -> Bool {
        let value = self.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if value.count != 15 && value.count != 18 {
            // 不满足15位或18位
            return false
        }
        
        // 省份代码
        let areasArray = ["11","12", "13","14", "15","21", "22","23", "31","32", "33","34", "35","36", "37","41", "42","43", "44","45", "46","50", "51","52", "53","54", "61","62", "63","64", "65","71", "81","82", "91"]
        
        // 检查身份证省份代码
        let start2Index = value.index(value.startIndex, offsetBy: 2)
        let valueStart2 = value[..<start2Index]
        let areaFlag = areasArray.contains(String(valueStart2))
        if !areaFlag {
            return false
        }
        
        var regularExp: NSRegularExpression
        let numberOfMatch: Int
        
        var year = 0
        switch value.count {
        case 15:
            let start6Index = value.index(value.startIndex, offsetBy: 6)
            let index = value.index(start6Index, offsetBy: 2)
            guard let y = Int(value[start6Index..<index]) else {
                return false
            }
            year =  y + 1900
            if year%4 == 0 || (year%100 == 0 && year%4 == 0) {
                guard let regular = try? NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive) else {
                    return false
                }
                regularExp = regular
            }
            else {
                guard let regular = try? NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive) else {
                    return false
                }
                regularExp = regular
            }
            
            numberOfMatch = regularExp.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, value.count))
            return (numberOfMatch > 0)
        case 18:
            let start6Index = value.index(value.startIndex, offsetBy: 6)
            let index = value.index(start6Index, offsetBy: 4)
            year = Int(value[start6Index..<index]) ?? 0
            if year%4 == 0 || (year%100 == 0 && year%4 == 0) {
                guard let regular = try? NSRegularExpression(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive) else {
                    return false
                }
                regularExp = regular
            }
            else {
                guard let regular = try? NSRegularExpression(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive) else {
                    return false
                }
                regularExp = regular
            }
            
            numberOfMatch = regularExp.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, value.count))
            if numberOfMatch > 0 {
                var sum = 0
                let wiArray = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
                var start = value.startIndex
                var end = value.index(value.startIndex, offsetBy: 1)
                for i in 0..<wiArray.count {
                    let subString = Int(value[start..<end]) ?? 0
                    sum = sum + subString * wiArray[i]
                    start = end
                    end = value.index(end, offsetBy: 1)
                }
                let y = sum%11
                let JYM = "10X98765432"
                start = JYM.index(JYM.startIndex, offsetBy: y)
                end = JYM.index(start, offsetBy: 1)
                let m = JYM[start..<end]
                
                start = value.index(value.startIndex, offsetBy: 17)
                end = value.index(start, offsetBy: 1)
                let lastValue = value[start..<end].uppercased()
                return (m == lastValue)
            }
            else {
                return false
            }
        default:
            return false
        }
    }
}

extension String {
    
    /// 字符串(自定义格式) 转成TimeInterval
    /// - Parameter formater: 格式， 默认 yyyy-MM-dd
    /// - Returns: TimeInterval 时间戳，毫秒
    public func timeInterval(_ formater: Date.Formatter = .date) -> TimeInterval? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater.rawValue
        if let date = dateFormater.date(from: self) {
            return date.timeIntervalSince1970 * 1000
        }
        return nil
    }
    
    /// 字符串(自定义格式) 转成Date
    /// - Parameter formater: 格式， 默认 yyyy-MM-dd
    /// - Returns: formater格式的Date
    public func dateValue(_ formater: Date.Formatter = .date) -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater.rawValue
        return dateFormater.date(from: self)
    }
}
