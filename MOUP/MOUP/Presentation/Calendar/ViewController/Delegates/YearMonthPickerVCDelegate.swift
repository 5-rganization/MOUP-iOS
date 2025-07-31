//
//  YearMonthPickerVCDelegate.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

/// `YearMonthPickerViewController`의 데이터를 `CalendarViewController`로 넘겨주는 Delegate
protocol YearMonthPickerVCDelegate: AnyObject {
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int)
}
