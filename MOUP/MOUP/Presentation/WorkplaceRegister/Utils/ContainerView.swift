//
//  containerView.swift
//  MOUP
//
//  Created by 양원식 on 7/16/25.
//

import Foundation
import UIKit

final class ContainerView: UIView {
    // MARK: - Properties
    
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
    
    // MARK: - Public Methods
}

private extension ContainerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        
    }
    
    // MARK: - setStyles
    func setStyles() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray400.cgColor
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
    }
}

