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
    struct Input {
        let titleChanged: Observable<String>
//        let alarmTimeButtonTapped: Observable<Void>
//        let saveButtonTapped: Observable<Void>
        
        let addTodoButtonTapped: Observable<Void>
        let itemTextChanged: Observable<(index: Int, text: String)>
        let itemMoved: Observable<(source: Int, destination: Int)>
    }
    
    struct Output {
        let items: Driver<[TodoItem]>
        let focusOnRow: Signal<Int>
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let itemsRelay = BehaviorRelay<[TodoItem]>(value: [TodoItem(text: "")])
        let titleRelay = BehaviorRelay<String>(value: "")
        let focusRelay = PublishRelay<Int>()
        
        input.titleChanged
            .bind(to: titleRelay)
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
                let (source, destination) = move
                let moveItem = newItems.remove(at: source)
                newItems.insert(moveItem, at: destination)
                return newItems
            }
            .bind(to: itemsRelay)
            .disposed(by: disposeBag)
        
        return Output(
            items: itemsRelay.asDriver(),
            focusOnRow: focusRelay.asSignal()
        )
    }
}
