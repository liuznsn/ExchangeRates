//
//  CurrencyViewModelTests.swift
//  ExchangeRatesTests
//
//  Created by Leo on 2020/9/8.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import RxCocoa

class CurrencyViewModelTests: XCTestCase {

    var viewModel:CurrencyViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var pickerView: UIPickerView!
   
    override func setUpWithError() throws {
        
        self.viewModel = CurrencyViewModel()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        self.viewModel = nil
        self.scheduler = nil
        self.disposeBag = nil
    }

    func testExample() throws {
    
    }
    
    func testOutputSelectCurrency() throws {
       let selectItems = scheduler.createObserver([SelectCurrencyData].self)
               
       self.viewModel
        .outputs
        .currencySelect
        .bind(to: selectItems)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
    }
    
    func testOutputCurrencyRate() throws {
        let rates = scheduler.createObserver([CurrencyData].self)
            
            viewModel.outputs.currencyRate
                .bind(to: rates)
                .disposed(by: disposeBag)
            
            scheduler.createColdObservable([.next(5, "USD")])
                .bind(to: viewModel.inputs.source)
            .disposed(by: disposeBag)
            
            scheduler.createColdObservable([.next(15, "100")])
                .bind(to: viewModel.inputs.amount)
                .disposed(by: disposeBag)
            
            scheduler.start()
            
        let usdCurrencyData = rates.events[1].value.element?.filter{ $0.name ==  "USDUSD"}
            XCTAssertEqual(usdCurrencyData![0].rate, 100.0)

           
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
