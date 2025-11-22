//
//  EditRoutineViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/16/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EditRoutineViewModel {

    // MARK: - Input

    struct Input {
        let viewDidLoad: Observable<Void>
        let titleChanged: Observable<String>
        let alarmTimeChanged: Observable<DateComponents?>
        let editButtonTapped: Observable<Void>

        let addTodoButtonTapped: Observable<Void>
        let itemTextChanged: Observable<(index: Int, text: String)>
        let itemMoved: Observable<(source: Int, destination: Int)>
        let itemDeleted: Observable<Int>
    }

    // MARK: - Output

    struct Output {
        let items: Driver<[RoutineTaskItem]>
        let focusOnRow: Signal<Int>

        let title: Driver<String>
        let alarmTime: Driver<DateComponents?>
        let validationFocus: Signal<ValidationFocusTarget>
        let editCompleted: Signal<RoutineSummary>
        let error: Signal<String>
        let isLoading: Driver<Bool>
        let fetchError: Signal<String>
    }

    // MARK: - Properties

    private let routineId: Int
    private let routineUseCase: RoutineUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init(
        routineId: Int,
        routineUseCase: RoutineUseCaseProtocol
    ) {
        self.routineId = routineId
        self.routineUseCase = routineUseCase
    }

    // MARK: - Transform

    func transform(input: Input) -> Output {
        let itemsRelay = BehaviorRelay<[RoutineTaskItem]>(value: [])
        let titleRelay = BehaviorRelay<String>(value: "")
        let alarmTimeRelay = BehaviorRelay<DateComponents?>(value: nil)
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let focusRelay = PublishRelay<Int>()
        let validationFocusRelay = PublishRelay<ValidationFocusTarget>()
        let saveCompletedRelay = PublishRelay<RoutineSummary>()
        let errorRelay = PublishRelay<String>()
        let fetchErrorRelay = PublishRelay<String>()
        
        input.viewDidLoad
            .do(onNext: { _ in
                loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<RoutineDetail> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let routineDetail = try await self.routineUseCase.fetchRoutineDetail(
                                routineId: self.routineId
                            )
                            observer.onNext(routineDetail)
                            observer.onCompleted()
                        } catch {
                            fetchErrorRelay.accept("루틴 정보를 불러올 수 없습니다.")
                            observer.onError(error)
                        }
                        loadingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { routineDetail in
                titleRelay.accept(routineDetail.summary.routineName)
                
                if let alarmTime = routineDetail.summary.alarmTime {
                    let components = alarmTime.split(separator: ":")
                    if components.count == 2,
                       let hour = Int(components[0]),
                       let minute = Int(components[1]) {
                        var dateComponents = DateComponents()
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        alarmTimeRelay.accept(dateComponents)
                    }
                }
                
                let tasks = routineDetail.tasks.isEmpty
                    ? [RoutineTaskItem(content: "", orderIndex: 0)]
                    : routineDetail.tasks
                itemsRelay.accept(tasks)
            })
            .disposed(by: disposeBag)

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

        input.editButtonTapped
            .withLatestFrom(Observable.combineLatest(titleRelay, alarmTimeRelay, itemsRelay))
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

                guard let hour = alarmTime.hour, let minute = alarmTime.minute else {
                    validationFocusRelay.accept(.alarmTime)
                    return .empty()
                }
                let alarmTimeString = String(format: "%02d:%02d", hour, minute)

                let tasks = validItems.map { item in
                    (content: item.content, orderIndex: item.orderIndex)
                }

                return Observable.create { observer in
                    Task {
                        do {
                            try await self.routineUseCase.updateRoutine(
                                routineId: self.routineId,
                                name: title,
                                alarmTime: alarmTimeString,
                                tasks: tasks
                            )

                            let updatedRoutine = RoutineSummary(
                                routineId: self.routineId,
                                routineName: title,
                                alarmTime: alarmTimeString
                            )
                            observer.onNext(updatedRoutine)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("루틴 업데이트에 실패했습니다.")
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
            alarmTime: alarmTimeRelay.asDriver(),
            validationFocus: validationFocusRelay.asSignal(),
            editCompleted: saveCompletedRelay.asSignal(),
            error: errorRelay.asSignal(),
            isLoading: loadingRelay.asDriver(),
            fetchError: fetchErrorRelay.asSignal()
        )
    }
}
