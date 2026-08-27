//
//  WorkerSummary.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

struct WorkerSummary: Codable, Equatable {
    let id: Int
    let workerBasedLabelColorStr: String?
    let ownerBasedLabelColorStr: String?
    let nickname: String
    let profileImg: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "workerId"
        case workerBasedLabelColorStr = "workerBasedLabelColor"
        case ownerBasedLabelColorStr = "ownerBasedLabelColor"
        case nickname
        case profileImg
    }
}

