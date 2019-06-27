//
//  WeathersManager.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation

fileprivate var WeathersManagerInstance = WeathersManager()

class WeathersManager: NSObject {
    
    override init() {
        super.init()
    }
    
    open class var `manager`: WeathersManager {
        return WeathersManagerInstance
    }
    
    open var localWeathersSavedOnDevice: [Weather] {
        let user = User()
        return user.weathers
    }
    
    
    
}
