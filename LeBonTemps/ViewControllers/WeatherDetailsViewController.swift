//
//  WeatherDetailsViewController.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import UIKit

class WeatherDetailsViewController: UIViewController {

    
    // MARK: - Variables
    // Private variables
    // **************************************************************
   
    // Public variables
    // **************************************************************
    var data: Weather?
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityRatioTextLabel: UILabel!
    
    
    
    // MARK: - Constructors
    // **************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()

        updateCurrentWeatherItemData()
        
        
    }
    
    
    // MARK: - Private methods
    // *************************************************************
    
    // *****************************
    private func updateCurrentWeatherItemData() {
        if let weatherData = data {
            temperatureLabel.text = "\(Int(kelvinsToCelcius(kelvinsTemperature: weatherData.temperature.sol)))°C"
            humidityRatioTextLabel.text? = "\(weatherData.humidite.the2M)%"
        }
    }
    
   
    private func kelvinsToCelcius(kelvinsTemperature: Double) -> Double {
        print(kelvinsTemperature)
        let fahrenheitTemperature =  (kelvinsTemperature - 273.15)
        return fahrenheitTemperature
    }
    
    // MARK: - Public methods
    // *************************************************************
    @IBAction func closeHandler(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
