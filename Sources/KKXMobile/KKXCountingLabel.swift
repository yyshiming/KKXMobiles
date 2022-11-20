//
//  KKXCountingLabel.swift
//  Demo
//
//  Created by ming on 2021/6/3.
//

import UIKit

private let counterRate: Float = 3.0
private let defaultDuration: TimeInterval = 1

public class KKXCountingLabel: UILabel {

    public enum Style {
        case linear
        case easeIn
        case easeOut
        case easeInOut
        case easeInBounce
        case easeOutBounce
    }
    
    // MARK: -------- Properties --------
    
    public var style: KKXCountingLabel.Style = .linear
    public var duration: TimeInterval = defaultDuration
    public var currentValue: Float {
        if progress >= totalTime {
            return destinationValue
        }
        
        let percent = Float(progress/totalTime)
        let update = counter.update(percent)
        return startingValue + update*(destinationValue - startingValue)
        
    }

    public var format: String? {
        didSet {
            textValue = currentValue
        }
    }
    public var formatClosure: ((Float) -> String?)?
    public var attributedFormatClosure: ((Float) -> NSAttributedString?)?
    public var completeClosure: (() -> Void)?
    
    // MARK: -------- Private Properties --------

    private var startingValue: Float = 0
    private var destinationValue: Float = 0
    private var progress: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var totalTime: TimeInterval = 0
    private var easingRate: Float = 3
    
    private var timer: CADisplayLink?
    private var counter: KKXLabelCounter = KKXLabelCounterLinear()
    
    private var textValue: Float = 0 {
        didSet {
            if attributedFormatClosure != nil {
                attributedText = attributedFormatClosure?(textValue)
            }
            else if formatClosure != nil {
                text = formatClosure?(textValue)
            }
            else {
                
                // check if counting with ints - cast to int
                // regex based on IEEE printf specification: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
                if let _ = format?.range(of: "%[^fega]*[diouxc]", options: [.regularExpression, .caseInsensitive]) {
                    text = String(format: format!, Int(textValue))
                }
                else {
                    text = String(format: format!, textValue)
                }
            }
        }
    }
    
    // MARK: -------- Public Func --------

    public func countingFromCurrent(to toValue: Float) {
        counting(from: currentValue, to: toValue)
    }
    
    public func counting(from fromValue: Float = 0,
                         to toValue: Float) {
        if duration == 0 {
            duration = defaultDuration
        }
        counting(from: fromValue, to: toValue, duration: duration)
    }
    
    /// 开始数字变化动画
    ///
    /// - Parameters:
    ///   - fromValue: 开始值，默认为0
    ///   - toValue: 结束值
    ///   - duration: 持续时间
    public func counting(from fromValue: Float = 0,
                         to toValue: Float,
                         duration: TimeInterval) {
        self.startingValue = fromValue
        self.destinationValue = toValue
        
        self.timer?.invalidate()
        self.timer = nil
        
        if format == nil {
            format = "%.0f"
        }
        
        guard duration > 0 else {
            textValue = toValue
            runCompleted()
            return
        }
        
        totalTime = duration
        lastUpdate = Date.timeIntervalSinceReferenceDate
        
        switch style {
        case .linear:
            counter = KKXLabelCounterLinear()
        case .easeIn:
            counter = KKXLabelCounterEaseIn()
        case .easeOut:
            counter = KKXLabelCounterEaseOut()
        case .easeInOut:
            counter = KKXLabelCounterEaseInOut()
        case .easeInBounce:
            counter = KKXLabelCounterEaseInBounce()
        case .easeOutBounce:
            counter = KKXLabelCounterEaseOutBounce()
        }
        
        timer = CADisplayLink(target: self, selector: #selector(updateLabelValue(_:)))
        timer?.preferredFramesPerSecond = 2
        timer?.add(to: RunLoop.main, forMode: .common)
    }
    
    // MARK: -------- Init --------
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    // MARK: -------- Configure --------
    
    private func configureSubviews() {
        
    }
    
    // MARK: -------- Actions --------
    
    @objc private func updateLabelValue(_ timer: Timer) {
        
        // update progress
        let now = Date.timeIntervalSinceReferenceDate
        progress += now - lastUpdate
        lastUpdate = now
        
        if progress >= totalTime {
            self.timer?.invalidate()
            self.timer = nil
            progress = totalTime
        }
        
        textValue = currentValue
        if progress == totalTime {
            runCompleted()
        }
    }
    
    private func runCompleted() {
        completeClosure?()
    }
}

fileprivate protocol KKXLabelCounter {
    
    func update(_ t: Float) -> Float
}

fileprivate class KKXLabelCounterLinear: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        return t
    }
}

fileprivate class KKXLabelCounterEaseIn: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        return powf(t, counterRate)
    }
}

fileprivate class KKXLabelCounterEaseOut: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        return 1.0 - powf((1.0 - t), counterRate)
    }
}

fileprivate class KKXLabelCounterEaseInOut: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        let newT = t*2
        if (newT < 1) {
            return 0.5 * powf (newT, counterRate)
        }
        else {
            return 0.5 * (2.0 - powf(2.0 - newT, counterRate))
        }
    }
}

fileprivate class KKXLabelCounterEaseInBounce: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        if t < 4.0/11.0 {
            return 1.0 - (powf(11.0/4.0, 2) * powf(t, 2)) - t
        }
        
        if t < 8.0/11.0 {
            return 1.0 - (3.0/4.0 + powf(11.0/4.0, 2) * powf(t - 6.0/11.0, 2)) - t
        }
        
        if t < 10.0/11.0 {
            return 1.0 - (15.0/16.0 + powf(11.0/4.0, 2) * powf(t - 9.0/11.0, 2)) - t
        }
        
        return 1.0 - (63.0/64.0 + powf(11.0/4.0, 2) * powf(t - 21.0/22.0, 2)) - t
    }
}

fileprivate class KKXLabelCounterEaseOutBounce: KKXLabelCounter {
    
    func update(_ t: Float) -> Float {
        if t < 4.0/11.0 {
            return powf(11.0/4.0, 2) * powf(t, 2)
        }
        
        if t < 8.0/11.0 {
            return 3.0/4.0 + powf(11.0/4.0, 2) * powf(t - 6.0/11.0, 2)
        }
        
        if t < 10.0/11.0 {
            return 15.0/16.0 + powf(11.0/4.0, 2) * powf(t - 9.0/11.0, 2)
        }
        
        return 63.0/64.0 + powf(11.0/4.0, 2) * powf(t - 21.0/22.0, 2)
    }
}
