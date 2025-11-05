//
//  AddRoutineView.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

final class AddRoutineView: UIView {
    
    // MARK: - Properties
    
    enum Section { case main }
    fileprivate lazy var dataSource = UITableViewDiffableDataSource<Section, RoutineTaskItem>(
        tableView: tableView
    ) { tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.id, for: indexPath) as? TodoCell else {
            fatalError("TodoCell을 생성할 수 없습니다.")
        }
        cell.textField.text = item.content
        return cell
    }
    fileprivate let itemTextChangeRelay = PublishRelay<(index: Int, text: String)>()
    fileprivate let itemMovedRelay = PublishRelay<(source: Int, destination: Int)>()
    fileprivate let itemDeleteRelay = PublishRelay<Int>()
    fileprivate var isHandlingDragDrop = false

    // MARK: - UI Components
    
    fileprivate let navigationBar = BaseNavigationBar(title: "새 루틴").then {
        $0.configureRightButton(icon: nil, title: "저장")
    }
    
    private let routineTitleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    fileprivate let textfield = CustomTextField().then {
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
        $0.text = "00:00"
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateRoutineTitleLabel(with title: String) {
        textfield.text = title
    }
    
    func updateAlarmTimeChip(with components: DateComponents) {
        guard let hour = components.hour, let minute = components.minute else {
            alarmTimeChipView.isHidden = true
            return
        }
        
        let timeString = String(format: "%d:%02d", hour, minute)
        
        alarmTimeChipLabel.text = timeString
        alarmTimeChipView.isHidden = false
    }
    
    func focusOnTitle() {
        textfield.becomeFirstResponder()
    }
    
    func shakeAlarmButton() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(
            x: alarmTimeButton.center.x - 5, y: alarmTimeButton.center.y
        ))
        animation.toValue = NSValue(cgPoint: CGPoint(
            x: alarmTimeButton.center.x + 5, y: alarmTimeButton.center.y
        ))
        alarmTimeButton.layer.add(animation, forKey: "position")
    }
    
    func restoreItems(_ items: [RoutineTaskItem]) {
        let validItems = items.isEmpty ? [RoutineTaskItem(
            content: "", orderIndex: 0
        )] : items
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, RoutineTaskItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(validItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

private extension AddRoutineView {
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
            routineTitleLabel,
            textfield,
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
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
        
        tableView.register(
            TodoCell.self,
            forCellReuseIdentifier: TodoCell.id
        )
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
        
        textfield.snp.makeConstraints {
            $0.top.equalTo(routineTitleLabel.snp.bottom).offset(18)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        alarmTimeButton.snp.makeConstraints {
            $0.top.equalTo(textfield.snp.bottom).offset(6)
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
            $0.edges.equalToSuperview()
                .inset(
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
}

extension AddRoutineView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TodoCell else { return }
        cell.textField.tag = indexPath.row
        cell.textField.removeTarget(nil, action: nil, for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    @objc private func textChanged(_ tf: UITextField) {
        itemTextChangeRelay.accept((index: tf.tag, text: tf.text ?? ""))
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.itemDeleteRelay.accept(indexPath.row)
            
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

extension AddRoutineView: UITableViewDragDelegate {

    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        return makeDragItems(for: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   itemsForAddingTo session: UIDragSession,
                   at indexPath: IndexPath,
                   point: CGPoint) -> [UIDragItem] {
        return makeDragItems(for: indexPath)
    }

    private func makeDragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return []
        }
        let provider = NSItemProvider(object: item.content as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension AddRoutineView: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        session.localDragSession != nil
    }

    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else { return }

        coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)

        self.isHandlingDragDrop = true

        self.itemMovedRelay.accept(
            (source: sourceIndexPath.row, destination: destinationIndexPath.row)
        )
    }
}

extension Reactive where Base: AddRoutineView {
    var backButtonTap: ControlEvent<Void> {
        return base.navigationBar.rx.backBtnTapped
    }
    
    var addButtonTap: ControlEvent<Void> {
        return base.addTodoButton.rx.tap
    }
    
    var itemTextChanged: Observable<(index: Int, text: String)> {
        return base.itemTextChangeRelay.asObservable()
    }
    
    var itemMoved: Observable<(source: Int, destination: Int)> {
        return base.itemMovedRelay.asObservable()
    }
    
    var items: Binder<[RoutineTaskItem]> {
        return Binder(self.base) { view, items in
            var snapshot = NSDiffableDataSourceSnapshot<AddRoutineView.Section, RoutineTaskItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(items, toSection: .main)

            let shouldAnimate = !view.isHandlingDragDrop
            view.dataSource.apply(snapshot, animatingDifferences: shouldAnimate)

            view.isHandlingDragDrop = false
        }
    }
    
    var focusOnRow: Binder<Int> {
        return Binder(self.base) { view, rowIndex in
            let indexPath = IndexPath(row: rowIndex, section: 0)
            
            view.tableView.layoutIfNeeded()
            view.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            DispatchQueue.main.async {
                if let cell = view.tableView.cellForRow(at: indexPath) as? TodoCell {
                    cell.textField.becomeFirstResponder()
                }
            }
        }
    }
    
    var titleText: ControlProperty<String?> {
        return base.textfield.rx.text
    }
    
    var saveButtonTap: ControlEvent<Void> {
        return base.navigationBar.rx.rightBtnTapped
    }
    
    var alarmTimeButtonTap: ControlEvent<Void> {
        base.alarmTimeButton.rx.tap
    }
    
    var itemDeleted: Observable<Int> {
        return base.itemDeleteRelay.asObservable()
    }
}
