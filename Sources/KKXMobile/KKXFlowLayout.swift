//
//  KKXFlowLayout.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

public class KKXFlowLayout: UICollectionViewFlowLayout {

    public struct DecorationConfiguration {
        
        public init(maskedCornerConfiguration: MaskedCornerConfiguration = .init(), backgroundColor: UIColor = .clear, extendedLayoutIncludesHeader: Bool = false, extendedLayoutIncludesFooter: Bool = false) {
            self.maskedCornerConfiguration = maskedCornerConfiguration
            self.backgroundColor = backgroundColor
            self.extendedLayoutIncludesHeader = extendedLayoutIncludesHeader
            self.extendedLayoutIncludesFooter = extendedLayoutIncludesFooter
        }
        
        public var maskedCornerConfiguration: MaskedCornerConfiguration = .init()
        
        /// 背景色，默认 UIColor.clear
        public var backgroundColor: UIColor = .clear
        
        /// decoration布局是否延伸到sectionHeader，默认false
        public var extendedLayoutIncludesHeader: Bool = false
        
        /// decoration布局是否延伸到sectionFooter，默认false
        public var extendedLayoutIncludesFooter: Bool = false
    }
    
    // MARK: -------- Properties --------
    
    /// decoration view configuration
    public var decorationConfiguration = DecorationConfiguration() {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: -------- private Properties --------

    private let decorationIdentifier: String = "kkxDecorationIdentifier"
    private var decorationAttributes = [IndexPath: LayoutAttributes]()
    private var itemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var supplementaryAttributes = [UICollectionViewLayoutAttributes]()
    
    // MARK: -------- Init --------
    
    public override init() {
        super.init()
        configurations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurations()
    }
    
    // MARK: -------- Configurations --------
    
    private func configurations() {
        // 注册自定义装饰view
        register(DecorationView.self, forDecorationViewOfKind: decorationIdentifier)
    }
    
    // MARK: -------- LayoutAttrubutes --------
    
    public override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    public override func prepare() {
        
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        
        itemAttributes.removeAll()
        supplementaryAttributes.removeAll()
        decorationAttributes.removeAll()
        let sections = collectionView.numberOfSections
        
        for section in 0..<sections {
            /*
            // 高度大于0时，创建header attributes
            if headerSize(in: section).height > 0, let header = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
                supplementaryAttributes.append(header)
            }
            
            // 高度大于0时，创建footer attributes
            if footerSize(in: section).height > 0, let footer = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section)) {
                supplementaryAttributes.append(footer)
            }
            
            // 创建items attributes
            let items = collectionView.numberOfItems(inSection: section)
            for item in 0..<items {
                let indexPath = IndexPath(item: item, section: section)
                if let item = self.layoutAttributesForItem(at: indexPath) {
                    itemAttributes[indexPath] = item
                }
            }
            */
            // 根据代理回调判断是否需要创建decoration attributes
            if let delegate = collectionView.delegate as? CollectionViewDelegate, delegate.collectionView(collectionView, hasDecorationViewAt: section) {
                createDecorationView(inSection: section)
            }
        }
        
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        var newAttributes = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        /*
        /// 添加rect范围下显示的cell
        attrubutes.append(contentsOf: itemAttributes.values.filter({
            rect.intersects($0.frame)
        }))
        /// 添加rect范围下显示的supplementary
        attrubutes.append(contentsOf: supplementaryAttributes.filter({
            rect.intersects($0.frame)
        }))
         */
        /// 添加rect范围下显示的装饰
        newAttributes.append(contentsOf: decorationAttributes.values.filter({
            rect.intersects($0.frame)
        }))

        return newAttributes
    }
    
    public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == decorationIdentifier {
            return decorationAttributes[indexPath]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    public override var collectionViewContentSize: CGSize {
        super.collectionViewContentSize
    }
    
    // MARK: -------- Private Method --------
    
    /// 创建decorationView
    /// - Parameter section: seciton
    private func createDecorationView(inSection section: Int) {
        guard let collectionView = collectionView else {
            return
        }
        
        let items = collectionView.numberOfItems(inSection: section)
        
        if !decorationConfiguration.extendedLayoutIncludesHeader &&
           !decorationConfiguration.extendedLayoutIncludesFooter &&
           items <= 0 {
            return
        }
        
        // 计算装饰视图布局
        var decorationFrame = CGRect.zero
        if items > 0, let firstItemAttributes = layoutAttributesForItem(at: IndexPath(item: 0, section: section)) {
            decorationFrame = firstItemAttributes.frame
        }
        
        for i in 0..<items {
            if let attributes = layoutAttributesForItem(at: IndexPath(item: i, section: section)) {
                decorationFrame = decorationFrame.union(attributes.frame)
            }
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        
        let decorationInset = decorationInsetsForSection(section)
        let sectionInset = insetsForSection(section)
        let decorationWidth = collectionView.contentWidth
        
        let originX = decorationInset.left
        var originY = decorationFrame.origin.y + decorationInset.top
        let width = decorationWidth - decorationInset.left - decorationInset.right
        var height = decorationFrame.height - decorationInset.top - decorationInset.bottom
        
        /// 包含header
        if decorationConfiguration.extendedLayoutIncludesHeader {
            var headerFrame = CGRect.zero
            if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                headerFrame = headerAttributes.frame
            }
            let additionTop = headerFrame.height + sectionInset.top
            originY = headerFrame.origin.y + decorationInset.top
            height += additionTop
        }
        /// 包含footer
        if decorationConfiguration.extendedLayoutIncludesFooter {
            var footerFrame = CGRect.zero
            if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath) {
                footerFrame = footerAttributes.frame
            }
            if !decorationConfiguration.extendedLayoutIncludesHeader {
                originY = footerFrame.origin.y + decorationInset.top
                height += decorationInset.top
            }
            let additionBottom = footerFrame.height + sectionInset.bottom
            height += additionBottom
        }
        
        decorationFrame = CGRect(x: originX, y: originY, width: width, height: height)
        
        // 创建装饰视图
        let attributes = LayoutAttributes(forDecorationViewOfKind: decorationIdentifier, with: indexPath)
        attributes.frame = decorationFrame
        attributes.zIndex = -1
        attributes.backgrounColor = decorationConfiguration.backgroundColor
        attributes.maskedCornerConfiguration = decorationConfiguration.maskedCornerConfiguration
        decorationAttributes[indexPath] = attributes
    }
}

// MARK: - ======== LayoutAttributes ========
private class LayoutAttributes: UICollectionViewLayoutAttributes {
        
    internal var backgrounColor: UIColor = .clear
    
    internal var maskedCornerConfiguration: MaskedCornerConfiguration = .init()
}

// MARK: - ======== DecorationView ========
private class DecorationView: UICollectionReusableView {
    
    internal override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? LayoutAttributes {
            maskedCorners(attributes.maskedCornerConfiguration)
            backgroundColor = attributes.backgrounColor
        }
    }
}
