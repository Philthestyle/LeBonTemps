//
//  User.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import UIKit
import CoreLocation


class User: AbstractModel {

    // MARK: - Variables
    // Private variables
    // **************************************************************
    private enum CodingKeys: String, CodingKey {
        case currentLocation
    }
    private var _loc: [Location] = []


    // Public variables
    // **************************************************************
    // array of 'Weather' after having been initialized from API Response.data.
    // array to be used in HomeViewController.swift -> to display all the currentLocation 'Weather' objects in the TableView || CollectionView cells.
    var weathers = [Weather]()

    var currentLocation: Location? // CLLocationCoordinate2D // CLLocation
    var locationCLLoation: CLLocation {
        let location: CLLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
        return location
    }


    // MARK: - Constructors
    // **************************************************************
    /**
     Method to create the manager of socket communications

     @param settings detail to launch the right sockets connection
     @param delegate used to dispatch event from sockets activities
     */
    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        do {
            try super.init(from: decoder)
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.currentLocation = try? values.decode(Location.self, forKey: .currentLocation)

        } catch {
            fatalError("Error! When you want to decode your model: \(AbstractModel.modelName)")
        }
    }


    // MARK: - Init behaviors
    // **************************************************************
    override func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(currentLocation, forKey: .currentLocation)
            try super.encode(to: encoder)
        } catch {
            fatalError("Error! When you want to encode your model: \(type(of: self).modelName) > \(self)")
        }
    }


    // MARK: - Public methods
    // **************************************************************
    public func add(location: Location) {
        _loc.append(location)
    }

    public func removeLocation(at index: Int) {
        _loc.remove(at: index)
    }

    // MARK: - Private methods

    // MARK: - Delegates methods
}
