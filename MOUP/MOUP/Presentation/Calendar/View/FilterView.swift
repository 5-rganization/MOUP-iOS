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
    /// 필터 리스트
    fileprivate let filterTableView = UITableView().then {
        $0.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        
        $0.separatorStyle = .none
        $0.rowHeight = 52  // 40 + 12(셀 간격)
        $0.sectionHeaderTopPadding = 0.0
    }
    /// 필터 리스트에 아이템이 없을 때 표시되는 라벨
    fileprivate let emptyLabel = UILabel().then {
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
        filterTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
                         filterTableView,
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
            $0.center.equalTo(filterTableView)
        }
        
        filterTableView.snp.makeConstraints {
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
    var filterTableViewDataSource: Binder<([WorkplaceSummary])> {
        return Binder(base) { view, filterWorkplace in
            // RxSwift Delegate 오류 방지
            view.filterTableView.dataSource = nil
            view.filterTableView.delegate = nil
            
            Observable.just(filterWorkplace)
                .bind(to: view.filterTableView.rx.items(
                    cellIdentifier: FilterCell.identifier,
                    cellType: FilterCell.self
                )) { _, filterWorkplace, cell in
                    cell.update(workplaceName: filterWorkplace.name)
                }.disposed(by: base.disposeBag)
        }
    }
    var filterTableViewModelSelected: ControlEvent<WorkplaceSummary> { base.filterTableView.rx.modelSelected(WorkplaceSummary.self) }
    var filterTableViewIsHidden: Binder<Bool> { base.filterTableView.rx.isHidden }
    var emptyLabelIsHidden: Binder<Bool> { base.emptyLabel.rx.isHidden }
    var applyButtonTap: ControlEvent<Void> { base.applyButton.rx.tap }
}
