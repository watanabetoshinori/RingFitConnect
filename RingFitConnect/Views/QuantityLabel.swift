//
//  QuantityView.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct QuantityLabel: View {

    var quantity: String

    var unit: String

    var body: some View {
        HStack(alignment: .center) {
            (
                Text(quantity)
                    .foregroundColor(.primary)
                    .font(.title)
                    .fontWeight(.medium)
                + Text(" " + unit)
                    .foregroundColor(.secondary)
                    .font(.callout))
                    .fontWeight(.heavy
            )
            .scaleEffect(0.8)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

}
