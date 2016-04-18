//
//  MenuItemView.swift
//  PagingMenuController
//
//  Created by Yusuke Kita on 5/9/15.
//  Copyright (c) 2015 kitasuke. All rights reserved.
//

import UIKit

public class MenuItemView: UIView {
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .Center
        label.userInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    public internal(set) var selected: Bool = false {
        didSet {
            if case .RoundRect = options.menuItemMode {
                backgroundColor = UIColor.clearColor()
            } else {
                backgroundColor = selected ? options.selectedBackgroundColor : options.backgroundColor
            }
            titleLabel.textColor = selected ? options.selectedTextColor : options.textColor
            titleLabel.font = selected ? options.selectedFont : options.font
            
            // adjust label width if needed
            let labelSize = calculateLableSize()
            widthLabelConstraint.constant = labelSize.width
        }
    }
    private var options: PagingMenuOptions!
    private var widthLabelConstraint: NSLayoutConstraint!
    private var labelSize: CGSize {
        guard let text = titleLabel.text else { return .zero }
        return NSString(string: text).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: titleLabel.font], context: nil).size
    }
    private let labelWidth: (CGSize, PagingMenuOptions.MenuItemWidthMode) -> CGFloat = { size, widthMode in
        switch widthMode {
        case .Flexible: return ceil(size.width)
        case .Fixed(let width): return width
        }
    }
    private var horizontalMargin: CGFloat {
        switch options.menuDisplayMode {
        case .SegmentedControl: return 0.0
        default: return options.menuItemMargin
        }
    }
    
    // MARK: - Lifecycle
    
    internal init(title: String, options: PagingMenuOptions) {
        super.init(frame: .zero)
        
        self.options = options
        
        setupView()
        setupLabel(title: title)
        layoutLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Cleanup
    
    internal func cleanup() {
        titleLabel.removeFromSuperview()
    }
    
    // MARK: - Constraints manager
    
    internal func updateLabelConstraints(size size: CGSize) {
        // set width manually to support ratotaion
        if case .SegmentedControl = options.menuDisplayMode {
            let labelSize = calculateLableSize(size)
            widthLabelConstraint.constant = labelSize.width
        }
    }
    
    // MARK: - Constructor
    
    private func setupView() {
        if case .RoundRect = options.menuItemMode {
            backgroundColor = UIColor.clearColor()
        } else {
            backgroundColor = options.backgroundColor
        }
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLabel(title title: String) {
        titleLabel.text = title
        titleLabel.textColor = options.textColor
        titleLabel.font = options.font
        addSubview(titleLabel)
    }
    
    private func layoutLabel() {
        let labelSize = calculateLableSize()
        
        // H:|[titleLabel(==labelSize.width)]|
        titleLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        titleLabel.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        widthLabelConstraint = titleLabel.widthAnchor.constraintEqualToConstant(labelSize.width)
        widthLabelConstraint.active = true
        
        // V:|[titleLabel]|
        titleLabel.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        titleLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    }
    
    // MARK: - Size calculator
    
    private func calculateLableSize(size: CGSize = UIApplication.sharedApplication().keyWindow!.bounds.size) -> CGSize {
        guard let text = titleLabel.text else { return .zero }
        
        let itemWidth: CGFloat
        switch options.menuDisplayMode {
        case let .Standard(widthMode, _, _):
            itemWidth = labelWidth(labelSize, widthMode)
        case .SegmentedControl:
            itemWidth = size.width / CGFloat(options.menuItemCount)
        case let .Infinite(widthMode):
            itemWidth = labelWidth(labelSize, widthMode)
        }
        
        let itemHeight = floor(labelSize.height)
        return CGSizeMake(itemWidth + horizontalMargin * 2, itemHeight)
    }
}
