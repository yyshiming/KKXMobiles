//
//  KKXAlertManager.swift
//  KKXMobile
//
//  Created by ming on 2021/5/25.
//

import UIKit

public final class KKXAlertManager {
    
    public static let shared = KKXAlertManager()
    
    public func addAlert(_ task: @escaping () -> Void) {
        alertQueue.async {
            self.alertSemaphore.wait()
            DispatchQueue.main.async {
                task()
            }
        }
    }
    
    public func signal() {
        alertSemaphore.signal()
    }
    
    private let alertQueue = DispatchQueue(label: "com.ibilliards.alert")
    private let alertSemaphore = DispatchSemaphore(value: 1)
}
