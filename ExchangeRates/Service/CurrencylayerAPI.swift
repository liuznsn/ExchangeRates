//
//  CurrencylayerAPI.swift
//  ExchangeRates
//
//  Created by Leo on 2020/9/7.
//  Copyright © 2020 leo.liu.com. All rights reserved.
//

import Foundation
import Moya

public var access_key = "da21158f52a9f279609c2086af65cb47"

public var CurrencyProvider = MoyaProvider<Currencylayer>(
    endpointClosure:endpointClosure,
    requestClosure:requestClosure,
    plugins:[
        NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: { (target, array) in
            if let log = array.first {
                print(log)
            }
        }, logOptions: .formatRequestAscURL))
    ]
)

/*
 plugins:[
      NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: { (target, array) in
          if let log = array.first {
              print(log)
          }
      }, logOptions: .formatRequestAscURL))
  ]
 */

public func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        done(.success(request))
    } catch {
    }
}

let endpointClosure = { (target: Currencylayer) -> Endpoint in
  //  let url = target.baseURL.appendingPathComponent(target.path).absoluteString
   // let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    return MoyaProvider.defaultEndpointMapping(for: target)
}


public enum Currencylayer {
    case Live(source: String)
    case List
}

extension Currencylayer: TargetType {
    public var baseURL: URL { return URL(string: "http://api.currencylayer.com")! }
    
    public var path: String {
        switch self {
        case .Live(_):
            return "/live"
        case .List:
            return "/list"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .Live(_),
             .List:
            return .get
        }
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
            case .Live(let source):
                let params: [String: Any] = ["source": source,"access_key":access_key,"format":1]
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .List:
                let params: [String: Any] = ["access_key":access_key]
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
}

