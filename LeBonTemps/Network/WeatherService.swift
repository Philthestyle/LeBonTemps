//
//  WeatherService.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import UIKit
import Moya


enum WeatherService {
    case currentLocationWeathers(lat: Int, long: Int)
    case other
}

extension WeatherService: TargetType {
    var baseURL: URL { return URL(string: Constants.apiServerURL)! }
    public var path: String {
        switch self {
        case .currentLocationWeathers:
            return "/currentLocationWeathers"
        case .other:
            return "/other"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .currentLocationWeathers, .other:
            return .get
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .currentLocationWeathers(let lat, let long):
            return ["_ll": "\(lat),\(long)"]
        default:
            return [String: Any]()
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var task: Task {
        switch self {
        case .currentLocationWeathers(_, _), .other:
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    public func clearCache(urlRequests: [URLRequest] = []) {
        let provider = MoyaProvider<WeatherService>()
        guard let urlCache = provider.manager.session.configuration.urlCache else { return }
        if urlRequests.isEmpty {
            urlCache.removeAllCachedResponses()
        } else {
            urlRequests.forEach { urlCache.removeCachedResponse(for: $0) }
        }
    }
    
}

