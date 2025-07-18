//
//  CalendarHeaderView.swift
//  MOUP
//
//  Created by 서동환 on 7/18/25.
//

import UIKit

import BetterSegmentedControl
import SnapKit
import Then

final class CalendarHeaderView: UIView {
    
    // MARK: - UI Components
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension CalendarHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        
    }
    
    func setStyles() {
        
    }
    
    func setConstraints() {
        
    }
}
