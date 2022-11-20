//
//  UIScrollViewExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

extension UIScrollView {
    
    /// 分页加载页数, 默认 1
    public var pageNumber: Int {
        get {
            let page = objc_getAssociatedObject(self, &pageNumberKey) as? Int
            return page ?? 1
        }
        set {
            objc_setAssociatedObject(self, &pageNumberKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 分页加载每页条数，默认 10
    public var pageSize: Int {
        get {
            let page = objc_getAssociatedObject(self, &pageSizeKey) as? Int
            return page ?? defaultPageSize
        }
        set {
            objc_setAssociatedObject(self, &pageSizeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var defaultPageSize: Int {
        return 10
    }
    
    /// 默认 true
    public var shouldShowLoading: Bool {
        get {
            let isHide = objc_getAssociatedObject(self, &shouldShowLoadingKey) as? Bool
            return isHide ?? true
        }
        set {
            objc_setAssociatedObject(self, &shouldShowLoadingKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 列表是否有更多数据，默认false
    public var hasMoreData: Bool {
        get {
            let hasMoreData = objc_getAssociatedObject(self, &hasMoreDataKey) as? Bool
            return hasMoreData ?? false
        }
        set {
            objc_setAssociatedObject(self, &hasMoreDataKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    public var kkxContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        }
        return contentInset
    }
}

// MARK: - ======== 缓存属性 ========
extension UIScrollView {
    
    /// cell高度缓存
    public var cellHeightCaches: [String: CGFloat] {
        get {
            let heightCaches = objc_getAssociatedObject(self, &cellHeightCachesKey) as? [String: CGFloat]
            return heightCaches ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &cellHeightCachesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// header高度缓存
    public var headerHeightCaches: [String: CGFloat] {
        get {
            let heightCaches = objc_getAssociatedObject(self, &headerHeightCachesKey) as? [String: CGFloat]
            return heightCaches ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &headerHeightCachesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// footer高度缓存
    public var footerHeightCaches: [String: CGFloat] {
        get {
            let heightCaches = objc_getAssociatedObject(self, &footerHeightCachesKey) as? [String: CGFloat]
            return heightCaches ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &footerHeightCachesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateCells: [String: Any] {
        get {
            let templates = objc_getAssociatedObject(self, &templateCellsKey) as? [String: Any]
            return templates ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &templateCellsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateHeaders: [String: Any] {
        get {
            let templates = objc_getAssociatedObject(self, &templateHeadersKey) as? [String: Any]
            return templates ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &templateHeadersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateFooters: [String: Any] {
        get {
            let templates = objc_getAssociatedObject(self, &templateFootersKey) as? [String: Any]
            return templates ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &templateFootersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否使用缓存, 默认false
    public var shouldKeepCaches: Bool {
        get {
            let shouldKeepCaches = objc_getAssociatedObject(self, &shouldKeepCachesKey) as? Bool
            return shouldKeepCaches ?? false
        }
        set {
            objc_setAssociatedObject(self, &shouldKeepCachesKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

private var pageNumberKey: UInt8 = 0
private var pageSizeKey: UInt8 = 0
private var shouldShowLoadingKey: UInt8 = 0
private var hasMoreDataKey: UInt8 = 0
private var cellHeightCachesKey: UInt8 = 0
private var headerHeightCachesKey: UInt8 = 0
private var footerHeightCachesKey: UInt8 = 0
private var templateCellsKey: UInt8 = 0
private var templateHeadersKey: UInt8 = 0
private var templateFootersKey: UInt8 = 0
private var shouldKeepCachesKey: UInt8 = 0
