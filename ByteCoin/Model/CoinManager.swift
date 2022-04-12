//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol CoinManagerRateDelegate {
    func didReceiveResponse(currency: String, rate: Double)
    func didFailWithError(message: String)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    var delegate: CoinManagerRateDelegate?
    
    func getCoinPrice(for currency: String) {
        let exchangeRateAPI = generateExchangeRateAPI(for: currency)
        httpRequest(to: exchangeRateAPI) { result in
            switch (result) {
            case .success(let json):
                let err = json["error"]
                if err != JSON.null {
                    delegate?.didFailWithError(message: err.stringValue)
                    return
                }
                
                let rate = json["rate"].doubleValue
                delegate?.didReceiveResponse(currency: currency, rate: rate)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func generateExchangeRateAPI(for currency: String) -> String {
        return "\(baseURL)/\(currency)?apikey=\(apiKey)"
    }
    
    enum HttpRequestError: Error {
        case NoData, invalidURL
    }
    func httpRequest(to url: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(HttpRequestError.invalidURL))
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard data != nil else {
                completion(.failure(HttpRequestError.NoData))
                return
            }
            
            do {
                let jsonObject = try JSON(data: data!)
                completion(.success(jsonObject))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
