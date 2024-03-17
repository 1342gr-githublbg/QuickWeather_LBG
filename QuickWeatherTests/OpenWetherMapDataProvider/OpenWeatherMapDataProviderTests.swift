//
//  OpenWeatherMapApiDataProviderTests.swift
//  QuickWeatherTests
//
//  Created by Gabriel Radu on 15/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.

import Foundation
import XCTest
@testable import QuickWeather

class OpenWeatherMapApiDataProviderTests: XCTestCase {

  private var mockRestDataProvider: MockRestDataProvider!
  private var iconCache: NSCache<NSString, NSData>!
  private var openWeatherMapAPIDataProvider: OpenWeatherMapAPIDataProvider!
  
  private var testApiKey = "test_api_key"
  private var iconMultiplier = "@2"

  override func setUp() {
    mockRestDataProvider = MockRestDataProvider()
    iconCache = NSCache<NSString, NSData>()
    openWeatherMapAPIDataProvider = OpenWeatherMapAPIDataProvider(
      restDataProvider: mockRestDataProvider,
      apiKey: testApiKey,
      iconMultiplier: iconMultiplier
    )
  }

  func test_fetchPeriodicWeatherForecast() async throws {
    
    let city = "Munich"
    
    mockRestDataProvider.setupWithPeriodicDataForecastResponse()
    
    let periodicWeatherForecast 
      = try await openWeatherMapAPIDataProvider.fetchPeriodicWeatherForecast(cityName: city)
    
    mockRestDataProvider.assertForecastURL(apiKey: testApiKey, city: city)
    
    XCTAssertEqual(periodicWeatherForecast.periods.count, 3)
    
    var period = periodicWeatherForecast.periods[0]
    XCTAssertEqual(period.date, Date(timeIntervalSince1970: 1576044000))
    XCTAssertEqual(period.iconData, nil)
    XCTAssertEqual(period.iconIdentifier, "03n")
    XCTAssertEqual(period.temperature, 277.04)

    period = periodicWeatherForecast.periods[1]
    XCTAssertEqual(period.date, Date(timeIntervalSince1970: 1576054800))
    XCTAssertEqual(period.iconData, nil)
    XCTAssertEqual(period.iconIdentifier, "03d")
    XCTAssertEqual(period.temperature, 277.38)

    period = periodicWeatherForecast.periods[2]
    XCTAssertEqual(period.date, Date(timeIntervalSince1970: 1576065600))
    XCTAssertEqual(period.iconData, nil)
    XCTAssertEqual(period.iconIdentifier, "03d")
    XCTAssertEqual(period.temperature, 280.4)
  }
  
  func test_fetchIconData() async throws {
    
    let iconIdentifier = "03d"
    
    mockRestDataProvider.setupWithIconDataResponse()
    
    let iconData = try await openWeatherMapAPIDataProvider.fetchWeatherIcon(
      iconIdentifier: iconIdentifier
    )
    
    
    XCTAssertEqual(iconData, mockRestDataProvider.testiconData)
  }
  
}

