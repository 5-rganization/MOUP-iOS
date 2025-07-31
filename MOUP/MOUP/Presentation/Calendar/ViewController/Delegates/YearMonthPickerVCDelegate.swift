//
//  YearMonthPickerVCDelegate.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

protocol YearMonthPickerVCDelegate: AnyObject {
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int)
}
