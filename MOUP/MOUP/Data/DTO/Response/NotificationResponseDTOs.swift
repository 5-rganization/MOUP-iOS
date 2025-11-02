//
//  NotificationResponseDTOs.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

struct NotificationResponseDTO: Decodable {
    let id: Int
    let senderId: Int?
    let receiverId: Int?
    let title: String
    let content: String
    let sentAt: String
    let readAt: String?
}
