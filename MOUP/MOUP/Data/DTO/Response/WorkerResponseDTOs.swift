//
//  WorkerSummaryInfo.swift
//  MOUP
//
//  Created by 서동환 on 10/28/25.
//

struct WorkerSummaryResponseDTO: Decodable {
    let workerId: Int
    let workerBasedLabelColor: String
    let ownerBasedLabelColor: String
    let nickname: String
    let profileImg: String?
}
