//
//  LabelColorBorderView.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// 왼쪽 모서리에 라벨 컬러를 표시하는 근무 UI
final class LabelColorBorderView: UIView {
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let borderPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerRadius: 12)
        let contentPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 0, width: rect.width - 2, height: rect.height), cornerRadius: 10.5)
        borderPath.fill()
        
        UIColor.gray100.setFill()
        contentPath.fill()
    }
    
    // MARK: - Internal Methods
    func update(borderColor: LabelColorString) {
        borderColor.labelColor.setFill()
        setNeedsDisplay()
    }
}

private extension LabelColorBorderView {
    // MARK: - configure
    func configure() {
        setStyles()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
}
