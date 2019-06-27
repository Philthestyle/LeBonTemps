//
//  Constants.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import CocoaLumberjack
import KeychainAccess

class Constants {
 
    // Public variables
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "me.faustin.\(String(describing: UIDevice.current.identifierForVendor?.uuidString))"
    }

    static var apiServerURL = "https://www.infoclimat.fr/public-api/gfs/json?_ll=48.85341,2.3488&_auth=ABpfSFIsBiRWewQzAnQDKgVtBzJeKFRzUS0GZQpvVCkFblU0D29dO1Q6A34PIFVjWHVQMwE6ADABalAoWykCYwBqXzNSOQZhVjkEYQItAygFKwdmXn5Uc1E7BmMKeVQ2BW5VNQ9yXT5UOwNlDyFVYFhjUDUBIQAnAWNQMlswAmAAZV86UjEGbFYxBG4CLQMoBTMHM15gVGhRNgYwCm9UPwVhVTYPbV1qVGoDZw8hVWhYaFA4ATcAOQFgUDdbMAJ%2BAHxfQlJCBnlWeQQkAmcDcQUrBzJeP1Q4&_c=cea1844ab375c1d77e932f70d92b095e"
    
    
    
    // Mark: - Manage Open Weather Map Token behavior
    static private var _openweathermapTokenKey = "openweathermapToken"
    static var openweathermapToken: String {
        let keychain = getKeychain()
        if let token = keychain[_openweathermapTokenKey] { return token }
        return ""
    }
    
    static func registerOpenweathermapToken() {
        _ = Constants.register(token: "", for: _openweathermapTokenKey)
    }
    
    static var locale = "fr"
    static var country = "fr"
    
    // MARK: - Getter & Setter methods
    
    
    // MARK: - Public methods
    
    // MARK: - Keychain behavior
    static func setupKeychain() -> Keychain {
        let keychain = Keychain(service: bundleIdentifier)
            .label("faustin.me (LeBonTemps)")
            .synchronizable(true)
        return keychain
    }
    
    static func getKeychain() -> Keychain {
        let keychain = Keychain(service: bundleIdentifier)
        return keychain
    }
    
    static func register(token: String, for key:String) -> String {
        // Setup api Tokens in keychain
        let keychain = getKeychain()
        if token == "" && (keychain[key] == nil || keychain[key] == "") {
            fatalError("Error! You need to add a tweak token for this app worked")
        } else if token != "" {
            keychain[key] = token
        }
        if let tokenRegistered = keychain[key] { DDLogDebug("🔑 The token(\(key)): \(tokenRegistered)") }
        return token
    }
    
    
    // MARK: - Private methods
}
