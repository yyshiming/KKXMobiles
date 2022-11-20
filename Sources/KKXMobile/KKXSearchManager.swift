//
//  KKXSearchManager.swift
//  KKXMobile
//
//  Created by ming on 2020/8/17.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

public class KKXSearchManager: NSObject {
    
    public struct Key {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let city = KKXSearchManager.Key(rawValue: "kkx_city_history_key")
    }
    
    public static let manager = KKXSearchManager()
    
    public func allHistory(for key: KKXSearchManager.Key) -> [String] {
        let citys = UserDefaults.standard.object(forKey: key.rawValue) as? [String]
        return citys ?? []
    }
    
    public func insert(_ string: String, for key: KKXSearchManager.Key) {
        var citys = UserDefaults.standard.object(forKey: key.rawValue) as? [String] ?? []
        if let index = citys.firstIndex(of: string) {
            citys.remove(at: index)
        }
        citys.append(string)
        UserDefaults.standard.setValue(citys, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public func deleteAll(for key: KKXSearchManager.Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
