//
//  CalendarModeSegmentedControl.swift
//  MOUP
//
//  Created by 서동환 on 8/13/25.
//

import UIKit

/// 캘린더 개인/공유 모드 전환 토글 세그먼트
final class CalendarModeSegmentedControl: UISegmentedControl {
    
    // MARK: - Initializer
    override init(items: [Any]?) {
        super.init(items: items)
        selectedSegmentIndex = 0
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setStyles()
    }
}

private extension CalendarModeSegmentedControl {
    // MARK: - setStyles
    func setStyles() {
        // SegmentedControl 자체 스타일 설정
        self.backgroundColor = .gray100
        
        self.setContentPositionAdjustment(UIOffset(horizontal: 1.67, vertical: 0), forSegmentType: .left, barMetrics: .default)
        self.setContentPositionAdjustment(UIOffset(horizontal: -1.67, vertical: 0), forSegmentType: .right, barMetrics: .default)
        
        self.setTitleTextAttributes([.font: UIFont.headBold(16), .foregroundColor: UIColor.gray400], for: .normal)
        self.setTitleTextAttributes([.font: UIFont.headBold(16), .foregroundColor: UIColor.white], for: .selected)
        
        self.layer.borderColor = UIColor.gray400.cgColor
        self.layer.borderWidth = 1
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
        
        // 선택된 Segment의 스타일 설정
        let selectedImageViewIndex = self.numberOfSegments
        if let selectedImageView = self.subviews[selectedImageViewIndex] as? UIImageView {
            selectedImageView.image = nil
            selectedImageView.backgroundColor = .gray700
            
            selectedImageView.bounds = selectedImageView.bounds.insetBy(dx: 0, dy: 3)
            
            selectedImageView.clipsToBounds = true
            selectedImageView.layer.cornerRadius = selectedImageView.bounds.height / 2
            
            selectedImageView.layer.removeAnimation(forKey: "SelectionBounds")
        }
    }
}
