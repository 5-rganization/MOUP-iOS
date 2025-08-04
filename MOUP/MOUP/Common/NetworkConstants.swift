//
//  NetworkConstants.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation

enum NetworkConstants {
    static let baseURL = Bundle.main.infoDictionary?["BaseURL"] as? String ?? ""
}
