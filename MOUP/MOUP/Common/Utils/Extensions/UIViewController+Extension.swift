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
    
    func presentNoticeModal(title: String, comment: String, onConfirm: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let vc = NoticeModalViewController(title: title, comment: comment, onConfirm: onConfirm)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
    }
}
