//
//  RxASAuthorizationControllerDelegateProxy.swift
//  MOUP
//
//  Created by 서동환 on 6/18/25.
//

import Foundation
import AuthenticationServices

import RxCocoa
import RxSwift

extension ASAuthorizationController: @retroactive HasDelegate {}

final class RxASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>, DelegateProxyType, ASAuthorizationControllerDelegate {
    static func registerKnownImplementations() {
        self.register {
            RxASAuthorizationControllerDelegateProxy(parentObject: $0,
                                                     delegateProxy: RxASAuthorizationControllerDelegateProxy.self)
        }
    }
    
    static func currentDelegate(for object: ASAuthorizationController) -> (any ASAuthorizationControllerDelegate)? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: (any ASAuthorizationControllerDelegate)?, to object: ASAuthorizationController) {
        object.delegate = delegate
    }
}

public extension Reactive where Base: ASAuthorizationController {
    private var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        RxASAuthorizationControllerDelegateProxy.proxy(for: base)
    }
    
    /// `ASAuthorizationController`의 인증이 성공했을 때 결과를 `ASAuthorization` 타입으로 방출하는 `Observable`
    private var didCompleteWithAuthorization: Observable<ASAuthorization> {
        return delegate
            .methodInvoked(#selector(ASAuthorizationControllerDelegate.authorizationController(controller:didCompleteWithAuthorization:)))
            .map { parameters in
                return parameters[1] as! ASAuthorization
            }
    }
    
    /// `ASAuthorizationController`의 인증이 실패했을 때 결과를 `Error` 타입으로 방출하는 `Observable`
    private var didCompleteWithError: Observable<Error> {
        return delegate
            .methodInvoked(#selector(ASAuthorizationControllerDelegate.authorizationController(controller:didCompleteWithError:)))
            .map { parameters in
                return parameters[1] as! Error
            }
    }
    
    /// `didCompleteWithAuthorization`, `didCompleteWithError`를 통합하여 `Result` 타입으로 방출하는 `Observable`
     var authorizationResult: Observable<Result<ASAuthorization, Error>> {
         let success = didCompleteWithAuthorization
             .map { Result<ASAuthorization, Error>.success($0) }
         
         let failure = didCompleteWithError
             .map { Result<ASAuthorization, Error>.failure($0) }
         
         return Observable.merge(success, failure)
     }
}
