//
//  CustomHeightTabBar.swift
//  MOUP
//
//  Created by 서동환 on 12/16/25.
//

import UIKit

final class CustomHeightTabBar: UITabBar {
    private let customHeight: CGFloat = 64
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = customHeight + (window?.safeAreaInsets.bottom ?? 0)
        return sizeThatFits
    }
}
