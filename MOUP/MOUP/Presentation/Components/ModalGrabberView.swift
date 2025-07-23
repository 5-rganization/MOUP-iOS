//
//  ModalGrabberView.swift
//  MOUP
//
//  Created by 서동환 on 7/23/25.
//

import UIKit

/// 모달 상단 Grabber 핸들
final class ModalGrabberView: UIView {
    
    /// 고정 크기 - 너비 45, 높이 4
    override var intrinsicContentSize: CGSize { CGSize(width: 45, height: 4) }
    
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

private extension ModalGrabberView {
    // MARK: - configure
    func configure() {
        setStyles()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .gray400
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
    }
}
