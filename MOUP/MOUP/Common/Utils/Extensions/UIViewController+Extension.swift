//
//  UIViewController+Extension.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit

extension UIViewController {
    /// 자식 뷰컨트롤러를 지정된 컨테이너 뷰에 추가합니다.
    func add(child: UIViewController, to container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        child.didMove(toParent: self)
    }
    
    /// 자식 뷰컨트롤러를 현재 뷰컨트롤러에서 제거합니다.
    func remove(child: UIViewController) {
        guard children.contains(child) else { return }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    /// - Parameter cancelTitle: 취소 버튼 제목. `nil`이면 확인 버튼만 있는 1버튼 모달이 된다.
    func presentNoticeModal(title: String,
                            comment: String,
                            cancelTitle: String? = nil,
                            confirmTitle: String = "확인",
                            otherTitle: String? = nil,
                            onConfirm: (() -> Void)? = nil,
                            onCancel: (() -> Void)? = nil,
                            onOther: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let vc = NoticeModalViewController(title: title,
                                               comment: comment,
                                               cancelTitle: cancelTitle,
                                               confirmTitle: confirmTitle,
                                               otherTitle: otherTitle,
                                               onConfirm: onConfirm,
                                               onCancel: onCancel,
                                               onOther: onOther)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
    }
}
