//
//  SelectedWorkerViewController.swift
//  MOUP
//
//  Created by 양원식 on 12/1/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SelectedWorkerViewController: UIViewController {
    
    // MARK: - UI
    private let selectedWorkerView = SelectedWorkerView()
    
    // MARK: - State
    private let disposeBag = DisposeBag()
    
    /// 외부에서 주입되는 알바 리스트
    private var workers: [(id: Int, name: String)] = []
    
    /// 선택된 ID 저장
    private var selectedIds: Set<Int> = []
    
    /// 선택 완료 시 외부로 전달(필요 시)
    var onWorkersSelected: (([Int]) -> Void)?
    
    
    // MARK: - Initializer
    init(workers: [(id: Int, name: String)]) {
        self.workers = workers
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError("Storyboard is not supported")
    }
    
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = selectedWorkerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}


// MARK: - UI Methods
private extension SelectedWorkerViewController {
    
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    func setHierarchy() {
        // 이미 loadView로 추가됨 -> 추가 계층 없음
    }
    
    func setStyles() {
        view.backgroundColor = .white
    }
    
    func setConstraints() { }
    
    
    // MARK: - setActions
    func setActions() {
        // 뒤로가기
        selectedWorkerView.getNavigationBar.rx.backBtnTapped
            .bind(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 적용하기 버튼
        selectedWorkerView.getRegisterButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                
                let result = Array(selectedIds)
                print("선택된 ID:", result)
                
                onWorkersSelected?(result)
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - setBinding
    func setBinding() {
        
        Observable.just(workers)
            .bind(to: selectedWorkerView.getTableView.rx.items(
                cellIdentifier: "WorkerCell",
                cellType: WorkerCell.self
            )) { [weak self] row, worker, cell in
                
                guard let self else { return }
                let isSelected = selectedIds.contains(worker.id)
                cell.configure(name: worker.name, isSelected: isSelected)
                
                cell.onToggle = { [weak self] in
                    guard let self else { return }
                    
                    if self.selectedIds.contains(worker.id) {
                        self.selectedIds.remove(worker.id)
                    } else {
                        self.selectedIds.insert(worker.id)
                    }
                    
                    self.selectedWorkerView.getTableView.reloadRows(
                        at: [IndexPath(row: row, section: 0)],
                        with: .none
                    )
                    
                    self.selectedWorkerView.getRegisterButton.isEnabled = !self.selectedIds.isEmpty
                }
            }
            .disposed(by: disposeBag)
        
        selectedWorkerView.getTableView.rx.modelSelected((id: Int, name: String).self)
            .bind(onNext: { [weak self] worker in
                guard let self else { return }
                
                if selectedIds.contains(worker.id) {
                    selectedIds.remove(worker.id)
                } else {
                    selectedIds.insert(worker.id)
                }
                
                selectedWorkerView.getTableView.reloadData()
                selectedWorkerView.getRegisterButton.isEnabled = !selectedIds.isEmpty
            })
            .disposed(by: disposeBag)
    }

}
