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
    
    let restApiResponse = RestDataProviderResponse(
      statusCode: 200,
      body: testOpenWeatherMap5Days3HoursForecastData
    )
    let city = "Munich"
    
    mockRestDataProvider.getReturn = restApiResponse
    
    let periodicWeatherForecast 
      = try await openWeatherMapAPIDataProvider.fetchPeriodicWeatherForecast(cityName: city)
    
    XCTAssertEqual(
      mockRestDataProvider.getArgUrl!.absoluteString,
      "https://api.openweathermap.org/data/2.5/forecast?q=Munich&units=metric&APPID=test_api_key"
    )
    
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
    
    let restApiResponse = RestDataProviderResponse(statusCode: 200, body: testiconData)
    let iconIdentifier = "03d"
    
    mockRestDataProvider.getReturn = restApiResponse
    
    let iconData = try await openWeatherMapAPIDataProvider.fetchWeatherIcon(
      iconIdentifier: iconIdentifier
    )
    
    XCTAssertEqual(
      mockRestDataProvider.getArgUrl!.absoluteString,
      "https://openweathermap.org/img/wn/03d.png"
    )
    
    XCTAssertEqual(iconData, testiconData)
  }
  
  private var testOpenWeatherMap5Days3HoursForecastData: Data {
    """
    {
      "cod": "200",
      "message": 0,
      "cnt": 40,
      "list": [
        {
          "dt": 1576044000,
          "main": {
            "temp": 277.04,
            "temp_min": 277.04,
            "temp_max": 279.06,
            "pressure": 1007,
            "sea_level": 1007,
            "grnd_level": 1003,
            "humidity": 76,
            "temp_kf": -2.02
          },
          "weather": [
            {
              "id": 802,
              "main": "Clouds",
              "description": "scattered clouds",
              "icon": "03n"
            }
          ],
          "clouds": {
            "all": 33
          },
          "wind": {
            "speed": 2.6,
            "deg": 226
          },
          "sys": {
            "pod": "n"
          },
          "dt_txt": "2019-12-11 06:00:00"
        },
        {
          "dt": 1576054800,
          "main": {
            "temp": 277.38,
            "temp_min": 277.38,
            "temp_max": 278.9,
            "pressure": 1006,
            "sea_level": 1006,
            "grnd_level": 1002,
            "humidity": 75,
            "temp_kf": -1.52
          },
          "weather": [
            {
              "id": 802,
              "main": "Clouds",
              "description": "scattered clouds",
              "icon": "03d"
            }
          ],
          "clouds": {
            "all": 35
          },
          "wind": {
            "speed": 2.72,
            "deg": 201
          },
          "sys": {
            "pod": "d"
          },
          "dt_txt": "2019-12-11 09:00:00"
        },
        {
          "dt": 1576065600,
          "main": {
            "temp": 280.4,
            "temp_min": 280.4,
            "temp_max": 281.41,
            "pressure": 1004,
            "sea_level": 1004,
            "grnd_level": 1000,
            "humidity": 64,
            "temp_kf": -1.01
          },
          "weather": [
            {
              "id": 802,
              "main": "Clouds",
              "description": "scattered clouds",
              "icon": "03d"
            }
          ],
          "clouds": {
            "all": 47
          },
          "wind": {
            "speed": 3.82,
            "deg": 236
          },
          "sys": {
            "pod": "d"
          },
          "dt_txt": "2019-12-11 12:00:00"
        }
      ],
      "city": {
        "id": 2643743,
        "name": "London",
        "coord": {
          "lat": 51.5085,
          "lon": -0.1258
        },
        "country": "GB",
        "population": 1000000,
        "timezone": 0,
        "sunrise": 1576050947,
        "sunset": 1576079498
      }
    }
    """.data(using: .utf8)!
  }
  
  private var testiconData: Data {
    return "icon_data".data(using: .utf8)!
  }
}

class MockRestDataProvider: RestDataProvider {
  
  var getArgUrl: URL?
  var getError: Error?
  var getReturn: RestDataProviderResponse!
  
  func get(url: URL) async throws -> QuickWeather.RestDataProviderResponse {
    getArgUrl = url
    if let getError {
      throw getError
    }
    return getReturn;
  }
}
