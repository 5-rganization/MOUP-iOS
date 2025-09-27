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

struct TodoItem: Hashable {
    let id: UUID = UUID()
    var text: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
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
    }
    
    // MARK: - Output
    
    struct Output {
        let items: Driver<[TodoItem]>
        let focusOnRow: Signal<Int>
        
        let title: Driver<String>
        let validationFocus: Signal<ValidationFocusTarget>
        let saveCompleted: Signal<Routine>
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let itemsRelay = BehaviorRelay<[TodoItem]>(value: [TodoItem(text: "")])
        let titleRelay = BehaviorRelay<String>(value: "")
        let alarmTimeRelay = BehaviorRelay<DateComponents?>(value: nil)
        
        let focusRelay = PublishRelay<Int>()
        let validationFocusRelay = PublishRelay<ValidationFocusTarget>()
        let saveCompletedRelay = PublishRelay<Routine>()
        
        input.titleChanged
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
        
        input.alarmTimeChanged
            .bind(to: alarmTimeRelay)
            .disposed(by: disposeBag)
        
        input.addTodoButtonTapped
            .withLatestFrom(itemsRelay)
            .subscribe(onNext: { currentItems in                
                var newItems = currentItems
                
                if let lastItem = newItems.last, lastItem.text.isEmpty {
                    focusRelay.accept(newItems.count - 1)
                    return
                }
                
                newItems.append(TodoItem(text: ""))
                itemsRelay.accept(newItems)
                focusRelay.accept(newItems.count - 1)
            })
            .disposed(by: disposeBag)
        
        input.itemTextChanged
            .withLatestFrom(itemsRelay) { (change, currentItems) -> [TodoItem] in
                var newItems = currentItems
                let (index, text) = change
                guard newItems.indices.contains(index) else { return newItems }
                
                newItems[index].text = text
                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.itemMoved
            .withLatestFrom(itemsRelay) { (move, currentItems) -> [TodoItem] in
                var newItems = currentItems
                let (sourceIndex, destinationIndex) = move
                
                guard newItems.indices.contains(sourceIndex),
                      (0...newItems.count).contains(destinationIndex) else { return newItems }
                
                let itemToMove = newItems.remove(at: sourceIndex)
                newItems.insert(itemToMove, at: destinationIndex)
                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.itemDeleted
            .withLatestFrom(itemsRelay) { (indexToDelete, currentItems) -> [TodoItem] in
                var newItems = currentItems
                guard newItems.indices.contains(indexToDelete) else { return newItems }
                
                newItems.remove(at: indexToDelete)
                
                if newItems.isEmpty {
                    newItems.append(TodoItem(text: ""))
                }
                
                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withLatestFrom(Observable.combineLatest(
                titleRelay,
                alarmTimeRelay,
                itemsRelay
            ))
            .subscribe(onNext: { title, alarmTime, items in
                if title.isEmpty {
                    validationFocusRelay.accept(.title)
                    return
                }
                
                if alarmTime == nil {
                    validationFocusRelay.accept(.alarmTime)
                    return
                }
                
                let validItems = items.filter { !$0.text.isBlank }
                if validItems.isEmpty {
                    validationFocusRelay.accept(.firstTodoItem)
                    return
                }
                
                let newRoutine = Routine(
                    id: UUID(), title: title, alarmTime: alarmTime, items: validItems
                )
                
                // TODO: usecase 호출
                print("저장 성공: \(newRoutine)")
                saveCompletedRelay.accept(newRoutine)
            })
            .disposed(by: disposeBag)
        
        return Output(
            items: itemsRelay.asDriver(),
            focusOnRow: focusRelay.asSignal(),
            title: titleRelay.asDriver(),
            validationFocus: validationFocusRelay.asSignal(),
            saveCompleted: saveCompletedRelay.asSignal()
        )
    }
}
