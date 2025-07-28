//
//  CustomTextField.swift
//  MOUP
//
//  Created by 양원식 on 7/28/25.
//

import UIKit

class CustomTextField: UITextField {
    let padding = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 0)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // 텍스트를 수정하지 않을 때 텍스트가 차지하는 영역
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 텍스트를 수정할 때 텍스트가 차지하는 영역
        return bounds.inset(by: padding)
    }

    // 초기화 메서드 (필요시)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }

    private func setupTextField() {
        borderStyle = .none // 기본 테두리 스타일 제거
        layer.borderColor = UIColor.gray400.cgColor // 테두리 색상
        layer.borderWidth = 1.0 // 테두리 두께
        layer.cornerRadius = 12.0 // 모서리 둥글기
    }
}
