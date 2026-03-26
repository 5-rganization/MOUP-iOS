//
//  UIApplication+Extension.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

extension UIApplication {
    static var safeAreaBottom: CGFloat {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
