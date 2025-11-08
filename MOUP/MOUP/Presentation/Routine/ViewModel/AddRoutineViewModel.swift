//
//  AddRoutineViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import Foundation
import RxSwift
import RxCocoa

enum ValidationFocusTarget {
    case title
    case alarmTime
    case firstTodoItem
}

final class AddRoutineViewModel {
    
    // MARK: - Input
    
    struct Input {
        let titleChanged: Observable<String>
        let alarmTimeChanged: Observable<DateComponents?>
        let saveButtonTapped: Observable<Void>
        
        let addTodoButtonTapped: Observable<Void>
        let itemTextChanged: Observable<(index: Int, text: String)>
        let itemMoved: Observable<(source: Int, destination: Int)>
        let itemDeleted: Observable<Int>
        
        let itemsLoaded: Observable<[RoutineTaskItem]>?
    }
    
    // MARK: - Output
    
    struct Output {
        let items: Driver<[RoutineTaskItem]>
        let focusOnRow: Signal<Int>
        let title: Driver<String>
        let validationFocus: Signal<ValidationFocusTarget>
        let saveCompleted: Signal<RoutineSummary>
        let error: Signal<String>
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let storage: DraftRoutineStorageProtocol
    private let routineUseCase: RoutineUseCaseProtocol
    
    // MARK: - Initializer
    
    init(
        routineUseCase: RoutineUseCaseProtocol,
        storage: DraftRoutineStorageProtocol = DraftRoutineStorage.shared
    ) {
        self.routineUseCase = routineUseCase
        self.storage = storage
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let itemsRelay = BehaviorRelay<[RoutineTaskItem]>(value: [
            RoutineTaskItem(content: "", orderIndex: 0)
        ])
        let titleRelay = BehaviorRelay<String>(value: "")
        let alarmTimeRelay = BehaviorRelay<DateComponents?>(value: nil)
        
        let focusRelay = PublishRelay<Int>()
        let validationFocusRelay = PublishRelay<ValidationFocusTarget>()
        let saveCompletedRelay = PublishRelay<RoutineSummary>()
        let errorRelay = PublishRelay<String>()
        
        input.titleChanged
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
        
        input.alarmTimeChanged
            .bind(to: alarmTimeRelay)
            .disposed(by: disposeBag)
        
        if let itemsLoaded = input.itemsLoaded {
            itemsLoaded
                .bind(to: itemsRelay)
                .disposed(by: disposeBag)
        }
        
        input.addTodoButtonTapped
            .withLatestFrom(itemsRelay)
            .subscribe(onNext: { currentItems in                
                var newItems = currentItems
                
                if let lastItem = newItems.last, lastItem.content.isEmpty {
                    focusRelay.accept(newItems.count - 1)
                    return
                }
                
                let newOrderIndex = (newItems.last?.orderIndex ?? -1) + 1
                newItems.append(RoutineTaskItem(content: "", orderIndex: newOrderIndex))
                itemsRelay.accept(newItems)
                focusRelay.accept(newItems.count - 1)
            })
            .disposed(by: disposeBag)
        
        input.itemTextChanged
            .withLatestFrom(itemsRelay) { (change, currentItems) -> [RoutineTaskItem] in
                var newItems = currentItems
                let (index, text) = change
                guard newItems.indices.contains(index) else { return newItems }

                newItems[index] = RoutineTaskItem(
                    content: text,
                    orderIndex: newItems[index].orderIndex,
                    id: newItems[index].id
                )
                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.itemMoved
            .withLatestFrom(itemsRelay) { (move, currentItems) -> [RoutineTaskItem] in
                var newItems = currentItems
                let (sourceIndex, destinationIndex) = move

                guard newItems.indices.contains(sourceIndex),
                      (0...newItems.count).contains(destinationIndex) else { return newItems }

                let itemToMove = newItems.remove(at: sourceIndex)
                newItems.insert(itemToMove, at: destinationIndex)

                return newItems.enumerated().map { index, item in
                    RoutineTaskItem(content: item.content, orderIndex: index, id: item.id)
                }
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.itemDeleted
            .withLatestFrom(itemsRelay) { (indexToDelete, currentItems) -> [RoutineTaskItem] in
                var newItems = currentItems
                guard newItems.indices.contains(indexToDelete) else { return newItems }

                newItems.remove(at: indexToDelete)

                if newItems.isEmpty {
                    newItems.append(RoutineTaskItem(content: "", orderIndex: 0))
                } else {
                    newItems = newItems.enumerated().map { index, item in
                        RoutineTaskItem(content: item.content, orderIndex: index, id: item.id)
                    }
                }

                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(titleRelay, alarmTimeRelay, itemsRelay)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .take(until: saveCompletedRelay)
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                let (title, alarmTime, items) = value

                let hasTitle = !title.isEmpty
                let hasAlarmTime = alarmTime != nil
                let hasValidItems = items.contains { !$0.content.isEmpty }

                if hasTitle || hasAlarmTime || hasValidItems {
                    let draft = DraftRoutine(
                        title: title,
                        alarmTime: alarmTime,
                        items: items,
                        savedAt: Date()
                    )
                    owner.storage.saveDraft(draft)
                } else {
                    owner.storage.deleteDraft()
                }
            })
            .disposed(by: disposeBag)

        saveCompletedRelay
            .subscribe(onNext: { [weak self] _ in
                self?.storage.deleteDraft()
            })
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withLatestFrom(Observable.combineLatest(
                titleRelay,
                alarmTimeRelay,
                itemsRelay
            ))
            .flatMapLatest { [weak self] (title, alarmTime, items) -> Observable<RoutineSummary> in
                guard let self else { return .empty() }
                
                if title.isEmpty {
                    validationFocusRelay.accept(.title)
                    return .empty()
                }
                
                guard let alarmTime = alarmTime else {
                    validationFocusRelay.accept(.alarmTime)
                    return .empty()
                }
                
                let validItems = items.filter { !$0.content.isBlank }
                if validItems.isEmpty {
                    validationFocusRelay.accept(.firstTodoItem)
                    return .empty()
                }
                
                guard let hour = alarmTime.hour,
                      let minute = alarmTime.minute else {
                    validationFocusRelay.accept(.alarmTime)
                    return .empty()
                }
                let alarmTimeString = String(format: "%d:%02d", hour, minute)
                
                let tasks = validItems.map { item in
                    (content: item.content, orderIndex: item.orderIndex)
                }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let routineSummary = try await self.routineUseCase.createRoutine(
                                name: title,
                                alarmTime: alarmTimeString,
                                tasks: tasks
                            )
                            
                            observer.onNext(routineSummary)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("루틴 생성에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind(to: saveCompletedRelay)
            .disposed(by: disposeBag)
        
        return Output(
            items: itemsRelay.asDriver(),
            focusOnRow: focusRelay.asSignal(),
            title: titleRelay.asDriver(),
            validationFocus: validationFocusRelay.asSignal(),
            saveCompleted: saveCompletedRelay.asSignal(),
            error: errorRelay.asSignal()
        )
    }
}
