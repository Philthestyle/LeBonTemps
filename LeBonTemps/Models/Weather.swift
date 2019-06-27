//
//  Weather.swift
//  LeBonTemps
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Weather
struct Weather: Codable {
    var date: String?
    // --> as 'Weather' object getting from API has a key -> (e.i.: "2019-06-27 02:00:00" { "temperature": "2m": 295.3 etc... }) for 'temperature' object.
    // Moreover, this date is changing as time goes by... So we need to update it to make API request work and being updated regularly.
    
    let temperature: Temperature
    let pression: Pression
    let pluie, pluieConvective: Double
    let humidite: Humidite
    let ventMoyen, ventRafales, ventDirection: Vent
    let isoZero: Int
    let risqueNeige: String
    let cape: Int
    let nebulosite: Nebulosite
    
    enum CodingKeys: String, CodingKey {
        case date, temperature, pression, pluie // please refer to 'date', 'temperature', 'pression' & 'pluie' struct below
        case pluieConvective = "pluie_convective"
        case humidite // please refer to 'Humidite' struct below
        case ventMoyen = "vent_moyen"
        case ventRafales = "vent_rafales"
        case ventDirection = "vent_direction"
        case isoZero = "iso_zero"
        case risqueNeige = "risque_neige"
        case cape, nebulosite // please refer to 'cape' & 'nebulosite' structs below
    }
}

// MARK: - Humidite
struct Humidite: Codable {
    let the2M: Double
    
    enum CodingKeys: String, CodingKey {
        case the2M = "2m"
    }
}

// MARK: - Nebulosite
struct Nebulosite: Codable {
    let haute, moyenne, basse, totale: Int
}

// MARK: - Pression
struct Pression: Codable {
    let niveauDeLaMer: Int
    
    enum CodingKeys: String, CodingKey {
        case niveauDeLaMer = "niveau_de_la_mer"
    }
}

// MARK: - Temperature
struct Temperature: Codable {
    let the2M, sol, the500HPa, the850HPa: Double
    
    enum CodingKeys: String, CodingKey {
        case the2M = "2m"
        case sol // TO DO: Kelvin degrees to be converted in Celcius degree (formula is: (kelvinsTemperature - 273.15) )
        case the500HPa = "500hPa"
        case the850HPa = "850hPa"
    }
}

// MARK: - Vent
struct Vent: Codable {
    let the10M: Double
    
    enum CodingKeys: String, CodingKey {
        case the10M = "10m"
    }
}
