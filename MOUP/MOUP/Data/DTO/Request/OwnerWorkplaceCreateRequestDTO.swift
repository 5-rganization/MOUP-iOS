//
//  OwnerWorkplaceCreateRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

struct OwnerWorkplaceCreateRequestDTO: Encodable {
    let workplaceName: String
    let categoryName: String
    let ownerBasedLabelColor: String
    
    let address: String? = nil
    let latitude: Double? = nil
    let longitude: Double? = nil
}
