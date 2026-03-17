//
//  TimePickerView.swift
//  MOUP
//
//  Created by 서동환 on 3/17/26.
//

import UIKit

import SnapKit

final class TimePickerView: UIView {
    
    // MARK: - Properties
    
    /// 기기 설정이 12시간제인지 여부
    private let is12Hour: Bool = {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)
        return format?.contains("a") == true
    }()
    
    private var ampmStrings: [String] {
        let formatter = DateFormatter.ko12hTimeFormatter
        return [formatter.amSymbol, formatter.pmSymbol]
    }
    
    /// 12시간제: 1...12, 24시간제: 0...23
    private var hours: [Int] { is12Hour ? Array(1...12) : Array(0...23) }
    private let minutes: [Int] = Array(0...59)
    
    /// 컴포넌트 인덱스 (12시간: AM/PM=0, 시=1, 분=2 / 24시간: 시=0, 분=1)
    private var hourComponent: Int { is12Hour ? 1 : 0 }
    private var minuteComponent: Int { is12Hour ? 2 : 1 }
    private var componentCount: Int { is12Hour ? 3 : 2 }
    
    /// 24시간 기준(0...23)으로 내부 관리
    private var hour24: Int
    private var selectedMinute: Int
    
    /// 콜백 — (hour24: 0...23, minute: 0...59)
    var onTimeChanged: ((Int, Int) -> Void)?
    
    // MARK: - UI Components
    
    private let pickerView = UIPickerView()
    
    // MARK: - Initializer
    
    /// hour24: 0...23 기준으로 전달
    init(hour24: Int, minute: Int) {
        self.hour24 = hour24
        self.selectedMinute = minute
        super.init(frame: .zero)
        configure()
        
        syncPickerToState(animated: false)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Internal Methods
    
    /// 외부에서 값 갱신 시 호출 (hour24: 0...23)
    func updateSelection(hour24: Int, minute: Int) {
        self.hour24 = hour24
        self.selectedMinute = minute
        syncPickerToState(animated: false)
    }
}

// MARK: - UI Methods

private extension TimePickerView {
    func configure() {
        setStyles()
        setHierarchy()
        setConstraints()
    }
    
    func setStyles() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .clear
    }
    
    func setHierarchy() {
        self.addSubview(pickerView)
    }
    
    func setConstraints() {
        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Conversion Helpers

private extension TimePickerView {
    /// 24시간 → 12시간 변환
    func to12Hour(_ h24: Int) -> (ampm: Int, hour12: Int) {
        switch h24 {
        case 0:         return (0, 12)       // 오전 12시
        case 1...11:    return (0, h24)      // 오전 1~11시
        case 12:        return (1, 12)       // 오후 12시
        default:        return (1, h24 - 12) // 오후 1~11시
        }
    }
    
    /// 12시간 → 24시간 변환
    func to24Hour(ampm: Int, hour12: Int) -> Int {
        if ampm == 0 { // 오전
            return hour12 == 12 ? 0 : hour12
        } else {        // 오후
            return hour12 == 12 ? 12 : hour12 + 12
        }
    }
    
    /// 내부 상태 → 피커 row 동기화
    func syncPickerToState(animated: Bool) {
        if is12Hour {
            let (ampm, hour12) = to12Hour(hour24)
            pickerView.selectRow(ampm, inComponent: 0, animated: animated)
            if let index = hours.firstIndex(of: hour12) {
                pickerView.selectRow(index, inComponent: hourComponent, animated: animated)
            }
        } else {
            if let index = hours.firstIndex(of: hour24) {
                pickerView.selectRow(index, inComponent: hourComponent, animated: animated)
            }
        }
        pickerView.selectRow(selectedMinute, inComponent: minuteComponent, animated: animated)
    }
    
    /// 피커 선택 → 내부 상태 갱신 후 콜백
    func readPickerAndNotify() {
        if is12Hour {
            let ampm = pickerView.selectedRow(inComponent: 0)
            let hour12 = hours[pickerView.selectedRow(inComponent: hourComponent)]
            hour24 = to24Hour(ampm: ampm, hour12: hour12)
        } else {
            hour24 = hours[pickerView.selectedRow(inComponent: hourComponent)]
        }
        selectedMinute = minutes[pickerView.selectedRow(inComponent: minuteComponent)]
        onTimeChanged?(hour24, selectedMinute)
    }
}

// MARK: - UIPickerViewDataSource

extension TimePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { componentCount }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if is12Hour {
            switch component {
            case 0: return ampmStrings.count  // 오전/오후
            case 1: return hours.count        // 1...12
            case 2: return minutes.count      // 0...59
            default: return 0
            }
        } else {
            switch component {
            case 0: return hours.count        // 0...23
            case 1: return minutes.count      // 0...59
            default: return 0
            }
        }
    }
}

// MARK: - UIPickerViewDelegate

extension TimePickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 44 }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if is12Hour {
            switch component {
            case 0: return 80   // 오전/오후
            case 1: return 80   // 시
            case 2: return 80   // 분
            default: return 0
            }
        } else {
            switch component {
            case 0: return 100  // 시 (0~23)
            case 1: return 100  // 분
            default: return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        if is12Hour {
            switch component {
            case 0: label.text = ampmStrings[row]
            case 1: label.text = "\(hours[row])"
            case 2: label.text = String(format: "%02d", minutes[row])
            default: break
            }
        } else {
            switch component {
            case 0: label.text = String(format: "%02d", hours[row])
            case 1: label.text = String(format: "%02d", minutes[row])
            default: break
            }
        }
        
        label.font = .headBold(20)
        label.textColor = .gray900
        label.textAlignment = .center
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        readPickerAndNotify()
    }
}

// MARK: - SwiftUI Convert

import SwiftUI

/// `TimePickerView`의 SwiftUI 래퍼
///
/// 기기의 시간 설정에 따라 **12시간제**(오전/오후 · 시 · 분) 또는
/// **24시간제**(시 · 분)로 자동 전환됩니다.
/// 값은 항상 **24시간 기준**(hour24: 0...23, minute: 0...59)으로 바인딩합니다.
///
/// **사용 예시**
/// ```swift
/// @State private var hour24: Int = 9
/// @State private var minute: Int = 30
///
/// var body: some View {
///     TimePickerViewSU(
///         hour24: $hour24,
///         minute: $minute
///     )
///     .frame(height: 180)
/// }
/// ```
struct TimePickerViewSU: UIViewRepresentable {
    @Binding var hour24: Int
    @Binding var minute: Int
    
    func makeUIView(context: Context) -> TimePickerView {
        let picker = TimePickerView(hour24: hour24, minute: minute)
        picker.onTimeChanged = { h, m in
            hour24 = h
            minute = m
        }
        return picker
    }
    
    func updateUIView(_ uiView: TimePickerView, context: Context) {
        uiView.updateSelection(hour24: hour24, minute: minute)
    }
}
