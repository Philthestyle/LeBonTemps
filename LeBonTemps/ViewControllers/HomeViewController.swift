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

        
    }
    
    
    
    // MARK: - Init behaviors
    // **************************************************************

    
    
    
    
    // MARK: - Public methods
    // **************************************************************
    
    
    
    
    // MARK: - Private methods
    // **************************************************************
    private func setupNetworkEngineCacheConfig() {
        let memoryCapacity = 200 * 1024 * 1024 // 200 MB
        let diskCapacity = 50 * 1024 * 1024 // 50 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: NSTemporaryDirectory())
        let urlSessionConf = URLSessionConfiguration.background(withIdentifier: "\(Constants.bundleIdentifier).weather-cache")
        
        let cachePlugin = NetworkDataCachingPlugin(configuration: urlSessionConf, with: cache)
        _provider = MoyaProvider<WeatherService>(plugins: [cachePlugin])
    }
    
    private func setupTableViewRefreshControll() {
        // Setup table view
        weathersTableView.delegate = self
        weathersTableView.dataSource = self
        
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
    
    @objc private func _refreshData(_ sender: Any) {
        weathersTableView.reloadData()
        self._refreshControl.endRefreshing()
    }
    
    
    // MARK: - Delegates methods
    // **************************************************************
    
    
    
    
    
    
    
    
    
    // MARK: - Navigation
    // **************************************************************

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

// Mark: - Manage the tableView delegate
//*************************************************************
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weathersTableView.dequeueReusableCell(withIdentifier: "customWeatherCell", for: indexPath) as! WeatherTableViewCell
        
        cell.dateTextLabel.text? = "Cell label test"
        
        return cell
    }
    
    // cell 'height' management
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // TO DO: --> cell selection action ('data' && 'navigation' management prepared for the destination controller) -> 'WeatherDetailsViewController'
}
