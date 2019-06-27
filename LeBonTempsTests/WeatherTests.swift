//
//  WeatherTests.swift
//  LeBonTempsTests
//
//  Created by Faustin Veyssiere on 27/06/2019.
//  Copyright © 2019 Faustin Veyssiere. All rights reserved.
//

import XCTest

@testable import LeBonTemps

class WeatherTests: XCTestCase {

    func testInitWeather() {
        let weather = Weather(date: "2019-06-26 23:00:00",
                              temperature: Temperature(the2M: 297.5, sol: 296.7, the500HPa: -0.1, the850HPa: -0.1),
                              pression: Pression(niveauDeLaMer: 102240),
                              pluie: 0.0,
                              pluieConvective: 0.0,
                              humidite: Humidite(the2M: 76.8),
                              ventMoyen: Vent(the10M: 21.0),
                              ventRafales: Vent(the10M: 44.8),
                              ventDirection: Vent(the10M: 396.0),
                              isoZero: 4678,
                              risqueNeige: "non",
                              cape: 0,
                              nebulosite: Nebulosite(haute: 0, moyenne: 0, basse: 0, totale: 0)
        )
        
        // Expected Values check:
        // ***************************************************************
        
        // date:
        XCTAssertEqual("2019-06-26 23:00:00", weather.date) // -> String

        // temperature:
        XCTAssertEqual(297.5, weather.temperature.the2M)    // -> Double
        XCTAssertEqual(296.7, weather.temperature.sol)      // -> Double
        XCTAssertEqual(-0.1, weather.temperature.the500HPa) // -> Double
        XCTAssertEqual(-0.1, weather.temperature.the850HPa) // -> Double
        
        // pression:
        XCTAssertEqual(102240, weather.pression.niveauDeLaMer) // -> Int
        
        // pluie:
        XCTAssertEqual(0.0, weather.pluie) // -> Double
        
        // pluieConvective:
        XCTAssertEqual(0.0, weather.pluieConvective)  // -> Double
        
        // humidite:
        XCTAssertEqual(0.0, weather.pluieConvective)  // -> Double
        
        // ventMoyen:
        XCTAssertEqual(21.0, weather.ventMoyen.the10M)  // -> Double
        
        // ventRafales:
         XCTAssertEqual(44.8, weather.ventRafales.the10M)  // -> Double
        
        // ventDirection:
         XCTAssertEqual(396.0, weather.ventDirection.the10M)  // -> Double
        
        // isoZero:
        XCTAssertEqual(4678, weather.isoZero) // -> Int
        
        // risqueNeige:
        XCTAssertEqual("non", weather.risqueNeige) // -> String
        
        // cape:
        XCTAssertEqual(0, weather.cape) // -> Int
        
        // nebulosite:
        XCTAssertEqual(0, weather.nebulosite.haute)   // -> Int
        XCTAssertEqual(0, weather.nebulosite.moyenne) // -> Int
        XCTAssertEqual(0, weather.nebulosite.basse)   // -> Int
        XCTAssertEqual(0, weather.nebulosite.totale)  // -> Int
       
    }

}
