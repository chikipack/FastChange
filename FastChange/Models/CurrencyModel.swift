//
//  CurrencyModel.swift
//  FastChange
//
//  Created by Victor Alejandro Anaya Martinez on 14/07/25.
//

import Foundation

struct Currency: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let country: String
    let symbol: String?

    var id: String { code }
}

func loadCurrencies() -> [Currency] {
    guard let url = Bundle.main.url(forResource: "CurrencyCodes", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
        return []
    }
    return currencies
}
