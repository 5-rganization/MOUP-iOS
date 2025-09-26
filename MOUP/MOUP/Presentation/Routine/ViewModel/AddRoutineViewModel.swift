//
//  AddRoutineViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import Foundation
import RxSwift
import RxCocoa

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
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - State
    
    private let itemsRelay = BehaviorRelay<[TodoItem]>(value: [TodoItem(text: "")])
    private let titleRelay = BehaviorRelay<String>(value: "")
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let focusRelay = PublishRelay<Int>()
        
        input.titleChanged
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
        
        input.addTodoButtonTapped
            .withLatestFrom(itemsRelay)
            .subscribe(onNext: { [weak self] currentItems in
                guard let self else { return }
                
                var newItems = currentItems
                
                if let lastItem = newItems.last, lastItem.text.isEmpty {
                    focusRelay.accept(newItems.count - 1)
                    return
                }
                
                newItems.append(TodoItem(text: ""))
                self.itemsRelay.accept(newItems)
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
        
        return Output(
            items: itemsRelay.asDriver(),
            focusOnRow: focusRelay.asSignal(),
            title: titleRelay.asDriver()
        )
    }
}
