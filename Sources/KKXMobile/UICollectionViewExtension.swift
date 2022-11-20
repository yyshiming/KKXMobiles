//
//  UICollectionViewExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== backgroundView ========
extension UICollectionView {
    
    public var kkxBackgroundView: UIView {
        guard let bgView = objc_getAssociatedObject(self, &kkxBackgroundViewKey) as? UIView else {
            let bgView = UIView()
            backgroundView = bgView
            objc_setAssociatedObject(self, &kkxBackgroundViewKey, bgView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bgView
        }
        return bgView
    }
}
private var kkxBackgroundViewKey: UInt8 = 0

// MARK: - ======== UICollectionView注册、复用 ========
extension UICollectionView {

    /// 从Nib注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_registerFromNib<T: UICollectionViewCell>(_ cellClass: T.Type) {
        
        let identifier = String(describing: cellClass)
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    /// 从Nib注册复用Cell
    /// - Parameter nib: Nib
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UICollectionViewCell>(_ nib: UINib?, forCellWithClass cellClass: T.Type) {
        
        let identifier = String(describing: cellClass)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        
        let identifier = String(describing: cellClass)
        register(T.self, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册ReusableView
    /// - Parameter viewClass: 类型
    /// - Parameter kind: kind
    public func kkx_register<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        
        let identifier = String(describing: viewClass)
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    /// 从Nib注册ReusableView
    /// - Parameter kind: kind
    /// - Parameter viewClass: 类型
    public func kkx_registerFromNib<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
       
        let identifier = String(describing: viewClass)
        register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    /// 从Nib注册ReusableView
    /// - Parameter nib: Nib
    /// - Parameter kind: kind
    /// - Parameter viewClass: 类型
    public  func kkx_register<T: UICollectionReusableView>(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withViewClass viewClass: T.Type) {
        
        let identifier = String(describing: viewClass)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    /// 获取复用cell
    /// - Parameter aClass: 类型
    /// - Parameter indexPath: indexPath
    public func kkx_dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(identifier) with reuse identifier of \(identifier)")
        }
        return cell
    }
    
    /// 获取复用ReusableView
    /// - Parameter viewClass: 类型
    /// - Parameter kind: kind
    /// - Parameter indexPath: indexPath
    public func kkx_dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewClass: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: viewClass)
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(identifier), make sure the view is registered with collection view")
        }
        return cell
    }
    
}

// MARK: - ======== UICollectionViewcell高度 ========
extension UICollectionView {
    
    private func kkx_templateCell<T: UICollectionViewCell>(_ cellClass: T.Type, for key: String) -> T {
        
        guard let cell = templateCells[key] as? T else {
            let cell = cellClass.init()
            templateCells[key] = cell
            return cell
        }
        return cell
    }
    
    /// 获取Cell高度，用在使用 AutoLayout的Cell中
    /// - Parameter cellClass: cell类型
    /// - Parameter indexPath: indexPath
    /// - Parameter contentWidth: cell宽度约束值
    /// - Parameter configuration: 配置cell
    public func kkx_cellAutolayoutHeight<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(indexPath.section)_\(indexPath.item)"
        guard shouldKeepCaches, let height = cellHeightCaches[key] else {
            let templateKey = String(describing: cellClass) + ".template.autolayout"
            let cell = kkx_templateCell(cellClass, for: templateKey)
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
            configuration(cell)

            let height = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            cellHeightCaches[key] = height
            return height
        }
        
        return height
    }
    
    /// cell中赋值kkxTotalHeight后可以用此方法获取cell高度
    /// - Parameter cellClass: cell类型
    /// - Parameter indexPath: indexPath
    /// - Parameter contentWidth: cell宽度
    /// - Parameter configuration: 配置cell
    public func kkx_cellHeight<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(indexPath.section)_\(indexPath.item)"
        guard shouldKeepCaches, let height = cellHeightCaches[key] else {
            let templateKey = String(describing: cellClass) + ".template"
            let cell = kkx_templateCell(cellClass, for: templateKey)
            cell.frame.size.width = contentWidth
            configuration(cell)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let height = cell.kkxTotalHeight
            cellHeightCaches[key] = height
            
            return height
        }
        
        return height
    }
}

// MARK: - ======== UICollectionViewReusableView高度 ========
extension UICollectionView {
    
    private func kkx_templateReusableView<T: UICollectionReusableView>(_ viewClass: T.Type, ofKind kind: String, for key: String) -> T {
        
        var view = templateHeaders[key] as? T
        if kind == UICollectionView.elementKindSectionFooter {
            view = templateFooters[key] as? T
        }
        if view == nil {
            let newView = viewClass.init()
            if kind == UICollectionView.elementKindSectionFooter {
                templateFooters[key] = newView
            } else {
                templateHeaders[key] = newView
            }
            view = newView
        }
        return view!
    }
    
    /// 获取header footer高度，用在使用AutoLayout的header footer中
    /// - Parameter viewClass: ReusableView类型
    /// - Parameter kind: Header/Footer
    /// - Parameter section: section
    /// - Parameter contentWidth: view宽度约束值
    /// - Parameter configuration: 配置view
    public func kkx_reusableViewAutolayoutHeight<T: UICollectionReusableView>(_ viewClass: T.Type, ofKind kind: String, for section: Int, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(section)"
        var height = headerHeightCaches[key]
        if kind == UICollectionView.elementKindSectionFooter {
            height = footerHeightCaches[key]
        }
        guard shouldKeepCaches, let cacheHeight = height else {
            let templateKey = String(describing: viewClass) + ".template.autolayout"
            let view = kkx_templateReusableView(viewClass, ofKind: kind, for: templateKey)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
            configuration(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if kind == UICollectionView.elementKindSectionFooter {
                footerHeightCaches[key] = height
            } else {
                headerHeightCaches[key] = height
            }
            return height
        }
        return cacheHeight
    }
    
    /// cell中赋值kkxTotalHeight后可以用此方法获取cell高度
    /// - Parameter viewClass: view类型
    /// - Parameter kind: Header/Footer
    /// - Parameter section: section
    /// - Parameter contentWidth: view宽度约束值
    /// - Parameter configuration: 配置view
    public func kkx_reusableViewHeight<T: UICollectionReusableView>(_ viewClass: T.Type, ofKind kind: String, for section: Int, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(section)"
        var height = headerHeightCaches[key]
        if kind == UICollectionView.elementKindSectionFooter {
            height = footerHeightCaches[key]
        }
        guard shouldKeepCaches, let cacheHeight = height else {
            let templateKey = String(describing: viewClass) + ".template"
            let view = kkx_templateReusableView(viewClass, ofKind: kind, for: templateKey)
            view.frame.size.width = contentWidth
            configuration(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            let h = view.kkxTotalHeight
            if kind == UICollectionView.elementKindSectionFooter {
                footerHeightCaches[key] = h
            } else {
                headerHeightCaches[key] = h
            }
            
            return h
        }
        
        return cacheHeight
    }
}

// MARK: - ======== swizzle ========
extension UICollectionView {
    
    public class func initializeCollectionView() {
        kkxSwizzleSelector(self, originalSelector: #selector(reloadData), swizzledSelector: #selector(kkxReloadData))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadItems(at:)), swizzledSelector: #selector(kkxReloadItems(at:)))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadSections(_:)), swizzledSelector: #selector(kkxReloadSections(_:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteItems(at:)), swizzledSelector: #selector(kkxDeleteItems(at:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteSections(_:)), swizzledSelector: #selector(kkxDeleteSections(_:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertItems(at:)), swizzledSelector: #selector(kkxInsertItems(at:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertSections(_:)), swizzledSelector: #selector(kkxInsertSections(_:)))
    }
    
    @objc private func kkxReloadData() {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxReloadData()
    }
    
    @objc private func kkxReloadItems(at indexPaths: [IndexPath]) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()

        kkxReloadItems(at: indexPaths)
    }
    
    @objc private func kkxReloadSections(_ sections: IndexSet) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxReloadSections(sections)
    }
    
    @objc private func kkxDeleteItems(at indexPaths: [IndexPath]) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxDeleteItems(at: indexPaths)
    }
    
    @objc private func kkxDeleteSections(_ sections: IndexSet) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxDeleteSections(sections)
    }
    
    @objc private func kkxInsertItems(at indexPaths: [IndexPath]) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxInsertItems(at: indexPaths)
    }
    
    @objc private func kkxInsertSections(_ sections: IndexSet) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkxInsertSections(sections)
    }
}

extension UICollectionView {
    
    public var contentWidth: CGFloat {
        return frame.width - contentInset.left - contentInset.right
    }
    
    public var contentHeight: CGFloat {
        return frame.height - contentInset.top - contentInset.bottom
    }
    
}
extension UICollectionViewLayout {
    
    public var width: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
    }
    
    public var height: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom
    }
    
    public func insetsForSection(_ section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView, let flowLayoutDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let inset = flowLayoutDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) else {
            if let flowLayout = self as? UICollectionViewFlowLayout {
                return flowLayout.sectionInset
            }
            return .zero
        }
        
        return inset
    }
    
    public var sections: Int {
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let sections = dataSource.numberOfSections?(in: collectionView) {
            return sections
        }
        return 0
    }
    
    public func items(in section: Int) -> Int {
        if let collectionView = collectionView,
           let delegate = collectionView.dataSource {
            return delegate.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return 0
    }
    
    public func itemSize(at indexPath: IndexPath) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return size
        }
        return .zero
    }
    
    public func headerSize(in section: Int) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
            return size
        }
        return .zero
    }
    
    public func footerSize(in section: Int) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
            return size
        }
        return .zero
    }
    
    public func decorationInsetsForSection(_ section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? CollectionViewDelegate {
            let inset = delegate.collectionView(collectionView, layout: self, decorationViewInsetForSectionAt: section)
            return inset
        }
        return .zero
    }
    
}

public protocol CollectionViewDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, hasDecorationViewAt section: Int) -> Bool
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationViewInsetForSectionAt section: Int) -> UIEdgeInsets
}

extension CollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, hasDecorationViewAt section: Int) -> Bool {
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationViewInsetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
}
