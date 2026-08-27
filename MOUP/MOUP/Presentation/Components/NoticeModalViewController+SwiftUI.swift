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
    /// 확인/취소 사이에 놓이는 추가 선택지. `nil`이면 표시하지 않는다.
    private let otherTitle: String?
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var onOther: (() -> Void)?
    
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
        // 실패한 근무자 목록처럼 줄 수를 예측할 수 없는 문구가 들어온다.
        $0.numberOfLines = 0
    }
    
    private lazy var confirmButton = BaseButton(title: confirmTitle, isSecondary: false)
    private lazy var cancelButton = BaseButton(title: cancelTitle ?? "", isSecondary: true)
    private lazy var otherButton = BaseButton(title: otherTitle ?? "", isSecondary: false)

    /// 선택지가 셋이면 가로로 나눠 담기 좁으므로 세로로 쌓는다.
    private lazy var buttonStackView = UIStackView().then {
        $0.axis = otherTitle == nil ? .horizontal : .vertical
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    // MARK: - Initializer

    /// - Parameters:
    ///   - cancelTitle: 취소 버튼 제목. `nil`이면 확인 버튼만 있는 1버튼 모달이 된다.
    ///   - confirmTitle: 확인 버튼 제목.
    ///   - otherTitle: 확인/취소 외 추가 선택지 제목. 지정하면 버튼이 세로로 쌓인다.
    init(title: String,
         comment: String,
         cancelTitle: String? = nil,
         confirmTitle: String = "확인",
         otherTitle: String? = nil,
         onConfirm: (() -> Void)? = nil,
         onCancel: (() -> Void)? = nil,
         onOther: (() -> Void)? = nil) {
        self.noticeTitle = title
        self.comment = comment
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.otherTitle = otherTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.onOther = onOther
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
            buttonStackView
        )

        // 세로로 쌓을 때는 주 선택지가 위로 오도록 순서를 뒤집는다.
        if otherTitle != nil {
            buttonStackView.addArrangedSubviews(confirmButton, otherButton, cancelButton)
        } else if cancelTitle != nil {
            buttonStackView.addArrangedSubviews(cancelButton, confirmButton)
        } else {
            buttonStackView.addArrangedSubview(confirmButton)
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
            // 버튼을 세로로 쌓을 때는 내용에 맞춰 높이가 정해진다.
            if otherTitle == nil {
                // 문구가 길면 높이가 늘어나되, 화면을 넘기지는 않는다.
                $0.height.greaterThanOrEqualTo(210)
                $0.height.lessThanOrEqualToSuperview().multipliedBy(0.7)
            }
        }
        
        noticeTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(noticeTitleLabel.snp.bottom).offset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            // 이 관계가 있어야 문구 길이에 맞춰 containerView 높이가 늘어난다.
            $0.bottom.lessThanOrEqualTo(buttonStackView.snp.top).offset(-20)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)

            if otherTitle != nil {
                $0.top.equalTo(commentLabel.snp.bottom).offset(24)
            }
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(45)
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

        otherButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.dismiss(animated: false) {
                    owner.onOther?()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - SwiftUI Convert

import SwiftUI

/// `NoticeModalViewController`의 SwiftUI 래퍼
///
/// > 현재 앱에서 쓰이지 않는다. SwiftUI 화면도 알림은 주입받은 `UINavigationController`의
/// > `presentNoticeModal(...)`로 띄운다 — `.fullScreenCover`는 SwiftUI 화면 위에만 덮여서
/// > 하위 화면을 push한 상태에서는 모달이 가려진다. 아래 예시는 그 제약이 없는 화면에만 해당한다.
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
