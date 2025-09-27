//
//  RoutineEditorView.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

struct RoutineEditorConfig {
    enum Mode { case add, edit }
    let mode: Mode
    var navTitle: String { mode == .add ? "새 루틴" : "루틴 변경" }
    var rightButtonTitle: String { mode == .add ? "저장" : "수정" }
}

final class RoutineEditorView: UIView {
    enum Section { case main }
    
    // MARK: - Properties
    
    fileprivate let itemTextChangeRelay = PublishRelay<(index: Int, text: String)>()
    fileprivate let itemMovedRelay = PublishRelay<(source: Int, destination: Int)>()
    fileprivate let itemDeleteRelay = PublishRelay<Int>()
    private lazy var dataSource = UITableViewDiffableDataSource<Section, TodoItem>(
        tableView: tableView
    ) { tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.id, for: indexPath) as? TodoCell else {
            fatalError("TodoCell 생성 실패")
        }
        cell.textField.text = item.text
        cell.textField.tag = indexPath.row
        cell.textField.removeTarget(nil, action: nil, for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        return cell
    }
    
    // MARK: - UI Components
    
    fileprivate let navigationBar: BaseNavigationBar
    private let routineTitleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    fileprivate let titleTextField = CustomTextField().then {
        let placeholderText = "제목을 입력해 주세요"
        $0.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .foregroundColor: UIColor.gray400,
                .font: UIFont.fieldsRegular(16)
            ]
        )
    }
    fileprivate let alarmTimeButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.clipsToBounds = true
        $0.contentHorizontalAlignment = .left
    }
    private let alarmTitleLabel = UILabel().then {
        $0.text = "알림시간"
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    private let alarmTimeChipView = UIView().then {
        $0.backgroundColor = .primary100
        $0.layer.cornerRadius = 8
        $0.isHidden = true
    }
    private let alarmTimeChipLabel = UILabel().then {
        $0.text = "00 : 00"
        $0.textColor = .gray700
        $0.font = .bodyMedium(16)
    }
    private let todoListTitleLabel = UILabel().then {
        $0.text = "할 일 리스트"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    fileprivate let addTodoButton = UIButton().then {
        $0.setImage(.plus, for: .normal)
    }
    fileprivate let tableView = UITableView()
    
    // MARK: - Initializer
    
    init(config: RoutineEditorConfig) {
        self.navigationBar = BaseNavigationBar(title: config.navTitle).then {
            $0.configureRightButton(icon: nil, title: config.rightButtonTitle)
        }
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func applyItems(_ items: [TodoItem], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TodoItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    func setAlarmTime(_ components: DateComponents?) {
        guard let c = components,
              let h = c.hour,
              let m = c.minute else {
            alarmTimeChipView.isHidden = true
            return
        }
        alarmTimeChipLabel.text = String(format: "%d : %02d", h, m)
        alarmTimeChipView.isHidden = false
    }

    func focusOnTitle() { titleTextField.becomeFirstResponder() }

    func shakeAlarmButton() {
        let a = CABasicAnimation(keyPath: "position")
        a.duration = 0.07; a.repeatCount = 3; a.autoreverses = true
        a.fromValue = NSValue(cgPoint: CGPoint(
            x: alarmTimeButton.center.x - 5, y: alarmTimeButton.center.y)
        )
        a.toValue   = NSValue(cgPoint: CGPoint(
            x: alarmTimeButton.center.x + 5, y: alarmTimeButton.center.y)
        )
        alarmTimeButton.layer.add(a, forKey: "position")
    }
}

private extension RoutineEditorView {
    // MARK: - Configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setTableView()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            navigationBar,
            routineTitleLabel,
            titleTextField,
            alarmTimeButton,
            todoListTitleLabel,
            addTodoButton,
            tableView
        )
        
        alarmTimeButton.addSubviews(
            alarmTitleLabel,
            alarmTimeChipView
        )

        alarmTimeChipView.addSubview(alarmTimeChipLabel)
    }
    
    // MARK: - setStyles()
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        routineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(routineTitleLabel.snp.bottom).offset(18)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        alarmTimeButton.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        alarmTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        alarmTimeChipView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
        }
        
        alarmTimeChipLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
            )
        }
        
        todoListTitleLabel.snp.makeConstraints {
            $0.top.equalTo(alarmTimeButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        addTodoButton.snp.makeConstraints {
            $0.centerY.equalTo(todoListTitleLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(todoListTitleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    // MARK: - setTableView
    func setTableView() {
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.id)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.isEditing = false
        tableView.allowsSelection = false

        tableView.dataSource = dataSource
        tableView.delegate = self

        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    
    @objc func textChanged(_ tf: UITextField) {
        itemTextChangeRelay.accept((tf.tag, tf.text ?? ""))
    }
}

extension RoutineEditorView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        (cell as? TodoCell)?.textField.tag = indexPath.row
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completion in
            self?.itemDeleteRelay.accept(indexPath.row)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle { .none }
    
    func tableView(
        _ tableView: UITableView,
        shouldIndentWhileEditingRowAt indexPath: IndexPath
    ) -> Bool { false }
}

@available(iOS 11.0, *)
extension RoutineEditorView: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] { dragItems(indexPath) }
    
    func tableView(
        _ tableView: UITableView,
        itemsForAddingTo session: UIDragSession,
        at indexPath: IndexPath,
        point: CGPoint
    ) -> [UIDragItem] { dragItems(indexPath) }
    
    private func dragItems(_ indexPath: IndexPath) -> [UIDragItem] {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return [] }
        let provider = NSItemProvider(object: item.text as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(
        _ tableView: UITableView,
        canHandle session: UIDropSession
    ) -> Bool { session.localDragSession != nil }
    
    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
        let dest: IndexPath = coordinator.destinationIndexPath ?? {
            let s = tableView.numberOfSections - 1
            return IndexPath(row: tableView.numberOfRows(inSection: s), section: s)
        }()
        guard let src = coordinator.items.first?.sourceIndexPath else { return }
        itemMovedRelay.accept((src.row, dest.row))
    }
}

extension Reactive where Base: RoutineEditorView {
    var navTitle: Binder<String> {
        Binder(base) { view, t in
            view.navigationBar.configureTitle(title: t)
        }
    }
    
    var rightButtonTitle: Binder<String> {
        Binder(base) { view, t in
            view.navigationBar.configureRightButton(
                icon: nil,
                title: t
            )
        }
    }
    
    var backButtonTap: ControlEvent<Void> {
        base.navigationBar.rx.backBtnTapped
    }
    
    var saveButtonTap: ControlEvent<Void> {
        base.navigationBar.rx.rightBtnTapped
    }
    
    var addButtonTap: ControlEvent<Void> {
        base.addTodoButton.rx.tap
    }
    
    var alarmTimeButtonTap: ControlEvent<Void> {
        base.alarmTimeButton.rx.tap
    }
    
    var itemTextChanged: Observable<(index: Int, text: String)> {
        base.itemTextChangeRelay.asObservable()
    }
    
    var itemMoved: Observable<(source: Int, destination: Int)> {
        base.itemMovedRelay.asObservable()
    }
    
    var itemDeleted: Observable<Int> {
        base.itemDeleteRelay.asObservable()
    }
    
    var items: Binder<[TodoItem]> {
        Binder(base) { v, items in
            v.applyItems(items)
        }
    }
    
    var focusOnRow: Binder<Int> {
        Binder(base) { v, row in
            let indexPath = IndexPath(row: row, section: 0)
            v.tableView.layoutIfNeeded()
            v.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            DispatchQueue.main.async {
                (v.tableView.cellForRow(at: indexPath) as? TodoCell)?.textField.becomeFirstResponder()
            }
        }
    }

    var titleText: ControlProperty<String?> {
        base.titleTextField.rx.text
    }
}
