//
//  ViewController.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/4.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import UIKit


import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController,UITableViewDelegate {

    private let disposeBag = DisposeBag()
    private var tableView: UITableView!
    private var pickerView: UIPickerView!
    private var textfield: UITextField!
    private var datasource =  [CurrencySectionViewModel]()
    private let viewModel = CurrencyViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCurrencyData>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "reuseIdentifier")
            cell.textLabel?.text = "\(item.name): \(item.rate)"
            return cell
        })
        
        self.viewModel
            .outputs
            .currencySelect
            .bind(to: pickerView.rx.itemTitles){ _, element in  "\(element.shortName): \(element.longName)" }
            .disposed(by: disposeBag)
    
        self.viewModel
            .outputs
            .currencyRate
            .map{[SectionOfCurrencyData(header: "Currency", items: $0)]}
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.pickerView.rx
            .modelSelected(SelectCurrencyData.self)
            .map{ $0[0].shortName }
            .bind(to: self.viewModel.inputs.source)
            .disposed(by: disposeBag)
           
        self.textfield.rx.text
            .orEmpty
            .bind(to: self.viewModel.inputs.amount)
            .disposed(by: disposeBag)
    }


}

extension ViewController {
    func configureTableView() {
        self.tableView = UITableView(frame: CGRect.zero)
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.tableView.rx.setDelegate(self)
                   .disposed(by: disposeBag)
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.keyboardDismissMode = .onDrag
        
        self.pickerView = UIPickerView(frame: CGRect.zero)
        self.view.addSubview(pickerView)
        self.pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.pickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        self.pickerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.pickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.pickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        self.textfield = UITextField(frame: CGRect.zero)
        self.textfield.keyboardType = .numberPad
        self.textfield.translatesAutoresizingMaskIntoConstraints = false
        self.textfield.text = "100"
        self.textfield.textAlignment = .right
        self.textfield.font = UIFont.systemFont(ofSize: 30)
        self.textfield.backgroundColor = .gray
        self.view.addSubview(self.textfield)
        self.textfield.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        self.textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.textfield.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        self.textfield.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-30).isActive = true
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource[section].header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let item = datasource[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }
    
}
