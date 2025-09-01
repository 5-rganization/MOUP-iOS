//
//  Bundle+Extension.swift
//  MOUP
//
//  Created by 송규섭 on 8/26/25.
//

import Foundation

extension Bundle {
    var googleClientID: String {
        object(forInfoDictionaryKey: "GIDClientID") as? String ?? ""
    }

    var googleRedirectURI: String? {
        if let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
           let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String],
           let reversedClientID = urlSchemes.first {
            return "\(reversedClientID):/oauth2redirect"
        }
        return nil
    }
}
