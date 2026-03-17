//
//  DatePickerView.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import UIKit

import SnapKit

final class DatePickerView: UIView {
    
    // MARK: - Properties
    
    private let calendar = Calendar(identifier: .gregorian)
    private let years = Array(CalendarRange.startYear...CalendarRange.endYear)
    private let months = Array(1...12)
    private var days: [Int] = Array(1...31)
    
    private var selectedYear: Int
    private var selectedMonth: Int
    private var selectedDay: Int
    
    var onDateChanged: ((Int, Int, Int) -> Void)?
    
    // MARK: - UI Components
    
    private let pickerView = UIPickerView()
    
    // MARK: - Initializer
    
    init(year: Int, month: Int, day: Int) {
        self.selectedYear = year
        self.selectedMonth = month
        self.selectedDay = day
        super.init(frame: .zero)
        configure()
        
        rebuildDays()
        updateSelection(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    
    func updateSelection(year: Int, month: Int, day: Int) {
        selectedYear = year
        selectedMonth = month
        selectedDay = day
        rebuildDays()
        
        if let yearIndex = years.firstIndex(of: year) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(month - 1, inComponent: 1, animated: false)
        let dayRow = max(0, min(days.count - 1, day - 1))
        pickerView.selectRow(dayRow, inComponent: 2, animated: false)
    }
}

// MARK: - UI Methods

private extension DatePickerView {
    func configure() {
        setStyles()
        setHierachy()
        setConstraints()
    }
    
    func setStyles() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .clear
    }
    
    func setHierachy() {
        self.addSubview(pickerView)
    }
    
    func setConstraints() {
        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Private Methods

private extension DatePickerView {
    func rebuildDays() {
        if let date = calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)),
           let range = calendar.range(of: .day, in: .month, for: date) {
            days = Array(range)
        } else {
            days = Array(1...31)
        }
    }
    
    func clampDay() {
        let maxDay = days.last ?? 31
        if selectedDay > maxDay {
            selectedDay = maxDay
        }
        pickerView.reloadComponent(2)
        pickerView.selectRow(selectedDay - 1, inComponent: 2, animated: true)
        onDateChanged?(selectedYear, selectedMonth, selectedDay)
    }
}

// MARK: - UIPickerViewDataSource
extension DatePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1: return months.count
        case 2: return days.count
        default: return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension DatePickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 44 }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 110
        case 1: return 80
        case 2: return 80
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        switch component {
        case 0: label.text = "\(years[row])"
        case 1: label.text = "\(months[row])"
        case 2: label.text = "\(days[row])"
        default: break
        }
        
        label.font = .headBold(20)
        label.textColor = .gray900
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedYear = years[row]
            rebuildDays()
            clampDay()
        case 1:
            selectedMonth = months[row]
            rebuildDays()
            clampDay()
        case 2:
            selectedDay = days[row]
            onDateChanged?(selectedYear, selectedMonth, selectedDay)
        default:
            break
        }
    }
}


// MARK: - SwiftUI Convert

import SwiftUI

struct YearMonthDayPickerViewSU: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int
    
    func makeUIView(context: Context) -> DatePickerView {
        let picker = DatePickerView(
            year: selectedYear,
            month: selectedMonth,
            day: selectedDay
        )
        picker.onDateChanged = { year, month, day in
            selectedYear = year
            selectedMonth = month
            selectedDay = day
        }
        return picker
    }
    
    func updateUIView(_ uiView: DatePickerView, context: Context) {
        uiView.updateSelection(year: selectedYear, month: selectedMonth, day: selectedDay)
    }
}
