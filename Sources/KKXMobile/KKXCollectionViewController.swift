//
//  KKXCollectionViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit

private let cellIdentifier = "UICollectionViewCell"
private let reusableIdentifier = "UICollectionReusableView"

open class KKXCollectionViewController: KKXViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    public var collectionViewLayout: UICollectionViewLayout {
        _collectionViewLayout
    }
    
    open var collectionView: UICollectionView! {
        get { _collectionView }
        set {
            _collectionView.removeFromSuperview()
            _collectionView = newValue
            view.addSubview(newValue)
            reloadViewConstraints()
        }
    }
    
    private var _collectionViewLayout = UICollectionViewLayout()
    
    private var _collectionView: UICollectionView!
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(nibName: nil, bundle: nil)
        _collectionViewLayout = layout
        _collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = defaultConfiguration.mainBackground

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reusableIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reusableIdentifier)
        
        if collectionView.superview == nil {
            view.addSubview(collectionView)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        reloadViewConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    private func reloadViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [
            .top, .left, .bottom, .right
        ]
        for attribute in attributes {
            NSLayoutConstraint(item: collectionView!, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
        }
    }
    
    // MARK: - ======== UICollectionViewDataSource ========

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
                
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusableIdentifier, for: indexPath)
    }
}

extension KKXCollectionViewController: KKXKeyboardShowHideProtocol {
    
    public var aScrollView: UIScrollView {
        _collectionView
    }
}

extension KKXCollectionViewController: KKXAdjustmentBehaviorProtocol {
    
    public var kkxAdjustsScrollViewInsets: Bool {
        get {
            if #available(iOS 11.0, *) {
                return collectionView.contentInsetAdjustmentBehavior != .never
            }
            else {
                return automaticallyAdjustsScrollViewInsets
            }
        }
        set {
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = newValue ? .always:.never
            }
            else {
                automaticallyAdjustsScrollViewInsets = newValue
            }
        }
    }
}
