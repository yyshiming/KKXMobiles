//
//  KKXPreferences.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import UIKit

public class KKXPreferencesKey {}

public final class KKXPreferences: NSObject {
    /// Represents a `Key` with an associated generic value type conforming to the
    /// `Codable` protocol.
    ///
    /// static let someKey = Key<ValueType>("someKey")
    public final class Key<ValueType: Codable>: KKXPreferencesKey {
        fileprivate let key: String
        
        public init(_ key: String) {
            self.key = key
        }
    }
    
    // MARK: Properties
    
    private var userDefaults: UserDefaults
    
    // MARK: Initialization
    
    /// An instance of `KKXPreferences` with the specified `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The UserDefaults.
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: Public Methods
    
    /// Delete the value associated with the specified key, if any.
    ///
    /// - Parameter key: The key.
    public func clear<ValueType>(_ key: Key<ValueType>) {
        self.userDefaults.set(nil, forKey: key.key)
        self.userDefaults.synchronize()
        
        NotificationCenter.default.post(
            name: KKXPreferences.didChanged,
            object: nil,
            userInfo: [Notification.KKXPreferences.Key: key.key]
        )
    }
    
    /// Checks if there is a value associated with the specified key.
    ///
    /// - Parameter key: The key to look for.
    /// - Returns: A boolean value indicating if a value exists for the specified key.
    public func has<ValueType>(_ key: Key<ValueType>) -> Bool {
        return userDefaults.value(forKey: key.key) != nil
    }
    
    /// Returns the value associated with the specified key.
    ///
    /// - Parameter key: The key.
    /// - Returns: A `ValueType` or nil if the key was not found.
    public func get<ValueType>(for key: Key<ValueType>) -> ValueType? {
        if isSwiftCodableType(type: ValueType.self) {
            return self.userDefaults.value(forKey: key.key) as? ValueType
        }
        
        guard let data = self.userDefaults.data(forKey: key.key) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ValueType.self, from: data)
            return decoded
        } catch {
            kkxPrint(error)
        }
        
        return nil
    }
    
    /// Sets a value associated with the specified key.
    ///
    /// - Parameters:
    ///   - some: The value to set.
    ///   - key: The associated `Key<ValueType>`.
    public func set<ValueType>(_ value: ValueType?, for key: Key<ValueType>) {
        guard let newValue = value else {
            clear(key)
            return
        }
        
        if isSwiftCodableType(type: ValueType.self) {
            self.userDefaults.set(newValue, forKey: key.key)
            self.userDefaults.synchronize()
            
            NotificationCenter.default.post(
                name: KKXPreferences.didChanged,
                object: nil,
                userInfo: [Notification.KKXPreferences.Key: key.key]
            )
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(newValue)
            self.userDefaults.set(encoded, forKey: key.key)
            self.userDefaults.synchronize()
            
            NotificationCenter.default.post(
                name: KKXPreferences.didChanged,
                object: nil,
                userInfo: [Notification.KKXPreferences.Key: key.key]
            )
        } catch {
            kkxPrint(error)
        }
    }
    
    // MARK: Private Methods
    
    /// Checks if a given type is primitive.
    ///
    /// - Parameter type: The type.
    /// - Returns: A boolean value indicating if the type is primitive.
    private func isSwiftCodableType<ValueType>(type: ValueType.Type) -> Bool {
        switch type {
        case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type, is Date.Type:
            return true
        default:
            return false
        }
    }
    
}

// MARK: -

extension KKXPreferences {
    
    public static let didChanged = Notification.Name(rawValue: "com.kkxmobile.notification.name.KKXPreferences.didChanged")
    
}

// MARK: -

extension Notification {
    
    public struct KKXPreferences {
        public static let Key = "com.kkxmobile.notification.KKXPreferences.key"
    }
    
}
