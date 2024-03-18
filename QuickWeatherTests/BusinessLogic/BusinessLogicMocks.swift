//
//  Mocks.swift
//  QuickWeatherTests
//
//  Created by Radu, Gabriel on 17.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import Foundation
import XCTest
@testable import QuickWeather

class MockWeatherDataProvider: WeatherDataProvider {
  
  private var fetchPeriodicWeatherForecastCityName: String?
  private var fetchPeriodicWeatherForecastError: Error?
  private var fetchPeriodicWeatherForecastReturn: PeriodicWeatherForecast!
  func fetchPeriodicWeatherForecast(cityName: String) async throws -> PeriodicWeatherForecast {
    fetchPeriodicWeatherForecastCityName = cityName
    if let fetchPeriodicWeatherForecastError {
      throw fetchPeriodicWeatherForecastError
    }
    return fetchPeriodicWeatherForecastReturn;
  }
  
  private var fetchWeatherIconIconIdentifier: [String] = []
  private var fetchWeatherIconError: Error?
  private var fetchWeatherIconReturn: [String: Data] = [:]
  func fetchWeatherIcon(iconIdentifier: String) async throws -> Data {
    fetchWeatherIconIconIdentifier.append(iconIdentifier)
    if let fetchWeatherIconError {
      throw fetchWeatherIconError
    }
    return fetchWeatherIconReturn[iconIdentifier]!
  }
}

extension MockWeatherDataProvider {
  
  func setupWithBasicResponse() {
    fetchPeriodicWeatherForecastReturn = testFetchPeriodicWeatherForecastReturnTest
    fetchWeatherIconReturn["iid1"] = testImageData1
    fetchWeatherIconReturn["iid2"] = testImageData2
  }
  
  func setupWithForcastPreriodsWithIdenticalIcons() {
    fetchPeriodicWeatherForecastReturn = testFetchPeriodicWeatherForecastReturnTestForCacheTest1
    fetchWeatherIconReturn["iid1"] = testImageData1
    fetchWeatherIconReturn["iid2"] = testImageData2
  }
  
  func setupWithPeriodicWeatherForecastForMultiplePeriodsPerDay() {
    fetchPeriodicWeatherForecastReturn = periodicWeatherForecastForMultiplePeriodsPerDay
    fetchWeatherIconReturn["iid1"] = testImageData1
    fetchWeatherIconReturn["iid2"] = testImageData2
    fetchWeatherIconReturn["iid3"] = testImageData3
  }
  
  func assertIconRequest(count: Int) {
    XCTAssertEqual(fetchWeatherIconIconIdentifier.count, count)
  }
  
  private var testFetchPeriodicWeatherForecastReturnTest: PeriodicWeatherForecast {
    .init(periods: [
      WeatherForecastPeriod(
        temperature: 21.3,
        date: Date(timeIntervalSince1970: 1),
        iconIdentifier: "iid1"
      ),
      WeatherForecastPeriod(
        temperature: 22.3,
        date: Date(timeIntervalSince1970: 2),
        iconIdentifier: "iid2"
      ),
    ])
  }

  private var testFetchPeriodicWeatherForecastReturnTestForCacheTest1: PeriodicWeatherForecast {
    .init(periods: [
      WeatherForecastPeriod(
        temperature: 21.3,
        date: Date(timeIntervalSince1970: 1),
        iconIdentifier: "iid1"
      ),
      WeatherForecastPeriod(
        temperature: 22.3,
        date: Date(timeIntervalSince1970: 2),
        iconIdentifier: "iid2"
      ),
      WeatherForecastPeriod(
        temperature: 23.3,
        date: Date(timeIntervalSince1970: 3),
        iconIdentifier: "iid2"
      ),
    ])
  }

  private var periodicWeatherForecastForMultiplePeriodsPerDay: PeriodicWeatherForecast {
    .init(periods: [
      
      WeatherForecastPeriod(
        temperature: 21.3,
        date: dates[0],
        iconIdentifier: "iid1"
      ),
      WeatherForecastPeriod(
        temperature: 22.3,
        date: dates[0].advanced(by: 3*3600),
        iconIdentifier: "iid1"
      ),
      WeatherForecastPeriod(
        temperature: 23.3,
        date: dates[0].advanced(by: 6*3600),
        iconIdentifier: "iid1"
      ),
      
      WeatherForecastPeriod(
        temperature: 22.3,
        date: dates[1],
        iconIdentifier: "iid2"
      ),
      WeatherForecastPeriod(
        temperature: 23.3,
        date: dates[1].advanced(by: 3*3600),
        iconIdentifier: "iid2"
      ),
      
      WeatherForecastPeriod(
        temperature: 23.3,
        date: dates[2],
        iconIdentifier: "iid3"
      ),
    ])
  }
  
  var testImageData1: Data {
    "image_data1".data(using: .utf8)!
  }
  
  var testImageData2: Data {
    "image_data2".data(using: .utf8)!
  }

  var testImageData3: Data {
    "image_data3".data(using: .utf8)!
  }

  var dates: [Date] {
    [
      Date(timeIntervalSince1970: 1*3600*24),
      Date(timeIntervalSince1970: 2*3600*24),
      Date(timeIntervalSince1970: 3*3600*24),
    ]
  }
}
