//
//  Font+Extension.swift
//  MOUP
//
//  Created by 서동환 on 3/5/26.
//

import SwiftUI

extension Font {
    static func headBold(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Bold", size: size)
    }
    
    static func bodyMedium(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Medium", size: size)
    }
    
    static func buttonSemibold(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-SemiBold", size: size)
    }
    
    static func fieldsRegular(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Regular", size: size)
    }
}
