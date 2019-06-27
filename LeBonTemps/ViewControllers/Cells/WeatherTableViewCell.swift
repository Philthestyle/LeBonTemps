//
//  WeatherTableViewCell.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import UIKit
import CocoaLumberjack

class WeatherTableViewCell: UITableViewCell {
    // MARK: - Variables
    // Private variables
    // *************************************************************
    
    @IBOutlet weak var temperatureTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    
    // Public variables
    // **************************************************************
    
    var data: Weather? {
        didSet {
            if data == nil {
                //                textLabel?.text = "fetching data failed, please refresh."
            } else {
                guard let weather = data else { DDLogError("Need more informations"); return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                let dataDate = dateFormatter.date(from: weather.date! )!
                
                dateFormatter.dateFormat = "d MMM (HH:mm)" //Your New Date format as per requirement change it own
                let newDate = dateFormatter.string(from: dataDate) //pass Date here
                print(newDate) //New formatted Date string
                
                dateTextLabel.text = "\(newDate)"
                temperatureTextLabel.text = "\(Int(kelvinsToCelcius(kelvinsTemperature: weather.temperature.sol)))°C"
            }
        }
    }
    
    
    
    // MARK: - Getter & Setter methods
    // **************************************************************
    
    // MARK: - Constructors
    // **************************************************************
    
    // MARK: - Init behaviors
    // **************************************************************
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - Public methods
    // **************************************************************
    
    override func prepareForReuse() {
        super.prepareForReuse()
        data = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Private methods
    // *************************************************************
    
    // Convert 'Kelvin' degres to -> 'Celcius' degres
    private func kelvinsToCelcius(kelvinsTemperature: Double) -> Double {
        print(kelvinsTemperature)
        let fahrenheitTemperature =  (kelvinsTemperature - 273.15)
        return fahrenheitTemperature
    }
    
    // MARK: - Delegates methods
    // **************************************************************

}
