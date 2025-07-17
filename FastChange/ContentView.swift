//
//  ContentView.swift
//  FastChange
//
//  Created by Victor Alejandro Anaya Martinez on 07/07/25.
//

import SwiftUI
import Foundation

struct ExchangeRateResponse: Decodable {
    let base_code: String
    let conversion_rates: [String: Decimal]
}

struct ContentView: View {
    let currencies: [Currency]
    let matchedCurrency: Currency?
    
    @State private var currentCurrencySelected: Currency? = nil
    @State private var shouldNavigate = false

    init() {
        self.currencies = loadCurrencies()
        let localeCurrencyCode = Locale.current.currency?.identifier
        self.matchedCurrency = currencies.first { $0.code == localeCurrencyCode }
    }
    
    var body: some View {
        NavigationStack {
            
            List(currencies) { currency in
                NavigationLink {
                    ConversorView(myCurrency: currency)
                        .navigationTitle("")
                } label: {
                    HStack {
                        Text("\(currency.country) - \(currency.code)")
                        if !currency.symbol!.isEmpty {
                            Text(currency.symbol!)
                                .fontWeight(.bold)
                        }
                    }
                }
                
            }
            .navigationTitle("Choose your currency")
            .navigationDestination(isPresented: $shouldNavigate) {
                if let selected = currentCurrencySelected {
                    ConversorView(myCurrency: selected)
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            if currentCurrencySelected == nil {
                if let localeCurrencyCode = Locale.current.currency?.identifier,
                   let matchedCurrency = currencies.first(where: { $0.code == localeCurrencyCode }) {
                    currentCurrencySelected = matchedCurrency
                    shouldNavigate = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
