//
//  Constants.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import CocoaLumberjack

class Constants {
    
    // MARK: - Variables
    // Public variables
    // **************************************************************
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "me.faustin.\(String(describing: UIDevice.current.identifierForVendor?.uuidString))"
    }

    static var apiServerURL = "https://www.infoclimat.fr/public-api/gfs/json?_auth=BR9QRw5wByUFKAE2AHYGL1E5BTAKfFJ1BHgHZA5rVisIY1IzBmZQNlE%2FBHlSfQcxUn8PbAkyUmIKYQF5WykEZQVvUDwOZQdgBWoBZAAvBi1RfwVkCipSdQRuB2AOfVY8CGtSKAZkUDRRNwR4UmMHMlJnD3AJKVJrCmwBYFs3BGQFb1A9DmsHYAVsAXwALwY3UTYFZAo0UmsEZgdmDmtWYAg4UjEGN1A0UTgEeFJjBzFSZg9oCTRSbApsAW9bKQR4BR9QRw5wByUFKAE2AHYGL1E3BTsKYQ%3D%3D&_c=5897ab4ab6215bbe69990428b09e870b"
    
}
