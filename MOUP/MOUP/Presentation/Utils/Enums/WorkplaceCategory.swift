//
//  WorkplaceCategory.swift
//  MOUP
//
//  Created by 서동환 on 11/27/25.
//

import UIKit

enum WorkplaceCategory: CaseIterable {
    case restaurant
    case cafe
    case cvs
    case movieTheater
    case others
    
    var serverStr: String {
        switch self {
        case .restaurant:
            return "RESTAURANT"
        case .cafe:
            return "CAFE"
        case .cvs:
            return "CVS"
        case .movieTheater:
            return "MOVIE_THEATER"
        case .others:
            return "OTHERS"
        }
    }
    
    var displayStr: String {
        switch self {
        case .restaurant:
            return "음식점"
        case .cafe:
            return "카페"
        case .cvs:
            return "편의점"
        case .movieTheater:
            return "영화관"
        case .others:
            return "기타"
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .restaurant:
            return .restaurantSelected
        case .cafe:
            return .cafeSelected
        case .cvs:
            return .cvsSelected
        case .movieTheater:
            return .theaterSelected
        case .others:
            return .othersSelected
        }
    }
    
    var unselectedImage: UIImage {
        switch self {
        case .restaurant:
            return .restaurantUnselected
        case .cafe:
            return .cafeUnselected
        case .cvs:
            return .cvsUnselected
        case .movieTheater:
            return .theaterUnselected
        case .others:
            return .othersUnselected
        }
    }
    
    init?(serverStr: String) {
        if let matchedCase = WorkplaceCategory.allCases.first(where: { $0.serverStr == serverStr }) {
            self = matchedCase
        } else {
            return nil
        }
    }
    
    init?(displayStr: String) {
        if let matchedCase = WorkplaceCategory.allCases.first(where: { $0.displayStr == displayStr }) {
            self = matchedCase
        } else {
            return nil
        }
    }
}
