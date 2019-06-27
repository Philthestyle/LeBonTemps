//
//  HomeViewController.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import UIKit

// external libraries
import CocoaLumberjack
import CoreLocation
import Moya
import RxSwift


class HomeViewController: UIViewController {
    // MARK: - Variables
    // Private variables
    // **************************************************************
    
    // tableView
    private var _defaultCellIdentifier = "defaultWeatherCell"
    private var _weatherCellIdentifier = "customWeatherCell"
    // data & network managment
    private var _locationManager = CLLocationManager() // help us get currentLocation
    private var _userInformations: User! // init userInformations to get access to weathers list that will be saved locally on device
    private var _provider: MoyaProvider<WeatherService>! // network
    private let _refreshControl = UIRefreshControl() // tableView refresh control
    
    
    // Public variables
    // **************************************************************
    @IBOutlet weak var weathersTableView: UITableView!
    
    
    
    // MARK: - Constructors
    // **************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        weathersTableView.delegate = self
        weathersTableView.dataSource = self
        self.setupTableViewRefreshControll()
        
        // Network
        self.setupNetworkEngineCacheConfig()
        
        // Manage data
        _userInformations = User()
        _determineMyCurrentLocation()
        
        
        // Custom UI && Design
        initTableViewDesign()
        
        // NavigationBar custom design
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1791211892, green: 0.4747553867, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)]
        
    }
    
    

    // MARK: - Private methods
    // *************************************************************
    
    // get data from network and save it locally into current device
    // ***************************
    private func _getCurrentLocationWeathersData() {
        // A) try to get user's currentLocation from 'User.latitude' && 'User.longitude'
        guard let lat = _userInformations.currentLocation?.latitude, let long = _userInformations.currentLocation?.longitude else {
            DDLogError("Warning! You don't have enough data to load detail of weather for your current location")
            return
        }
        // B) API request with Moya using 'lat' && 'long' (Tests ref. --> APIDataTests.swift)
        _provider.request(.currentLocationWeathers(lat: Int(lat), long: Int(long))) { event in
            switch event {
            case let .success(response):
                DDLogDebug("RESPONSE FROM API --> (Weathers list of current location): \(response)")
                do {
                    let json: [String: Any] = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                    var weathers = [Weather]()
                    for item in json {
                        print("----> K: \(item.key) => \n\(item.value)\n\n")
                        // B) 1) try to encode data in NSData for only Json => [String: Any]
                        if let value = item.value as? [String: Any],
                            let jsonData = try? JSONSerialization.data(withJSONObject: value),
                            var typedValue = AbstractModel.decodeTypedObject(type: Weather.self, data: jsonData) {
                            print("typedValue: \(typedValue)")
                            typedValue.date = item.key
                            weathers.append(typedValue)
                        } else {
                            print("error - encoding data in NSData has failed")
                        }
                    }
                    // B) 2) sort 'weathers' array by 'date'
                    let sortedWeathers = weathers.sorted { $0.date! < $1.date! }
                    self._userInformations.weathers = sortedWeathers
                    
                    // B) 3) TO DO:
                    // try to save 'response.data' (that has just been parsed to json format and sorted to local user's mobile folders so it will be available offline even if he kills 'LeBonTemps' and come back later without any Internet access (no wifi, no cellular data).)
                    
                } catch let error {
                    print("error: \(error)")
                }
                // C) Reload 'weathersTableView' data
                self.weathersTableView.reloadData()
                
            case let .failure(error):
                DDLogDebug("Weather of current location error: \(error)")
            }
        }
    }
    
    
    
    // network cache config
    // ***************************
    private func setupNetworkEngineCacheConfig() {
        let memoryCapacity = 200 * 1024 * 1024 // 200 MB
        let diskCapacity = 50 * 1024 * 1024 // 50 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: NSTemporaryDirectory())
        let urlSessionConf = URLSessionConfiguration.background(withIdentifier: "\(Constants.bundleIdentifier).weather-cache")
        
        let cachePlugin = NetworkDataCachingPlugin(configuration: urlSessionConf, with: cache)
        _provider = MoyaProvider<WeatherService>(plugins: [cachePlugin])
    }
    
    
    
    // get user's current location (and update it thanks to '_locationManager.startUpdatingLocation()')
    // ***************************
    private func _determineMyCurrentLocation() {
        _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        _locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            _locationManager.startUpdatingLocation()
        }
    }
    
    
    
    // init '_refreshControl' to it so when user swipe down, refresh control is customized
    // ***************************
    private func setupTableViewRefreshControll() {
        // Add Refresh Control to table view
        if #available(iOS 10.0, *) {
            weathersTableView.refreshControl = _refreshControl
        } else {
            weathersTableView.addSubview(_refreshControl)
        }
        _refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: _refreshControl.tintColor as Any, .kern: 10]
        _refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...", attributes: attributes)
        _refreshControl.addTarget(self, action: #selector(_refreshData(_:)), for: .valueChanged)
    }
    
    
    
    // manage 'refreshControl' and refresh data from 'weathersTableView'
    // ****************************
    @objc private func _refreshData(_ sender: Any) {
        weathersTableView.reloadData()
        self._refreshControl.endRefreshing()
    }
    
    // weathersTableView custom design
    // ***************************
    private func initTableViewDesign() {
        weathersTableView.backgroundColor = #colorLiteral(red: 0.1791211892, green: 0.4747553867, blue: 1, alpha: 1)
    }

}


// Mark: - Delegate methods
// Mark: - Manage user's location
// *************************************************************
extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { DDLogError("Location information missing."); return }
        
        // Call 'stopUpdatingLocation()' to stop listening for location updates,
        // other wise this function will be called every time user location will be changed.
        manager.stopUpdatingLocation()
        
        let location = Location(location: userLocation)
        _userInformations.currentLocation = location
       
        // TO DO --> update '_userInformations.weathers' using user's current Location (_userInformations.currentLocation)
        _getCurrentLocationWeathersData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DDLogError("CLLocation error \(error)")
    }
}

// Mark: - Manage tableView's delegate
// *************************************************************
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _userInformations.weathers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentData = _userInformations?.weathers[indexPath.row] else {
            return tableView.dequeueReusableCell(withIdentifier: _defaultCellIdentifier, for: indexPath)
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: _weatherCellIdentifier, for: indexPath) as? WeatherTableViewCell {
            cell.data = currentData
            cell.backgroundColor = #colorLiteral(red: 0.1791211892, green: 0.4747553867, blue: 1, alpha: 1)
            return cell
        }
        // manage my cell with the default behavior
        return tableView.dequeueReusableCell(withIdentifier: _defaultCellIdentifier, for: indexPath)
    }
    
    // cell 'height' management
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // TO DO: --> cell selection action ('data' && 'navigation' management prepared for the destination controller) -> 'WeatherDetailsViewController'
}
