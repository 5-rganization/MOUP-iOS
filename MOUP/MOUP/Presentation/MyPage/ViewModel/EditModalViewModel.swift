//
//  EditModalViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 8/31/25.
//

import RxSwift
import RxCocoa

enum ValidationViewState: Equatable {
    case empty(placeholder: String)
    case valid(message: String)
    case invalid(message: String)
}

final class EditModalViewModel {
    
    // MARK: - Input
    
    struct Input {
        let text: Observable<String>
        let saveTap: Observable<Void>
    }
    
    // MARK: - Output
    
    struct Output {
        let viewState: Driver<ValidationViewState>
        let isSaveEnabled: Driver<Bool>
        let saveSuccess: Signal<String>
        let saveError: Signal<String>
    }
    
    // MARK: - Properties
    
    private let initialMessage = "특수문자 제외 8자 이하로 입력해주세요"
    private let userUseCase: UserUseCaseProtocol
    
    // MARK: - Initializer
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let text = input.text
            .share(replay: 1, scope: .whileConnected)
        
        let validation = text
            .map { [weak self] text -> (
                isEmpty: Bool,
                isValid: Bool,
                message: String
            ) in
                guard let self else { return (true, false, "") }
                
                if text.isEmpty {
                    return (true, false, self.initialMessage)
                }
                
                let (ok, msg) = self.validate(text)
                return (false, ok, msg)
            }
            .share(replay: 1, scope: .whileConnected)
        
        let viewState = validation
            .map { tuple -> ValidationViewState in
                if tuple.isEmpty {
                    return .empty(placeholder: tuple.message)
                }
                return tuple.isValid ?
                    .valid(message: tuple.message)
                : .invalid(message: tuple.message)
            }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let isSaveEnabled = validation
            .map { !$0.isEmpty && $0.isValid }
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())
        
        let saveResult = input.saveTap
            .withLatestFrom(Observable.combineLatest(text, validation))
            .filter { _, validation in
                validation.isValid && !validation.isEmpty
            }
            .map { nickname, _ in nickname }
            .flatMapLatest { [weak self] nickname -> Observable<Result<String, Error>> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let updatedNickname = try await self.userUseCase.updateNickname(nickname)
                            observer.onNext(.success(updatedNickname))
                            observer.onCompleted()
                        } catch {
                            observer.onNext(.failure(error))
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .share(replay: 1, scope: .whileConnected)
        
        let saveSuccess = saveResult
            .compactMap { result -> String? in
                if case .success(let nickname) = result {
                    return nickname
                }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let saveError = saveResult
            .compactMap { result -> String? in
                if case .failure(let error) = result {
                    return error.localizedDescription
                }
                return nil
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            viewState: viewState,
            isSaveEnabled: isSaveEnabled,
            saveSuccess: saveSuccess,
            saveError: saveError
        )
    }
    
    private func validate(_ nickname: String) -> (Bool, String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return (false, "한글, 영문 또는 숫자만 사용하여 8자 이하로 입력해주세요")
        }

        if nickname.contains(where: { $0.isWhitespace }) {
            return (false, "공백은 사용할 수 없어요")
        }

        if trimmed.range(of: "^[ㄱ-ㅎ]+$", options: .regularExpression) != nil {
            return (false, "자음만 사용할 수 없어요")
        }

        if trimmed.range(of: "^[ㅏ-ㅣ]+$", options: .regularExpression) != nil {
            return (false, "모음만 사용할 수 없어요")
        }

        if trimmed.range(of: "[ㄱ-ㅎㅏ-ㅣ]", options: .regularExpression) != nil {
            return (false, "정확한 글자를 입력해주세요")
        }

        let containsHangul = trimmed.range(of: "[가-힣]", options: .regularExpression) != nil
        let containsAlphabet = trimmed.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        if containsHangul && containsAlphabet {
            return (false, "한글 또는 영문만 사용할 수 있어요")
        }

        if trimmed.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil {
            return (false, "특수문자는 사용할 수 없어요")
        }

        if trimmed.count > 8 {
            return (false, "8자 이하로 입력해주세요")
        }

        return (true, "사용 가능한 닉네임이에요!")
    }
}
