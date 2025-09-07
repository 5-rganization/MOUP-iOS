//
//  FilterWorkplace.swift
//  MOUP
//
//  Created by 서동환 on 8/16/25.
//

/// 근무지/매장 필터 Entity
/// - `workplaceId`: 근무지/매장 ID `Int64`
/// - `workplaceName`: 근무자/매장 이름 `String`
///   - 예시: `"세븐일레븐 동탄제일점"`
/// - `isShared`: 공유 여부 `Bool`
struct FilterWorkplace {
    let workplaceId: Int64
    let workplaceName: String
    let isShared: Bool
}
