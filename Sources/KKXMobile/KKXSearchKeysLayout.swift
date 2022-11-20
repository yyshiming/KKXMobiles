//
//  KKXSearchKeysLayout.swift
//  KKXMobile
//
//  Created by ming on 2020/8/11.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

open class KKXSearchKeysLayout: UICollectionViewFlowLayout {

    private var sectionFrames: [[CGRect]] = []
    private var headerFrames: [CGRect] = []
    
    open var itemInsets = UIEdgeInsets.zero {
        didSet {
            invalidateLayout()
        }
    }
    
    open override func prepare() {
        super.prepare()
        
        self.scrollDirection = .vertical
        
        guard let collectionView = collectionView else {
            return
        }
        sectionFrames.removeAll()
        headerFrames.removeAll()
        for section in 0..<collectionView.numberOfSections {
            layoutAttributes(at: section)
        }
    }
    
    private func layoutAttributes(at section: Int) {
        guard let collectionView = collectionView else {
            return
        }
        
        let insets = self.insetsForSection(section)
        let itemCount = self.items(in: section)
        
        let size = headerSize(in: section)
        let headerX = (collectionView.frame.width - size.width) / 2
        var headerFrame = CGRect(x: headerX, y: 0, width: size.width, height: size.height)
        if section > 0 {
            if sectionFrames.count > section - 1 {
                let preSectionFrames = sectionFrames[section - 1]
                let preInsets = self.insetsForSection(section - 1)
                let preItemCount = self.items(in: section - 1)
                let lastItemFrame = preSectionFrames[preItemCount - 1]
                headerFrame.origin.y = lastItemFrame.maxY + preInsets.bottom
            }
        }
        headerFrames.append(headerFrame)

        let minX = collectionView.contentInset.left + insets.left
        let minY = headerFrame.maxY + insets.top
        let maxX = collectionView.frame.width - collectionView.contentInset.right - insets.right
        
        var frames: [CGRect] = []
        let origin = CGPoint(x: minX, y: minY)
        for i in 0..<itemCount {
            var currentOrigin = origin
            let currentIndexPath = IndexPath(item: i, section: section)
            let currentSize = self.itemSize(at: currentIndexPath)
            if i > 0, frames.count > i - 1 {
                let preItemFrame = frames[i - 1]
                let currentX = preItemFrame.maxX + minimumInteritemSpacing
                // 如果大于最大宽度就换行
                if (currentX + currentSize.width) > maxX {
                    currentOrigin.x = minX
                    currentOrigin.y = preItemFrame.maxY + minimumLineSpacing
                } else {
                    currentOrigin.x = currentX
                    currentOrigin.y = preItemFrame.origin.y
                }
            }
            frames.append(CGRect(origin: currentOrigin, size: currentSize))
        }
        sectionFrames.append(frames)
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect) ?? []
        let newAttributed = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        for attr in newAttributed {
            switch attr.representedElementCategory {
            case .cell:
                let frame = sectionFrames[attr.indexPath.section][attr.indexPath.row]
                attr.frame = frame
            case .supplementaryView:
                if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                    let frame = headerFrames[attr.indexPath.section]
                    attr.frame = frame
                }
            default:
                continue
            }
        }
        return newAttributed
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath)
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
