//
//  ConversorView.swift
//  FastChange
//
//  Created by Victor Alejandro Anaya Martinez on 14/07/25.
//

import SwiftUI

@MainActor
class RatesViewModel: ObservableObject {
    var currencyRates: [String: Decimal] = [:]
    @Published var currencyRate: Decimal?

    func fetchCurrencyRates(for code:String) async {
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/f70baf83f68f0097c265aa4f/latest/\(code)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            self.currencyRates = response.conversion_rates
            #if DEBUG
            print("currency rates fetched!")
            #endif
        } catch {
            #if DEBUG
            print("Error: \(error)")
            #endif
            
        }
    }
    
    func findCurrencyRate(for code:String) -> Void {
        currencyRate = currencyRates[code]
    }
}

struct ConversorView: View {
    let myCurrency: Currency
    let currencies: [Currency] = loadCurrencies()
    let viewModel = RatesViewModel()
    
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = loadCurrencies().first?.code ?? ""
    @State private var selectedCurrency: Currency = loadCurrencies().first!
    @State private var totalAmount: Int = 0
    @State private var tenThousands: Int = 0
    @State private var thousands: Int = 0
    @State private var hundreds: Int = 0
    @State private var tens: Int = 0
    @State private var ones: Int = 0
    
    var totalEnteredAmount: Int {
        tenThousands * 10_000 +
        thousands * 1_000 +
        hundreds * 100 +
        tens * 10 +
        ones
    }
    
    var foreignToMyCurrency: Decimal {
        return Decimal(totalEnteredAmount) / (viewModel.currencyRate ?? 1)
    }
    
    var body: some View {
        VStack {
            Text(totalEnteredAmount, format: .currency(code: selectedCurrency.code))
                .font(.system(size: 40,weight: .bold))
            Text(foreignToMyCurrency, format: .currency(code: myCurrency.code))
                .font(.system(size: 30, weight: .bold))
            HStack(alignment: .center){
                Picker(selectedCurrency.code, selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text("\(currency.code) - \(currency.name)").tag(currency as Currency?)
                    }
                }
                .onAppear {
                    if let saved = currencies.first(where: { $0.code == selectedCurrencyCode }) {
                        selectedCurrency = saved
                    } else {
                        selectedCurrency = loadCurrencies().first!
                        selectedCurrencyCode = selectedCurrency.code
                    }
                }
                .onChange(of: selectedCurrency) {
                    selectedCurrencyCode = selectedCurrency.code
                    Task {
                        viewModel.findCurrencyRate(for: selectedCurrency.code)
                    }
                }
                .layoutPriority(1)
                Image(systemName: "arrow.right")
                Text("\(myCurrency.code) ")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            VStack {
                UnitsButtonsView(multiplier: 10000, amount: $tenThousands, localCurrency: selectedCurrency.code)
                UnitsButtonsView(multiplier: 1000, amount: $thousands, localCurrency: selectedCurrency.code)
                UnitsButtonsView(multiplier: 100, amount: $hundreds, localCurrency: selectedCurrency.code)
                UnitsButtonsView(multiplier: 10, amount: $tens, localCurrency: selectedCurrency.code)
                UnitsButtonsView(multiplier: 1, amount: $ones, localCurrency: selectedCurrency.code)
            }
            .padding()
            
            Button("Reset") {
                totalAmount = 0
                tenThousands = 0
                thousands = 0
                hundreds = 0
                tens = 0
                ones = 0
            }
        }
        .navigationTitle("Your Currency: \(myCurrency.code)")
        .onAppear {
            Task {
                if viewModel.currencyRates.isEmpty {
                    await viewModel.fetchCurrencyRates(for: myCurrency.code)
                }
                viewModel.findCurrencyRate(for: selectedCurrency.code)
            }
        }
    }
}

#Preview {
    ConversorView(myCurrency: Currency(code: "MXN", name: "myTest", country: "TST", symbol: "$"))
}
