//
//  CalendarCoordinatorProtocol.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

protocol CalendarCoordinatorProtocol: Coordinator {
    func showYearMonthPicker(currYear: Int, currMonth: Int, delegate: YearMonthPickerVCDelegate?)
}
