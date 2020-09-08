//
//  CurrencyViewModel.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/8.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

public protocol CurrencyViewModelInputs {
    
    var amount:PublishSubject<String>{ get}
    var source:PublishSubject<String>{ get }
   
}

public protocol CurrencyViewModelOutputs {
    
    var currencyRate: BehaviorRelay<[CurrencyData]> { get }
    var currencySelect: BehaviorRelay<[SelectCurrencyData]> { get }
    
}

public protocol CurrencyViewModelType {
    var inputs: CurrencyViewModelInputs { get  }
    var outputs: CurrencyViewModelOutputs { get }
}

public class CurrencyViewModel: CurrencyViewModelType, CurrencyViewModelInputs, CurrencyViewModelOutputs {
   
    public init() {
        self.amount = PublishSubject<String>()
        self.source = PublishSubject<String>()
       
    
        self.currencyRate = BehaviorRelay(value: [])
        self.currencySelect = BehaviorRelay(value: [])
        
        API.sharedAPI.currencySelections()
        .asObservable()
        .subscribe(onNext: { selections in
            self.currencySelect.accept(selections)
        }).disposed(by: disposeBag)
        
        
        Observable.combineLatest(self.amount,self.source)
            .subscribe(onNext: { amount, source in
                    API.sharedAPI.currencies(source:source)
                       .asObservable()
                       .subscribe(onNext: { data in
                       
                        var result = [CurrencyData]()
                        
                        if let value = Double(amount) {
                            data.forEach{
                                let data1 = CurrencyData(name: $0.name, rate: $0.rate * value )
                                result.append(data1)
                            }
                            self.currencyRate.accept(result)
                        }
                        
                        
                       }, onError: { error in
                        
                        self.currencyRate.accept([])
                        
                       }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    public var amount: PublishSubject<String>
    public var source: PublishSubject<String>
    public var currencyRate: BehaviorRelay<[CurrencyData]>
    public var currencySelect: BehaviorRelay<[SelectCurrencyData]>
    public var inputs: CurrencyViewModelInputs { return self }
    public var outputs: CurrencyViewModelOutputs { return self }
     
}

public struct CurrencySectionViewModel {
    let header: String
    let items: [CurrencyCellViewModel]
}

public struct CurrencyCellViewModel {
    let title: String
    let subtitle: String
}


extension PrimitiveSequence where Trait == SingleTrait {
    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
        return self.asObservable().asMaybe()
    }
    
    public func asCompletable() -> PrimitiveSequence<CompletableTrait, Never> {
        return self.asObservable().flatMap { _ in Observable<Never>.empty() }.asCompletable()
    }
}

extension PrimitiveSequence where Trait == CompletableTrait, Element == Swift.Never {
    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
        return self.asObservable().asMaybe()
    }
}
