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
    
    // MARK: - Variables
    // Public variables
    // **************************************************************
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "me.faustin.\(String(describing: UIDevice.current.identifierForVendor?.uuidString))"
    }

    static var apiServerURL = "https://www.infoclimat.fr/public-api/gfs/json?_ll=48.85341,2.3488&_auth=ABpfSFIsBiRWewQzAnQDKgVtBzJeKFRzUS0GZQpvVCkFblU0D29dO1Q6A34PIFVjWHVQMwE6ADABalAoWykCYwBqXzNSOQZhVjkEYQItAygFKwdmXn5Uc1E7BmMKeVQ2BW5VNQ9yXT5UOwNlDyFVYFhjUDUBIQAnAWNQMlswAmAAZV86UjEGbFYxBG4CLQMoBTMHM15gVGhRNgYwCm9UPwVhVTYPbV1qVGoDZw8hVWhYaFA4ATcAOQFgUDdbMAJ%2BAHxfQlJCBnlWeQQkAmcDcQUrBzJeP1Q4&_c=cea1844ab375c1d77e932f70d92b095e"
    
    
    // MARK: - Getter & Setter methods
    // **************************************************************
    
    
    // MARK: - Public methods
    // **************************************************************
    
    // MARK: - Keychain behavior
    // **************************************************************
    

    // MARK: - Private methods
    // **************************************************************
}
