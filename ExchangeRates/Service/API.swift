//
//  API.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/8.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


public class API:CurrencylayerAPI {
    
    static let sharedAPI = API()
    
    public func currencies(source: String) -> Single<[CurrencyData]> {
        
        let defaults = UserDefaults.standard
        let nowTimeStamp = defaults.double(forKey: "nowTimeStamp")
      
    
        if let liveObj = defaults.object(forKey: "live_\(source)") as? Data {
            let decoder = JSONDecoder()
            if let live = try? decoder.decode(Live.self, from: liveObj) {
                if((Date().timeIntervalSince1970 - nowTimeStamp) < 1300) { // 30 mins
                    return Single.just(live.quotes.compactMap { (key, value) -> CurrencyData in return CurrencyData(name: key, rate: value)})
                }
            }
        }
        
        
       return CurrencyProvider.rx.request(Currencylayer.Live(source: source))
            .map(Live.self)
            .do(onSuccess: { live in
        
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(live) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "live_\(source)")
                    
                    defaults.set(Date().timeIntervalSince1970, forKey: "nowTimeStamp")
                }
            })
            .observeOn(MainScheduler.instance)
            .flatMap { live -> Single<[CurrencyData]> in
                return Single.just(live.quotes.compactMap { (key, value) -> CurrencyData in return CurrencyData(name: key, rate: value)})
            }
    }
    
    public func currencySelections() -> Single<[SelectCurrencyData]> {
       return CurrencyProvider.rx.request(Currencylayer.List)
            .map(List.self)
            .observeOn(MainScheduler.instance)
            .flatMap { list -> Single<[SelectCurrencyData]> in
                return Single.just(list.currencies.compactMap { (key, value) -> SelectCurrencyData in return SelectCurrencyData(shortName: key, longName: value)})
            }
    }

}

public protocol CurrencylayerAPI {
    func currencies(source:String) -> Single<[CurrencyData]>
    func currencySelections() -> Single<[SelectCurrencyData]>
}
