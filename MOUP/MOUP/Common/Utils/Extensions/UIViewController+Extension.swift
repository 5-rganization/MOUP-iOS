//
//  UIViewController+Extension.swift
//  MOUP
//
//  Created by 양원식 on 7/15/25.
//

import UIKit

extension UIViewController {
    func setNavigationBar(
        title: String,
        titleColor: UIColor = .gray900,
        titleFont: UIFont = .headBold(20),
        backButtonColor: UIColor = .gray700,
        backAction: Selector? = nil
    ) {
        self.title = title

        // 타이틀 색상 및 폰트 설정
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont
        ]

        // 뒤로가기 버튼 설정
        if let backAction = backAction {
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: backAction
            )
            backButton.tintColor = backButtonColor
            self.navigationItem.leftBarButtonItem = backButton
        }
    }
    
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
}
