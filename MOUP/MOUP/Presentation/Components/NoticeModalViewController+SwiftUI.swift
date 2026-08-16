//
//  NoticeModalViewController.swift
//  MOUP
//
//  Created by 송규섭 on 10/20/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class NoticeModalViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let noticeTitle: String
    private let comment: String
    /// 취소 버튼 제목. `nil`이면 확인 버튼만 표시한다.
    private let cancelTitle: String?
    private let confirmTitle: String
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    // MARK: - UI Components
    private let dimmedView = UIView().then {
        $0.backgroundColor = .gray900.withAlphaComponent(0.5)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let noticeTitleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .headBold(18)
        $0.textAlignment = .left
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 1
    }
    
    private let commentLabel = UILabel().then {
        $0.textColor = .gray700
        $0.font = .bodyMedium(14)
        $0.textAlignment = .left
        $0.lineBreakMode = .byWordWrapping
        $0.numberOfLines = 2
    }
    
    private lazy var confirmButton = BaseButton(title: confirmTitle, isSecondary: false)
    private lazy var cancelButton = BaseButton(title: cancelTitle ?? "", isSecondary: true)

    // MARK: - Initializer

    /// - Parameters:
    ///   - cancelTitle: 취소 버튼 제목. `nil`이면 확인 버튼만 있는 1버튼 모달이 된다.
    ///   - confirmTitle: 확인 버튼 제목.
    init(title: String,
         comment: String,
         cancelTitle: String? = nil,
         confirmTitle: String = "확인",
         onConfirm: (() -> Void)? = nil,
         onCancel: (() -> Void)? = nil) {
        self.noticeTitle = title
        self.comment = comment
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
}

private extension NoticeModalViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setBindings()
    }
    
    func setHierarchy() {
        view.addSubviews(
            dimmedView,
            containerView
        )
        
        containerView.addSubviews(
            noticeTitleLabel,
            commentLabel,
            confirmButton
        )

        if cancelTitle != nil {
            containerView.addSubview(cancelButton)
        }
    }
    
    func setStyles() {
        noticeTitleLabel.text = noticeTitle
        commentLabel.text = comment
    }
    
    func setConstraints() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(210)
        }
        
        noticeTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        confirmButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(45)

            // 취소 버튼이 있으면 하단을 반씩 나눠 쓴다.
            if cancelTitle == nil {
                $0.leading.equalToSuperview().inset(16)
            } else {
                $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
                $0.width.equalTo(cancelButton)
            }
        }

        guard cancelTitle != nil else { return }

        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.height.equalTo(confirmButton)
        }
    }
    
    func setBindings() {
        confirmButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: false) {
                    owner.onConfirm?()
                }
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: false) {
                    owner.onCancel?()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - SwiftUI Convert

import SwiftUI

/// `NoticeModalViewController`의 SwiftUI 래퍼
///
/// **사용 예시**
/// ```swift
/// @State private var showNotice = false
///
/// var body: some View {
///     Button("알림 표시") {
///         showNotice = true
///     }
///     .fullScreenCover(isPresented: $showNotice) {
///         NoticeModalViewControllerSU(
///             title: "알림",
///             comment: "작업이 완료되었습니다."
///         ) {
///             showNotice = false
///         }
///     }
/// }
/// ```
struct NoticeModalViewControllerSU: UIViewControllerRepresentable {
    let title: String
    let comment: String
    var onConfirm: (() -> Void)?
    
    func makeUIViewController(context: Context) -> NoticeModalViewController {
        let vc = NoticeModalViewController(title: title, comment: comment, onConfirm: onConfirm)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NoticeModalViewController, context: Context) {}
}
