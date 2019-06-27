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

//enum WeatherService {
//    case currentLocationWeathers(lat: Int, long: Int)
//    case other
//}
//
//extension WeatherService: TargetType {
//    var baseURL: URL { return URL(string: Constants.apiServerURL)! }
//    var path: String {
//        switch self {
//        case .currentLocationWeathers:
//            return "/currentLocationWeathers"
//        case .other:
//            return "/other"
//        }
//    }
//
//    var method: Moya.Method {
//        switch self {
//        case .currentLocationWeathers, .other:
//            return .get
//        }
//    }
//
//    var parameters: [String: Any] {
//        switch self {
//        case .currentLocationWeathers(let lat, let long):
//            return ["_ll": "\(lat),\(long)"]
//        default:
//            return [String: Any]()
//        }
//    }
//
//    var parameterEncoding: ParameterEncoding {
//        return URLEncoding.default
//    }
//
//    var task: Task {
//        switch self {
//        case .currentLocationWeathers(_, _), .other:
//            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
//        default: // Send no parameters
//            return .requestPlain
//        }
//    }
//
//    var sampleData: Data {
//        switch self {
//        case .currentLocationWeathers:
//            return _getLocalJson(name: "currentLocationWeathers")
//        case .other:
//            return _getLocalJson(name: "other")
//        }
//    }
//
//    var headers: [String: String]? {
//        return ["Content-type": "application/json"]
//    }
//
//
//    private func _getLocalJson(name:String!) -> Data! {
//        // TO DO
//        var data = Data()
//        return data
//    }
//}

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
        default: // Send no parameters
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        return Data()
//        switch self {
//        case .currentLocationWeathers:
//            return Data()
//        case .other:
//            return _getLocalJson(name: "other")
//        }
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
    
    private func _getLocalJson(name:String!) -> Data! {
        //        let url = NSTemporaryDirectory()
        //        let jsonString = "{}"
        //        jsonString.write(to: url, atomically: true, encoding: .utf8)
        //        let data = Data()
        //        data.write(to: url)
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
            let data = try? Data(contentsOf: url) else {
                return Data()
        }
        return data
    }
}

