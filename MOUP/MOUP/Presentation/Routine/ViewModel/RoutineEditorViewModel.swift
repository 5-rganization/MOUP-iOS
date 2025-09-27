//
//  RoutineEditorViewModel.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RoutineEditorViewModel {
    enum Mode {
        case add
        case edit(initial: Routine)
    }
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let titleChanged: Observable<String?>
        let alarmTap: Observable<Void>
        let addTodoTap: Observable<Void>
        let itemTextChanged: Observable<(index: Int, text: String)>
        let itemMoved: Observable<(source: Int, destination: Int)>
        let itemDeleted: Observable<Int>
        let saveTap: Observable<Void>
        let backTap: Observable<Void>
    }
    
    // MARK: - Output

    struct Output {
        let navTitle: Driver<String>
        let rightButtonTitle: Driver<String>
        let items: Driver<[TodoItem]>
        let focusOnRow: Signal<Int>
        let showAlarmPicker: Signal<Void>
        let alarmComponents: Driver<DateComponents?>
        let title: Driver<String>
        let isSaving: Driver<Bool>
        let validationFocus: Signal<ValidationFocusTarget>
        let saveSucceeded: Signal<Routine>
        let pop: Signal<Void>
    }
    
    // MARK: - Properties
    
    private let mode: Mode
    private let saveStrategy: SaveStrategy
    private let disposeBag = DisposeBag()
    
    // MARK: - State
    
    private let itemsRelay: BehaviorRelay<[TodoItem]>
    private let titleRelay: BehaviorRelay<String>
    private let alarmRelay: BehaviorRelay<DateComponents?>

    private let focusRelay = PublishRelay<Int>()
    private let showAlarmRelay = PublishRelay<Void>()
    private let savingRelay = BehaviorRelay<Bool>(value: false)
    private let successRelay = PublishRelay<Routine>()
    private let errorRelay = PublishRelay<String>()
    private let validationRelay = PublishRelay<ValidationFocusTarget>()
    private let popRelay = PublishRelay<Void>()
    
    // MARK: - Initializer
    
    init(mode: Mode, saveStrategy: SaveStrategy) {
        self.mode = mode
        self.saveStrategy = saveStrategy

        switch mode {
        case .add:
            itemsRelay = BehaviorRelay(value: [TodoItem(text: "")])
            titleRelay = BehaviorRelay(value: "")
            alarmRelay = BehaviorRelay(value: nil)
        case .edit(let initial):
            itemsRelay = BehaviorRelay(
                value: initial.items.isEmpty ? [TodoItem(text: "")] : initial.items
            )
            titleRelay = BehaviorRelay(value: initial.title)
            alarmRelay = BehaviorRelay(value: initial.alarmTime)
        }
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        input.titleChanged
            .skip(1)
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .distinctUntilChanged()
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
        
        input.alarmTap
            .map { _ in () }
            .bind(to: showAlarmRelay)
            .disposed(by: disposeBag)

        input.addTodoTap
            .withLatestFrom(itemsRelay)
            .subscribe(onNext: { [weak self] current in
                guard let self else { return }
                var items = current
                if let last = items.last, last.text.isEmpty {
                    self.focusRelay.accept(items.count - 1)
                    return
                }
                items.append(TodoItem(text: ""))
                self.itemsRelay.accept(items)
                self.focusRelay.accept(items.count - 1)
            })
            .disposed(by: disposeBag)

        input.itemTextChanged
            .withLatestFrom(itemsRelay) { (change, items) -> [TodoItem] in
                var m = items
                let (idx, text) = change
                guard m.indices.contains(idx) else { return m }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if m[idx].text == trimmed { return m }
                m[idx].text = trimmed
                return m
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)

        input.itemMoved
            .withLatestFrom(itemsRelay) { (move, items) -> [TodoItem] in
                var m = items
                let (s, d) = move
                guard m.indices.contains(s), (0...m.count).contains(d) else { return m }
                let elem = m.remove(at: s)
                m.insert(elem, at: d)
                return m
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)

        input.itemDeleted
            .withLatestFrom(itemsRelay) { (idx, items) -> [TodoItem] in
                var m = items
                guard m.indices.contains(idx) else { return m }
                m.remove(at: idx)
                if m.isEmpty { m.append(TodoItem(text: "")) }
                return m
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.saveTap
            .withLatestFrom(Observable.combineLatest(
                titleRelay,
                alarmRelay,
                itemsRelay
            ))
            .flatMapLatest { [weak self] title, alarm, items -> Observable<Event<Void>> in
                guard let self else { return .empty() }

                let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleanTitle.isEmpty {
                    self.validationRelay.accept(.title)
                    return .empty()
                }
                if alarm == nil {
                    self.validationRelay.accept(.alarmTime)
                    return .empty()
                }
                let validItems = items
                    .map { TodoItem(text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    .filter { !$0.text.isEmpty }
                if validItems.isEmpty {
                    self.validationRelay.accept(.firstTodoItem)
                    return .empty()
                }

                self.savingRelay.accept(true)
                let draft = RoutineDraft(
                    title: cleanTitle,
                    alarm: alarm,
                    todos: validItems
                )
                return self.saveStrategy.save(draft)
                    .andThen(Observable.just(()))
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event in
                guard let self else { return }
                self.savingRelay.accept(false)
                switch event {
                case .next:
                    let routineID: UUID = {
                        switch self.mode {
                        case .add: return UUID()
                        case .edit(let initial): return initial.id
                        }
                    }()
                    let routine = Routine(
                        id: routineID,
                        title: self.titleRelay.value,
                        alarmTime: self.alarmRelay.value,
                        items: self.itemsRelay.value
                    )
                    self.successRelay.accept(routine)
                    self.popRelay.accept(())
                case .error(let e):
                    self.errorRelay.accept(e.localizedDescription)
                case .completed: break
                }
            })
            .disposed(by: disposeBag)

        input.backTap
            .map { _ in () }
            .bind(to: popRelay)
            .disposed(by: disposeBag)
        
        let navTitle = Observable<String>.just(
            {
                switch mode {
                case .add:
                    return "새 루틴"
                case .edit:
                    return "루틴 변경"
                }
            }()
        ).asDriver(onErrorJustReturn: "")
        
        let rightTitle = Observable<String>.just(
            {
                switch mode {
                case .add:
                    return "저장"
                case .edit:
                    return "수정"
                }
            }()
        ).asDriver(onErrorJustReturn: "")
        
        return Output(
            navTitle: navTitle,
            rightButtonTitle: rightTitle,
            items: itemsRelay.asDriver(),
            focusOnRow: focusRelay.asSignal(),
            showAlarmPicker: showAlarmRelay.asSignal(),
            alarmComponents: alarmRelay.asDriver(),
            title: titleRelay.asDriver(),
            isSaving: savingRelay.asDriver(),
            validationFocus: validationRelay.asSignal(),
            saveSucceeded: successRelay.asSignal(),
            pop: popRelay.asSignal()
        )
    }
    
    func setAlarm(_ components: DateComponents?) {
        let current = alarmRelay.value
        let same = (
            current?.hour == components?.hour
        ) && (
            current?.minute == components?.minute
        )
        if same { return }
        alarmRelay.accept(components)
    }
}
