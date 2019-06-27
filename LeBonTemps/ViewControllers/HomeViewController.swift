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
import PMAlertController


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
    
    private let _offlineJsonFileName: String = "Weathers.json"
    
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
        
        
        
        
    }
    
    
    // MARK: - Init behaviors
    // **************************************************************
    
    
    
    
    // Set 'statusBarStyle' to '.light' appearance
    // ***************************
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Custom UI && Design
        initTableViewDesign()
        
        // NavigationBar custom design
        self.setNeedsStatusBarAppearanceUpdate()
        self.initDesignViewController()
        
        
    }
    
    // set preferredStatusBarStyle to .lightContent style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
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
        
        // A) 1. update 'HomeViewController' title with 'city' name and 'country' name of user's current location (latitude & longitude)
        self.updateCityCountryCurrentLocationData()
        
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
                    // B) 1. try to encode data in NSData for only Json => [String: Any]
                        if let value = item.value as? [String: Any],
                            let jsonData = try? JSONSerialization.data(withJSONObject: value),
                            var typedValue = AbstractModel.decodeTypedObject(type: Weather.self, data: jsonData) {
                            print("typedValue: \(typedValue)")
                            typedValue.date = item.key
                            // fill weathers array with each weather item from API after JSONSerialization
                            weathers.append(typedValue)
                        } else {
                            print("error - encoding data in NSData has failed")
                        }
                    }
                    // B) 2. sort 'weathers' array by 'date'
                    let sortedWeathers = weathers.sorted { $0.date! < $1.date! }
                    self._userInformations.weathers = sortedWeathers
                    
                    // B) 3. save user's weathers's list with a json file locally into device
                    self.saveToJsonFile(weathersArray: sortedWeathers)
                    
                    // B) 4. retrieve json file from device and update weathersTableView with its data
//                    self.retrieveFromJsonFile()
                    
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
    
    private func initDesignViewController() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1791211892, green: 0.4747553867, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        ]
    }
    
    // save json data from given 'Weather' array (after API response has been serialized with typedValue = AbstractModel.decodeTypedObject(type: Weather.self, data: jsonData))
    // ****************************
    private func saveToJsonFile(weathersArray: [Weather]) {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent(_offlineJsonFileName)
        
        let weathersArray = weathersArray
        
        // Transform array into data and save it into file
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(weathersArray)
            try jsonData.write(to: fileUrl, options: [])
            print("Weathers array data: \(jsonData)")
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString!)
        } catch {
            print(error)
        }
    }
    
    
    // retrieve json file and decode it from [Weather].self and update user's weathers list with this data
    // ****************************
    func retrieveFromJsonFile() {
        // Get the url of Persons.json in document directory
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return
        }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent(_offlineJsonFileName)
        // Read data from .json file and transform data into an array
        
        if !(fileExist(path: fileUrl.path)) {
            print("File Does Not Exist...")
            return
        }  else {
            let jsonDecoder = JSONDecoder()
            let data = try! Data(contentsOf: fileUrl, options: [])
            let weathersArray = try! jsonDecoder.decode([Weather].self, from: data)
            self._userInformations.weathers = weathersArray
            print(self._userInformations.weathers)
            self.weathersTableView.reloadData()
        }
        
    }
    
    
     // check if json local file is available and exists - if available, return 'true', else, 'false'
     // ****************************
     func fileExist(fileNameWithExtention: String) -> Bool {
        var fileExist: Bool = false
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        let url = NSURL(fileURLWithPath: path)

         // Read data from .json file to observe it and conclude if it exists or not
        if let pathComponent = url.appendingPathComponent(fileNameWithExtention) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("File available")
                print("File 'size':\(fileNameWithExtention) --> \(fileManager.contents(atPath: filePath)!)")
                fileExist = true
            } else {
                print("File NOT available")
                fileExist = false
            }
        } else {
            print("File path NOT available")
            fileExist = false
        }
        return fileExist
    }
    
    func fileExist(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let fm = FileManager.default
        return (fm.fileExists(atPath: path, isDirectory: &isDirectory))
    }
    
    
    
    // get 'city' and 'country' data  by reversedGeocoding Location from users' 'currentLocation'
    // ****************************
    private func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    // convert
    // ****************************
    private func updateCityCountryCurrentLocationData() {
        // Updating 'city' && 'country' NavigationBar Title
        self.fetchCityAndCountry(from: self._userInformations.locationCLLoation) { city, country, error in
            var cityName: String = ""
            var countryName: String = ""
            guard let city = city, let country = country, error == nil else { return }
            cityName = city
            countryName = country
            print(city + ", " + country)  // e.i. Rio de Janeiro, Brazil
            
            self.updateNavigationControllerTitle(city: city, country: countryName)
            
            print(cityName)
        }
    }
    
    // update viewController 'title' with 'city' name and 'country' name
    // ****************************
    private func updateNavigationControllerTitle(city: String, country: String) {
        self.title = "\(city + ", " + country.uppercased())"
    }
    
    // get data if user is offline (wifi or cellular network)
    // ****************************
    private func getDataOfflineMode(fileNameWithExtension: String) {
        if fileExist(fileNameWithExtention: fileNameWithExtension) {
            print("File exists !!! :)")
            
            // retieve json and update '_userInformations.weathers'
            self.retrieveFromJsonFile()
        } else {
            print("Network error. Please check your Internet connection")
            
            
        }
//        // check if file ('Weathers.json' exists locally into user's device)
//        if fileExist(path: "Weathers.json") {
//            print("File exists !!! :)")
//            // retieve json and update '_userInformations.weathers'
//            self.retrieveFromJsonFile()
//        } else {
//            print("Network error. Please check your Internet connection")
//            // user has no json file saved locally into his device
//            print("Weathers.json doesn't exists into device")
//        }
    }
    
    
    // get data from API if user has wifi or cellular network available
    // ****************************
    private func getDataOnlineMode(userInformations: User) {
        // no need to check if json file is already saved in device, because we will update it and save it from the next method '_getCurrentLocationWeathersData'
        self._getCurrentLocationWeathersData()
    }
    
    
    // get data from API if user has wifi or cellular network available
    // ****************************
    private func showAlertViewNetworkError() {
        let alertController = UIAlertController(title: "Network error", message:
            "Please check your Internet connection and refresh.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }


    // get data from API if user has wifi or cellular network available
    // ****************************
    private func showAlertViewOfflineMode() {
        let alertController = UIAlertController(title: "Offline mode", message:
            "You are currently using our app in 'offline mode'. Please connect to the Internet to get steady updates.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "I understand", style: .default))

        self.present(alertController, animated: true, completion: nil)
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
       
        // manage 'offline'/'online' switch cases mode
        // ***************************
        
        // check if user has any Internet access (wifi of cellular network)
        if Connectivity.isConnectedToInternet() {
            // get data from API and save it into his device with a json file
            self._getCurrentLocationWeathersData()
            
        } else {
            // user has NO access to the Internet at all
            if self._userInformations.weathers.isEmpty {
                // make user aware of the fact that he is using the app ini 'offline mode'
                showAlertViewOfflineMode()
                
                // trying to get offline json data (if already exists - if NOT --> 'showAlertViewNetworkError()'...)
                getDataOfflineMode(fileNameWithExtension: _offlineJsonFileName)
                
                // update 'HomeViewController' 'title' to inform user that he has no Internet access
                self.title = "Offline mode"
                
            } else {
                // user has NO Internet access && json file Weathers.json'
                showAlertViewNetworkError()
                
                // update 'HomeViewController' 'title' to inform user that he has no Internet access
                self.title = "Network unavailable"
            }
        }
        
        // get data from API, save serialized values, save json locally, and retrieve json values to update weathersTableView
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
    
    // cell selection action ('data' && 'navigation' management prepared for the destination controller) -> 'WeatherDetailsViewController'
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "weatherDetailsVC") as? WeatherDetailsViewController else {
            DDLogError("Can't find 'WeatherDetailsViewController'")
            return
        }
        
        let currentWeatherItem = _userInformations.weathers[indexPath.row]
        detailVC.data = currentWeatherItem
        
        self.navigationController?.present(detailVC, animated: true, completion: nil)
        
        // deselect cell in order to avoid having to tap twice to select cell
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
