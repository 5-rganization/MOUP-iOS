//
//  RxASAuthorizationControllerDelegateProxy.swift
//  Routory
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
    var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        RxASAuthorizationControllerDelegateProxy.proxy(for: base)
    }
    
    var didCompleteWithAuthorization: Observable<ASAuthorizationCredential> {
        return delegate
            .methodInvoked(#selector(ASAuthorizationControllerDelegate.authorizationController(controller:didCompleteWithAuthorization:)))
            .map { parameters in
                return (parameters[1] as! ASAuthorization).credential
            }
    }
}
