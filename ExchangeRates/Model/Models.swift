//
//  Models.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/8.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation
import RxDataSources

public struct CurrencyData {
  var name: String
  var rate: Double
}

public struct SelectCurrencyData {
  var shortName: String
  var longName: String
}

struct SectionOfCurrencyData{
  var header: String
  var items: [Item]
}

extension SectionOfCurrencyData: SectionModelType {
  typealias Item = CurrencyData

   init(original: SectionOfCurrencyData, items: [Item]) {
    self = original
    self.items = items
  }
}
