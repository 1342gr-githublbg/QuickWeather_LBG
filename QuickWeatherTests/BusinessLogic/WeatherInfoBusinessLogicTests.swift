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
    
    mockWeatherDataProvider.setupWithBasicResponse()
    
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
    
    mockWeatherDataProvider.setupWithBasicResponse()

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    wait(for: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
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
    
    mockWeatherDataProvider.setupWithForcastPreriodsWithIdenticalIcons()
    
    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    wait(for: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
    XCTAssertEqual(lastForecast?.periods[2].iconData, mockWeatherDataProvider.testImageData2)
    
    mockWeatherDataProvider.assertIconRequest(count: 2)
  }

  func test_fetchWeatherInfo_cacheTest2() async throws {
    let cityName = "Leeds"
    
    await iconCache.set(icon: mockWeatherDataProvider.testImageData1, key: "iid1")
    await iconCache.set(icon: mockWeatherDataProvider.testImageData2, key: "iid2")

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
    
    mockWeatherDataProvider.setupWithForcastPreriodsWithIdenticalIcons()

    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
    
    await fulfillment(of: [expectation], timeout: 3)
    
    let lastForecast = self.delegate.periodicWeatherForecasts.last
    XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
    XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
    XCTAssertEqual(lastForecast?.periods[2].iconData, mockWeatherDataProvider.testImageData2)
    mockWeatherDataProvider.assertIconRequest(count: 0)
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

