//
//  HomeRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/26/25.
//

import Foundation

protocol HomeRepositoryProtocol: AnyObject {
    func fetchWorkerHomeData() async throws -> HomeWorkerSummary
    func fetchOwnerHomeData() async throws -> HomeOwnerSummary
}
