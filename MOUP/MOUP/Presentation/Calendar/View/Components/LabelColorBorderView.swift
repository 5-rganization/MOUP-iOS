//
//  LabelColorBorderView.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 왼쪽 모서리에 라벨 컬러를 표시하는 UI
final class LabelColorBorderView: UIView {
    
    // MARK: - Properties
    private var borderColor: LabelColor = ._default {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let borderPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerRadius: 12)
        borderColor.labelColor.setFill()
        borderPath.fill()
        
        let contentPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 0, width: rect.width - 2, height: rect.height), cornerRadius: 10.5)
        UIColor.gray100.setFill()
        contentPath.fill()
    }
    
    // MARK: - Internal Methods
    func update(borderColor: LabelColor) {
        self.borderColor = borderColor
    }
}
