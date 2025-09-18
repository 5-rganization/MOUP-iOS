//
//  AddRoutineView.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import UIKit
import Then
import SnapKit

final class AddRoutineView: UIView {
    
    // MARK: - Properties
    
    private var items: [TodoItem] = []
    private enum Section { case main }
    private lazy var dataSource = UITableViewDiffableDataSource<Section, TodoItem>(
        tableView: tableView
    ) { tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.id, for: indexPath) as! TodoCell
        cell.todoTextField.text = item.text
        return cell
    }
    private var isKeyboardVisible = false

    // MARK: - UI Components
    
    private let navigationBar = BaseNavigationBar(title: "새 루틴").then {
        $0.configureRightButton(icon: nil, title: "저장")
    }
    
    private let routineTitleLabel = UILabel().then {
        $0.text = "제목"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    private let textfield = CustomTextField().then {
        let placeholderText = "제목을 입력해 주세요"
        $0.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .foregroundColor: UIColor.gray400,
                .font: UIFont.fieldsRegular(16)
            ]
        )
    }
    
    private let alarmTimeButton = UIButton(configuration: .filled()).then {
        var config = $0.configuration
        config?.title = "알림시간"
        config?.baseForegroundColor = .gray900
        config?.baseBackgroundColor = .clear
        config?.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 16, bottom: 12, trailing: 16
        )
        var container = AttributeContainer()
        container.font = UIFont.bodyMedium(16)
        config?.attributedTitle = AttributedString(
            "알림시간", attributes: container
        )
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.clipsToBounds = true
    }
    
    private let todoListTitleLabel = UILabel().then {
        $0.text = "할 일 리스트"
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.setLineSpacing(.headBold)
    }
    
    private let addTodoButton = UIButton().then {
        $0.setImage(.plus, for: .normal)
    }
    
    private let tableView = UITableView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddRoutineView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setKeyboardVisible()
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
        applySnapshot(animated: false)
        
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
    
    // MARK: - setActions
    func setActions() {
        addTodoButton.addTarget(
            self,
            action: #selector(addTodoDidTap),
            for: .touchUpInside
        )
    }
    
    @objc func addTodoDidTap() {
        endEditing(true)
        tableView.setEditing(false, animated: false)
        
        if let last = items.last, last.text.isBlank {
            focusRow(items.count - 1)
            return
        }

        items.append(TodoItem(text: ""))

        applySnapshot(animated: !isKeyboardVisible)

        let last = IndexPath(row: items.count - 1, section: 0)
        tableView.scrollToRow(at: last, at: .bottom, animated: true)
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: last) as? TodoCell {
                cell.todoTextField.becomeFirstResponder()
            }
        }
    }
    
    func applySnapshot(animated: Bool = true) {
        var snap = NSDiffableDataSourceSnapshot<Section, TodoItem>()
        snap.appendSections([.main])
        snap.appendItems(items, toSection: .main)
        dataSource.apply(snap, animatingDifferences: animated)
    }
    
    func setKeyboardVisible() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func kbWillShow(_ n: Notification) { isKeyboardVisible = true }
    @objc private func kbWillHide(_ n: Notification) { isKeyboardVisible = false }
    
    func focusRow(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.layoutIfNeeded()
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? TodoCell {
                cell.todoTextField.becomeFirstResponder()
            }
        }
    }
}

extension AddRoutineView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TodoCell else { return }
        cell.todoTextField.tag = indexPath.row
        cell.todoTextField.removeTarget(nil, action: nil, for: .editingChanged)
        cell.todoTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    @objc private func textChanged(_ tf: UITextField) {
        let row = tf.tag
        guard items.indices.contains(row) else { return }
        items[row].text = tf.text ?? ""
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

@available(iOS 11.0, *)
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
        let item = items[indexPath.row]
        let provider = NSItemProvider(object: item.text as NSString)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        return [dragItem]
    }
}

@available(iOS 11.0, *)
extension AddRoutineView: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        session.localDragSession != nil
    }

    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator) {
        guard coordinator.proposal.operation == .move,
              let first = coordinator.items.first,
              let source = first.sourceIndexPath else { return }

        let dest = coordinator.destinationIndexPath ?? IndexPath(row: items.count - 1, section: 0)

        let moved = items.remove(at: source.row)
        items.insert(moved, at: dest.row)
        applySnapshot(animated: true)

        coordinator.drop(first.dragItem, toRowAt: dest)
    }
}
