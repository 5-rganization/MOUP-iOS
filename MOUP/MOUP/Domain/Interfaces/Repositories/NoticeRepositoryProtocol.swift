//
//  NoticeRepositoryProtocol.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

protocol NoticeRepositoryProtocol: AnyObject {
    func fetchNotices() async throws -> [Notice]
}
