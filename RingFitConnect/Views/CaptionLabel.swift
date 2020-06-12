//
//  CaptionView.swift
//  RingFitConnect
//
//  Created by Watanabe Toshinori on 2020/06/11.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct CaptionLabel: View {

    var systemName: String

    var label: String

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: systemName)
                .foregroundColor(Color("SymbolColor"))
                .font(.caption)

            Text(LocalizedStringKey(label))
                .foregroundColor(Color("SymbolColor"))
                .font(.caption)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
        }
    }

}
