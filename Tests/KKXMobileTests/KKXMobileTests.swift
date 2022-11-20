import XCTest
@testable import KKXMobile

final class KKXMobileTests: XCTestCase {
    
    func testFormatPrice() throws {
        
        XCTAssertEqual(kkxFormat(forPrice: 12300), "123")
        XCTAssertEqual(kkxFormat(forPrice: 12340), "123.4")
        XCTAssertEqual(kkxFormat(forPrice: 12345), "123.45")
        
        XCTAssertEqual(kkxFormat(forPrice: 12345, style: .digits(d: 0)), "123")
        XCTAssertEqual(kkxFormat(forPrice: 12345, style: .digits(d: 1)), "123.4")
        XCTAssertEqual(kkxFormat(forPrice: 12345, style: .digits(d: 2)), "123.45")
    }
    
    func testFormatTime() throws {
        
        let today = Date()
        let yesterday = kkxCalendar.date(byAdding: .day, value: -1, to: today)!
        let date = kkxCalendar.date(from: DateComponents(year: 2021, month: 12, day: 12, hour: 12, minute: 12, second: 12))!
        
        XCTAssertEqual(today.appropriateValue(), "今天 \(today.stringValue(.init(rawValue: "HH:mm")))")
        XCTAssertEqual(yesterday.appropriateValue(), "昨天 \(today.stringValue(.init(rawValue: "HH:mm")))")
        XCTAssertEqual(date.appropriateValue(), today.stringValue(.init(rawValue: "yyyy年MM月dd日 HH:mm")))
    }
}
