//
//  UITableViewExtension.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

// MARK: - ======== backgroundView ========
extension UITableView {
    
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

// MARK: - ======== UITableView注册、复用 ========
extension UITableView {
    
    /// 注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UITableViewCell>(_ cellClass: T.Type) {
        
        let identifier = String(describing: cellClass)
        register(T.self, forCellReuseIdentifier: identifier)
    }

    /// 从nib注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UITableViewCell>(_ nib: UINib?, forCellClass cellClass: T.Type) {
        
        let identifier = String(describing: cellClass)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    /// 复用cell
    /// - Parameter cellClass: 类型
    public func kkx_dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
       
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
            fatalError("Couldn't find UITableViewCell for \(identifier), make sure the cell is registered with table view")
        }
        return cell
    }
    
    /// 复用cell
    /// - Parameter cellClass: 类型
    public func kkx_dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(identifier) with reuse identifier of \(identifier)")
        }
        return cell
    }
    
    /// 从Nib注册复用header、footer
    /// - Parameter viewClass: 类型
    public func kkx_register<T: UITableViewHeaderFooterView>(_ nib: UINib?, forHeaderFooterViewClass viewClass: T.Type) {
        
        let identifier = String(describing: viewClass)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    /// 注册复用header、footer
    /// - Parameter viewClass: 类型
    public func kkx_register<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        
        let identifier = String(describing: viewClass)
        register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
    }

    /// 复用HeaderFooter
    /// - Parameter viewClass: 类型
    public func kkx_dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        
        let identifier = String(describing: viewClass)
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(identifier), make sure the view is registered with table view")
        }
        return headerFooterView
    }
}

extension UITableView {
    
    public func kkx_templateCell<T: UITableViewCell>(_ cellClass: T.Type, for key: String) -> T {
        
        if let cell = templateCells[key] as? T {
            return cell
        }
        let cell = cellClass.init()
        templateCells[key] = cell
        return cell
    }
    
    /// 获取cell高度，
    /// 只适合用在 accessoryType = .none，cell autolayout 的时候
    public func kkx_cellAutolayoutHeight<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(indexPath.section)_\(indexPath.item)"
        guard shouldKeepCaches, let height = cellHeightCaches[key] else {
            let templateKey = String(describing: cellClass) + ".templete.autolayout"
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
    
    /// 获取cell高度，重写UIView的kkxTotalHeight，返回高度
    /// 只适合用在 accessoryType = .none， 的时候
    public func kkx_cellHeight<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(indexPath.section)_\(indexPath.item)"
        guard shouldKeepCaches, let height = cellHeightCaches[key] else {
            let templateKey = String(describing: cellClass) + ".templete"
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

// MARK: - ======== UITableViewHeaderFooterView高度 ========
extension UITableView {
    
    private func kkx_templateHeaderFooter<T: UITableViewHeaderFooterView>(_ viewClass: T.Type, for key: String) -> T {
        
        if let view = templateHeaders[key] as? T {
            return view
        }
        let view = viewClass.init()
        templateHeaders[key] = view
        return view
    }
    
    /// 获取header footer高度，用在使用autolayout的header，footer
    public func kkx_headerFooterAutolayoutHeight<T: UITableViewHeaderFooterView>(_ viewClass: T.Type, for section: Int, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(section)"
        guard shouldKeepCaches, let cacheHeight = headerHeightCaches[key] else {
            let templateKey = String(describing: viewClass) + ".template.autolayout"
            let view = kkx_templateHeaderFooter(viewClass, for: templateKey)
            view.contentView.translatesAutoresizingMaskIntoConstraints = false
            view.contentView.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
            configuration(view)
            let h = view.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            headerHeightCaches[key] = h
            
            return h
        }
        
        return cacheHeight
    }
    
    /// cell中赋值kkxTotalHeight后可以用此方法获取cell高度
    public func kkx_headerFooterHeight<T: UITableViewHeaderFooterView>(_ viewClass: T.Type, for section: Int, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        
        let key = "\(section)"
        guard shouldKeepCaches, let cacheHeight = headerHeightCaches[key] else {
            let templateKey = String(describing: viewClass) + ".template"
            let view = kkx_templateHeaderFooter(viewClass, for: templateKey)
            view.frame.size.width = contentWidth
            configuration(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            let h = view.kkxTotalHeight
            headerHeightCaches[key] = h
            
            return h
        }
        
        return cacheHeight
    }
}

extension UITableView {
    
    /// 滚动到顶部
    public func kkx_scrollToTop(animated: Bool = true) {
        setContentOffset(.zero, animated: animated)
    }
    
    /// 滚动到底部
    public func kkx_scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
}

// MARK: - ======== swizzle ========
extension UITableView {
    
    public class func initializeTableView() {
        kkxSwizzleSelector(self, originalSelector: #selector(reloadData), swizzledSelector: #selector(kkx_reloadData))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadRows(at:with:)), swizzledSelector: #selector(kkx_reloadRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadSections(_:with:)), swizzledSelector: #selector(kkx_reloadSections(_:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteRows(at:with:)), swizzledSelector: #selector(kkx_deleteRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteSections(_:with:)), swizzledSelector: #selector(kkx_deleteSections(_:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertRows(at:with:)), swizzledSelector: #selector(kkx_insertRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertSections(_:with:)), swizzledSelector: #selector(kkx_insertSections(_:with:)))
    }
    
    @objc private func kkx_reloadData() {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_reloadData()
    }
    
    @objc private func kkx_reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()

        kkx_reloadRows(at: indexPaths, with: animation)
    }
    
    @objc private func kkx_reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_reloadSections(sections, with: animation)
    }
    
    @objc private func kkx_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteRows(at: indexPaths, with: animation)
    }
    
    @objc private func kkx_deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteSections(sections, with: animation)
    }
    
    @objc private func kkx_insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertRows(at: indexPaths, with: animation)
    }
    
    @objc private func kkx_insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertSections(sections, with: animation)
    }
}
