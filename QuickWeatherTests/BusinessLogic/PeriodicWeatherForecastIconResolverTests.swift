//
//  PeriodicWeatherForecastIconResolverTests.swift
//  QuickWeatherTests
//
//  Created by Gabriel Radu on 15/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import XCTest
@testable import QuickWeather

class WeatherInfoBusinessLogicTests: XCTestCase {
  
  private var mockWeatherDataProvider: MockWeatherDataProvider!
  private var delegate: WeatherInfoBusinessLogicDelegateTestImpl!
  private var iconCache: IconCache!
  private var weatherInfoBusinessLogic: WeatherInfoBusinessLogic!
  
  override func setUp() {
    mockWeatherDataProvider = MockWeatherDataProvider()
    delegate = WeatherInfoBusinessLogicDelegateTestImpl()
    iconCache = IconCache()
    weatherInfoBusinessLogic = WeatherInfoBusinessLogicImplementation(
      weatherDataProvider: mockWeatherDataProvider,
      iconCache: iconCache
    )
    weatherInfoBusinessLogic.delegate = delegate
  }
  
  func test_fetchWeatherInfo() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "delegate method has been called")
    expectation.assertForOverFulfill = false
    delegate.weatherInfoBusinessLogicDidFetchTestCallback = {
      expectation.fulfill()
    }
    
    mockWeatherDataProvider.fetchPeriodicWeatherForecastReturn
      = testFetchPeriodicWeatherForecastReturnTest
    mockWeatherDataProvider.fetchWeatherIconReturn["iid1"] = testImageData1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid2"] = testImageData2

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    wait(for: [expectation], timeout: 3)
    
    XCTAssert(delegate.periodicWeatherForecasts.count > 0)
  }
  
  func test_fetchWeatherInfo_withIcons() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "delegate method has been called")
    delegate.weatherInfoBusinessLogicDidFetchTestCallback = {
      let lastForecast = self.delegate.periodicWeatherForecasts.last
      if
        lastForecast?.periods[0].iconData != nil &&
        lastForecast?.periods[1].iconData != nil
      {
        expectation.fulfill()
      }
    }
    
    mockWeatherDataProvider.fetchPeriodicWeatherForecastReturn
      = testFetchPeriodicWeatherForecastReturnTest
    mockWeatherDataProvider.fetchWeatherIconReturn["iid1"] = testImageData1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid2"] = testImageData2

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    wait(for: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, testImageData2)
  }

  func test_fetchWeatherInfo_cacheTest1() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "delegate method has been called")
    delegate.weatherInfoBusinessLogicDidFetchTestCallback = {
      let lastForecast = self.delegate.periodicWeatherForecasts.last
      if
        lastForecast?.periods[0].iconData != nil &&
        lastForecast?.periods[1].iconData != nil &&
        lastForecast?.periods[2].iconData != nil
      {
        expectation.fulfill()
      }
    }
    
    mockWeatherDataProvider.fetchPeriodicWeatherForecastReturn
      = testFetchPeriodicWeatherForecastReturnTestForCacheTest1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid1"] = testImageData1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid2"] = testImageData2

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    wait(for: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, testImageData2)
    XCTAssertEqual(lastForecast?.periods[2].iconData, testImageData2)
    XCTAssertEqual(mockWeatherDataProvider.fetchWeatherIconIconIdentifier.count, 2)
  }

  func test_fetchWeatherInfo_cacheTest2() async throws {
    let cityName = "Leeds"
    
    await iconCache.set(icon: testImageData1, key: "iid1")
    await iconCache.set(icon: testImageData2, key: "iid2")

    let expectation = self.expectation(description: "delegate method has been called")
    expectation.assertForOverFulfill = false
    delegate.weatherInfoBusinessLogicDidFetchTestCallback = {
      let lastForecast = self.delegate.periodicWeatherForecasts.last
      if
        lastForecast?.periods[0].iconData != nil &&
        lastForecast?.periods[1].iconData != nil &&
        lastForecast?.periods[2].iconData != nil
      {
        expectation.fulfill()
      }
    }
    
    mockWeatherDataProvider.fetchPeriodicWeatherForecastReturn
      = testFetchPeriodicWeatherForecastReturnTestForCacheTest1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid1"] = testImageData1
    mockWeatherDataProvider.fetchWeatherIconReturn["iid2"] = testImageData2

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    await fulfillment(of: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, testImageData2)
    XCTAssertEqual(lastForecast?.periods[2].iconData, testImageData2)
    XCTAssertEqual(mockWeatherDataProvider.fetchWeatherIconIconIdentifier.count, 0)
  }

  var testFetchPeriodicWeatherForecastReturnTest: PeriodicWeatherForecast {
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

  var testFetchPeriodicWeatherForecastReturnTestForCacheTest1: PeriodicWeatherForecast {
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

  var testImageData1: Data {
    "image_data1".data(using: .utf8)!
  }
  
  var testImageData2: Data {
    "image_data2".data(using: .utf8)!
  }
}

class WeatherInfoBusinessLogicDelegateTestImpl: WeatherInfoBusinessLogicDelegate {
  
  var periodicWeatherForecasts: [PeriodicWeatherForecast] = []
  var weatherInfoBusinessLogicDidFetchTestCallback: () -> Void = {}
  func weatherInfoBusinessLogicDidFetch(periodicWeatherForecast: PeriodicWeatherForecast) {
    periodicWeatherForecasts.append(periodicWeatherForecast)
    weatherInfoBusinessLogicDidFetchTestCallback()
  }
  
  var errors: [Error] = []
  var weatherInfoBusinessLogicErrorTestCallback: () -> Void = {}
  func weatherInfoBusinessLogicError(_ error: Error) {
    errors.append(error)
    weatherInfoBusinessLogicErrorTestCallback()
  }
}

class MockWeatherDataProvider: WeatherDataProvider {
  
  var fetchPeriodicWeatherForecastCityName: String?
  var fetchPeriodicWeatherForecastError: Error?
  var fetchPeriodicWeatherForecastReturn: PeriodicWeatherForecast!
  func fetchPeriodicWeatherForecast(cityName: String) async throws -> PeriodicWeatherForecast {
    fetchPeriodicWeatherForecastCityName = cityName
    if let fetchPeriodicWeatherForecastError {
      throw fetchPeriodicWeatherForecastError
    }
    return fetchPeriodicWeatherForecastReturn;
  }
  
  var fetchWeatherIconIconIdentifier: [String] = []
  var fetchWeatherIconError: Error?
  var fetchWeatherIconReturn: [String: Data] = [:]
  func fetchWeatherIcon(iconIdentifier: String) async throws -> Data {
    fetchWeatherIconIconIdentifier.append(iconIdentifier)
    if let fetchWeatherIconError {
      throw fetchWeatherIconError
    }
    return fetchWeatherIconReturn[iconIdentifier]!
  }
}
