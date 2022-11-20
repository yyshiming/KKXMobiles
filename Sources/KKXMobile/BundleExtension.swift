//
//  BundleExtension.swift
//  KKXMobiile
//
//  Created by ming on 2021/5/11.
//

import UIKit

extension Bundle {
    
    public var kkxBundleId: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    }
    
    public var kkxName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }
    
    public var kkxDisplayName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
    
    public var kkxVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    public var kkxBuild: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

extension Bundle {
    
    public static var kkxMobile: Bundle = {
        let bundle: Bundle
        #if SWIFT_PACKAGE
        bundle = Bundle.module
        #else
        bundle = Bundle(for: _KKXMobile_.self)
        #endif
        return bundle
    }()
    
    public class func kkx_localizedString(forKey key: String) -> String {
        self.kkx_localizedString(forKey: key, value: nil)
    }
    
    public class func kkx_localizedString(forKey key: String, value: String?) -> String {
        
        let bundle = Bundle.kkxMobile
        return bundle.localizedString(forKey: key, value: value, table: nil)
    }
}
