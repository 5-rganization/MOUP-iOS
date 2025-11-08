//
//  NoticeDetailView.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class NoticeDetailView: UIView {
    
    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "공지사항")
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(18)
        $0.textColor = .gray900
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .fieldsRegular(12)
        $0.textColor = .gray600
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let contentLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
        $0.numberOfLines = 0
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateNotice(_ notice: Notice) {
        titleLabel.text = notice.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateLabel.text = dateFormatter.string(from: notice.sentAt)
        
        contentLabel.text = notice.content
    }
}

private extension NoticeDetailView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            scrollView
        )
        
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            titleLabel,
            dateLabel,
            separatorView,
            contentLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(24)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}

extension Reactive where Base: NoticeDetailView {
    var backButtonTapped: ControlEvent<Void> {
        base.navigationBar.rx.backBtnTapped
    }
}
