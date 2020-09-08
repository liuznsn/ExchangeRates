//
//  List.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/7.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation

// MARK: - Live
struct List: Codable {
    let success: Bool
    let terms, privacy: String
    let currencies: [String: String]
}


