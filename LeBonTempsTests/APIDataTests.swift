//
//  APIDataTests.swift
//  LeBonTempsTests
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//


import XCTest
import CoreLocation
import Moya

@testable import LeBonTemps

class APIDataTests: XCTestCase {
    var _provider: MoyaProvider<WeatherService>!
    
    override func setUp() {
        super.setUp()
        // A mock provider with a mocking `endpointClosure` that stub immediately
        _provider = MoyaProvider<WeatherService>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    }
    
    func customEndpointClosure(_ target: WeatherService) -> Endpoint {
        return Endpoint(url: URL(target: target).absoluteString,
                        sampleResponseClosure: { .networkResponse(200, target.testSampleData) },
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
    }
}

extension WeatherService {
    var testSampleData: Data {
        switch self {
        case .currentLocationWeathers(let lat, let long):
            // Returning all-popular-movies.json
            let url = Bundle(for: APIDataTests.self).url(forResource: "Weathers", withExtension: "json")!
            print(try! Data(contentsOf: url))
            return try! Data(contentsOf: url)
        case .other:
            let url = Bundle(for: APIDataTests.self).url(forResource: "Weathers", withExtension: "json")!
            return try! Data(contentsOf: url)
        }
    }
}
