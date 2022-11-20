//
//  KKXSearchKeysController.swift
//  KKXMobile
//
//  Created by ming on 2020/8/11.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

open class KKXSearchKeysController: KKXViewController, KKXCustomSearchView {

    // MARK: -------- Properties --------
        
    public var becomeFirstResponderOnAppear = true
    
    public var historyKey: KKXSearchManager.Key?
    public var clearImage: UIImage?
    
    public var collectionView: UICollectionView {
        _collectionView
    }
    
    public var dataArray: [String] = []

    public var sectionInset = UIEdgeInsets(left: 10, right: 10)
    public var itemInsets = UIEdgeInsets(left: 15, right: 15)
    
    // MARK: -------- Private Properties --------
    
    private let textFont = UIFont.systemFont(ofSize: 14)
    
    private lazy var _collectionView: UICollectionView = {
        
        let layout = KKXSearchKeysLayout.init()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        collectionView.kkx_register(KKXSearchKeysCell.self)
        collectionView.kkx_register(KKXSearchKeysHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        collectionView.kkx_register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        return collectionView
    }()
    
    // MARK: -------- View Life Cycle --------
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        isNavigationBarHidden = true
        
        configureSubviews()
        configureNavigationBar()
        
        if let key = historyKey {
            let historys = KKXSearchManager.manager.allHistory(for: key)
            dataArray.append(contentsOf: historys.reversed())
            collectionView.reloadData()
        }
        
        if becomeFirstResponderOnAppear {
            searchView.textField.becomeFirstResponder()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let searchViewH = view.kkxSafeAreaInsets.top + 51
        searchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: searchViewH)
        
        let collectionY: CGFloat = 0
        let collectionH = view.frame.height - collectionY
        collectionView.frame = CGRect(x: 0, y: collectionY, width: view.frame.width, height: collectionH)
        collectionView.contentInset = UIEdgeInsets(top: searchViewH + 10)
    }
    
    private var searchHandler: ((KKXSearchKeysController, String) -> Void)?
    
    @discardableResult
    public func onSearch(perform action: @escaping (KKXSearchKeysController, String) -> Void) -> Self {
        searchHandler = action
        return self
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        
    }
    
    private func configureSubviews() {
        view.addSubview(collectionView)
        view.addSubview(searchView)
        
        searchView.textField.placeholder = KKXExtensionString("search")
        searchView.textField.delegate = self
        searchView.cancelButtonBehavior = .always
        searchView.contentInset = UIEdgeInsets(left: 15)
        searchView.cancelButtonClick = { [weak self](_) in
            guard let self = self else { return }
            self.backAction()
        }
        searchView.backgroundColor = UIColor.kkxCard
        view.backgroundColor = UIColor.kkxCard
    }
    
    // MARK: -------- Actions --------

    private func backAction() {
        if self.navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
}

// MARK: - ======== UICollectionViewDataSource ========
extension KKXSearchKeysController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.kkx_dequeueReusableCell(KKXSearchKeysCell.self, for: indexPath)
        cell.contentInset = itemInsets

        cell.textLabel.font = textFont
        cell.textLabel.text = dataArray[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableView = collectionView.kkx_dequeueReusableSupplementaryView(KKXSearchKeysHeader.self, ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
            reusableView.textLabel.text = KKXExtensionString("search.history")
            reusableView.textLabel.font = UIFont.systemFont(ofSize: 15)
            reusableView.textLabel.textColor = UIColor.kkxSecondary
            reusableView.clearButton.setImage(clearImage, for: .normal)
            reusableView.contentInset = UIEdgeInsets(left: 10)
            reusableView.clearButtonClickHandler = { [weak self]() in
                guard let self = self else { return }
                if let key = self.historyKey {
                    KKXSearchManager.manager.deleteAll(for: key)
                    self.dataArray.removeAll()
                    self.collectionView.reloadData()
                }
            }
            return reusableView
        default:
            break
        }
        
        return collectionView.kkx_dequeueReusableSupplementaryView(UICollectionReusableView.self, ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
    }
}

// MARK: - ======== UITextFieldDelegate ========
extension KKXSearchKeysController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !text.isEmpty, let key = historyKey {
                KKXSearchManager.manager.insert(text, for: key)
            }
            searchHandler?(self, text)
            backAction()
        }
        return true
    }
}

// MARK: - ======== UICollectionViewDelegate ========
extension KKXSearchKeysController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = dataArray[indexPath.item]
        if let key = historyKey {
            KKXSearchManager.manager.insert(text, for: key)
        }
        searchHandler?(self, text)
        backAction()
    }
}

// MARK: - ======== UICollectionViewDelegateFlowLayout ========
extension KKXSearchKeysController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth = collectionView.frame.width - sectionInset.left - sectionInset.right
        let itemHeight: CGFloat = 30
        let text = dataArray[indexPath.item] as NSString
        
        let textWidth = text.boundingRect(with: CGSize(width: 0, height: itemHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: textFont], context: nil).size.width
        var itemWidth = ceil(textWidth + itemInsets.left + itemInsets.right)
        itemWidth = min(itemWidth, maxWidth)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if dataArray.count == 0 { return .zero }
        
        let maxWidth = collectionView.frame.width
        return CGSize(width: maxWidth, height: 40)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
}
