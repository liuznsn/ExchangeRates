//
//  Live.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/7.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation

// MARK: - Live
struct Live: Codable {
    let success: Bool
   // let terms, privacy: String
    let timestamp: Double
    let source: String
    let quotes: [String: Double]

}
