//
//  ContainerView.swift
//  MOUP
//
//  Created by 신영 on 3/5/26.
//

import SwiftUI

struct ContainerView: View {
    let title: String
    let isRequired: Bool
    let rows: [AnyView]

    init(
        title: String,
        isRequired: Bool = false,
        @SectionRowBuilder content: () -> [AnyView]
    ) {
        self.title = title
        self.isRequired = isRequired
        self.rows = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            titleView
            containerBox
        }
        .padding(.horizontal, 16)
    }

    private var titleView: some View {
        HStack(spacing: 0) {
            Text(title)
            if isRequired {
                Text(" *")
                    .foregroundColor(Color.accentColor)
            }
        }
        .font(Font.headBold(18))
        .foregroundColor(Color("Gray900"))
    }

    private var containerBox: some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { index in
                rows[index]
                if index < rows.count - 1 {
                    Divider()
                        .frame(height: 1)
                        .overlay(Color("Gray400"))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Gray400"), lineWidth: 1)
        )
    }
}

@resultBuilder
struct SectionRowBuilder {
    static func buildBlock(_ components: any View...) -> [AnyView] {
        components.map { AnyView($0) }
    }
}
