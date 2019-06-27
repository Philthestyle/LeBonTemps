//
//  NetworkDataCachingPlugin.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import UIKit
import Moya

protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class NetworkDataCachingPlugin: PluginType {
    init (configuration: URLSessionConfiguration, with cache: URLCache? = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: NSTemporaryDirectory())) {
        configuration.urlCache = cache
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cacheableTarget = target as? CachePolicyGettable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cacheableTarget.cachePolicy
            return mutableRequest
        }
        return request
    }
}

extension WeatherService: CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .other:
            return .returnCacheDataElseLoad
        default:
            return .useProtocolCachePolicy
        }
    }
}
