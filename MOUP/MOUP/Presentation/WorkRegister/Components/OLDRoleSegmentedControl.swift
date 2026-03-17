//
//  OLDRoleSegmentedControl.swift
//  MOUP
//
//  Created by 서동환 on 11/28/25.
//

import UIKit

final class OLDRoleSegmentedControl: UISegmentedControl {
    
    // MARK: - Initializer
    
    override init(items: [Any]?) {
        super.init(items: items)
        selectedSegmentIndex = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        setStyles()
    }
}

private extension OLDRoleSegmentedControl {
    // MARK: - setStyles
    func setStyles() {
        // SegmentedControl 자체 스타일 설정
        self.backgroundColor = .gray300
        
        self.setTitleTextAttributes([.font: UIFont.bodyMedium(16), .foregroundColor: UIColor.gray500], for: .normal)
        self.setTitleTextAttributes([.font: UIFont.headBold(16), .foregroundColor: UIColor.primary500], for: .selected)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        
        // 선택된 Segment의 스타일 설정
        let selectedImageViewIndex = self.numberOfSegments
        if let selectedImageView = self.subviews[selectedImageViewIndex] as? UIImageView {
            selectedImageView.image = nil
            selectedImageView.backgroundColor = .white
            
            selectedImageView.bounds = selectedImageView.bounds.insetBy(dx: 7, dy: 7)
            
            selectedImageView.clipsToBounds = true
            selectedImageView.layer.cornerRadius = 12
            
            selectedImageView.layer.removeAnimation(forKey: "SelectionBounds")
        }
    }
}
