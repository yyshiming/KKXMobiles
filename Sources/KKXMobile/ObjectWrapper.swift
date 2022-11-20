//
//  ObjectWrapper.swift
//  KKXMobile
//
//  Created by ming on 2021/5/11.
//

import Foundation

public class ObjectWrapper<Wrapper> {
    public let object: Wrapper
    public init(_ object: Wrapper) {
        self.object = object
    }
}

public protocol ObjectCompatible {
    associatedtype CompatibleType
    var kkx: CompatibleType { get }
}

extension ObjectCompatible {
    
    public var kkx: ObjectWrapper<Self> {
        guard let wrapper = objc_getAssociatedObject(self, &objectWrapperKey) as? ObjectWrapper<Self> else {
            let wrapper = ObjectWrapper(self)
            objc_setAssociatedObject(self, &objectWrapperKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return wrapper
        }
        return wrapper
    }
}
private var objectWrapperKey: UInt8 = 0
