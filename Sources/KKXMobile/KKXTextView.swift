//
//  KKXTextView.swift
//  Demo
//
//  Created by ming on 2021/12/2.
//

import UIKit

open class KKXTextView: UITextView {

    open override var font: UIFont? {
        get { super.font }
        set {
            super.font = newValue
            updateIntrinsicContentSize()
        }
    }
    /// 最大显示行数，默认为0无限制
    open var maxVisibleLine: Int = 0
    
    /// 自动高度变化时的回调
    @discardableResult
    public func onIntrinsicSizeChanged(_ handler: @escaping (CGSize) -> Void) -> Self {
        _intrinsicSizeChangedHandler = handler
        return self
    }
    private var _intrinsicSizeChangedHandler: ((CGSize) -> Void)?
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    private var defaultFont = UIFont.systemFont(ofSize: 16.0)

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configurations()
    }
        
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurations()
    }
                
    open func configurations() {
        textContainer.lineFragmentPadding = 0.0
        textContainerInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        contentSizeObservation = observe(\.contentSize, options: .new, changeHandler: { obj, change in
            obj.updateIntrinsicContentSize()
        })
    }
        
    open override var intrinsicContentSize: CGSize {
        _intrinsicContentSize
    }
    
    private var _intrinsicContentSize: CGSize = .zero
        
    private func updateIntrinsicContentSize() {
        let usedSize = layoutManager.usedRect(for: textContainer).size
        let width = usedSize.width + textContainerInset.left + textContainerInset.right
        let height = usedSize.height + textContainerInset.top + textContainerInset.bottom
        let size = CGSize(width: ceil(width), height: ceil(height))
        
        let f = font ?? defaultFont
        let lines = Int(usedSize.height / f.lineHeight)
        guard maxVisibleLine <= 0 || lines <= maxVisibleLine,
              _intrinsicContentSize != size  else {
            return
        }
        _intrinsicContentSize = size
        invalidateIntrinsicContentSize()
        _intrinsicSizeChangedHandler?(size)
    }
}
