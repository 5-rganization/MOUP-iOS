//
//  Coordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
