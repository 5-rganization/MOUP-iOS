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

// MARK: - SwiftUI Convert

import SwiftUI

/// `ModalGrabberView`의 SwiftUI 래퍼
///
/// `intrinsicContentSize`(45×4)가 설정되어 있어 별도 `.frame` 지정 없이 사용 가능
///
/// **사용 예시**
/// ```swift
/// VStack {
///     ModalGrabberViewSU()
///         .padding(.top, 8)
///
///     // 모달 컨텐츠 ...
/// }
/// ```
struct ModalGrabberViewSU: UIViewRepresentable {
    func makeUIView(context: Context) -> ModalGrabberView {
        let view = ModalGrabberView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: ModalGrabberView, context: Context) {}
}
