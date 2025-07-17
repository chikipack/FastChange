//
//  UnitsButtonsView.swift
//  FastChange
//
//  Created by Victor Alejandro Anaya Martinez on 08/07/25.
//

import SwiftUI

struct UnitsButtonsView: View {
    let multiplier: Int
    var amount: Binding<Int>
    var localCurrency: String
    var body: some View {
        HStack {
            Button("-") {
                amount.wrappedValue -= 1
                if amount.wrappedValue < 0 { amount.wrappedValue = 9 }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .font(.system(size: 40))
            .frame(width: 60, height: 60)

            Text(
                amount.wrappedValue == 0 ? multiplier : amount.wrappedValue * multiplier,
                format: .currency(code: localCurrency)
            )
            .font(.largeTitle)
            .foregroundStyle(amount.wrappedValue == 0 ? Color.gray : .black)
            .frame(maxWidth: .infinity, alignment: .center)

            Button("+") {
                amount.wrappedValue += 1
                if amount.wrappedValue > 9 { amount.wrappedValue = 1 }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .font(.system(size: 40))
            .frame(width: 60, height: 60)
        }
        
    }
}

#Preview {
    UnitsButtonsView(multiplier: 1, amount: .constant(0), localCurrency: "JPY")
}
