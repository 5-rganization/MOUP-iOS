//
//  FilterView.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

/// 필터 UI
final class FilterView: UIView {
    
    // MARK: - Properties
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    /// 모달 핸들 UI
    private let grabberView = ModalGrabberView()
    /// 제목 라벨
    private let titleLabel = UILabel().then {
        $0.text = "필터"
        $0.font = .headBold(20)
        $0.textColor = .gray900
    }
    /// 구분선 UI
    private let separatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    /// 필터 헤더 라벨
    private let headerLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .headBold(16)
    }
    /// 필터 리스트 UI
    fileprivate let filterWorkplaceTableView = UITableView().then {
        $0.register(FilterWorkplaceCell.self, forCellReuseIdentifier: FilterWorkplaceCell.identifier)
        
        $0.separatorStyle = .none
        $0.rowHeight = 52  // 40 + 12(셀 간격)
        $0.sectionHeaderTopPadding = 0.0
    }
    /// 필터 리스트에 아이템이 없을 때 표시되는 라벨
    private let emptyLabel = UILabel().then {
        $0.text = "등록된 공유 캘린더가 없어요"
        $0.textColor = .gray500
        $0.font = .bodyMedium(16)
        $0.textAlignment = .center
    }
    /// 적용 버튼
    fileprivate let applyButton = BaseButton(title: "적용하기")
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    func update(headerStr: String) {
        headerLabel.text = headerStr
    }
    
    func selectRow(at indexPath: IndexPath) {
        filterWorkplaceTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}

private extension FilterView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.addSubviews(grabberView,
                         titleLabel,
                         separatorView,
                         headerLabel,
                         emptyLabel,
                         filterWorkplaceTableView,
                         applyButton)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.width.equalTo(45)
            $0.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(16)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(1)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(12)
            $0.leading.equalTo(self.safeAreaLayoutGuide).inset(16)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(filterWorkplaceTableView)
        }
        
        filterWorkplaceTableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(applyButton.snp.top).offset(-12)
        }
        
        applyButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(45)
        }
    }
}

// MARK: - Extension Reactive
extension Reactive where Base: FilterView {
    var filterWorkplaceTableViewDataSource: Binder<([FilterWorkplace])> {
        return Binder(base) { view, filterModel in
            // RxSwift Delegate 오류 방지
            view.filterWorkplaceTableView.dataSource = nil
            view.filterWorkplaceTableView.delegate = nil
            
            Observable.just(filterModel)
                .bind(to: view.filterWorkplaceTableView.rx.items(
                    cellIdentifier: FilterWorkplaceCell.identifier,
                    cellType: FilterWorkplaceCell.self
                )) { _, model, cell in
                    cell.update(workplaceName: model.workplaceName)
                }.disposed(by: base.disposeBag)
        }
    }
    var filterWorkplaceTableViewModelSelected: ControlEvent<FilterWorkplace> { base.filterWorkplaceTableView.rx.modelSelected(FilterWorkplace.self) }
    var applyButtonTap: ControlEvent<Void> { base.applyButton.rx.tap }
}
