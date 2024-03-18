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
  private var iconCache: IconCache!
  private var weatherInfoBusinessLogic: WeatherInfoBusinessLogic!
  
  override func setUp() {
    mockWeatherDataProvider = MockWeatherDataProvider()
    iconCache = IconCache()
    weatherInfoBusinessLogic = WeatherInfoBusinessLogic(
      weatherDataProvider: mockWeatherDataProvider,
      iconCache: iconCache
    )
  }
  
  func test_fetchWeatherInfo() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "delegate method has been called")
    expectation.assertForOverFulfill = false
    
    mockWeatherDataProvider.setupWithBasicResponse()
    
    Task {
      let forecastStream = weatherInfoBusinessLogic.fetchWeatherForecast(cityName: cityName)
      for try await _ in forecastStream {
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 3)
  }
  
  func test_fetchWeatherInfo_withIcons() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "async stream has finished")
    
    mockWeatherDataProvider.setupWithBasicResponse()

    Task {
      let forecastStream = weatherInfoBusinessLogic.fetchWeatherForecast(cityName: cityName)
      var lastForecast: PeriodicWeatherForecast? = nil
      for try await forecast in forecastStream {
        lastForecast = forecast
      }
      XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
      XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 3)
  }

  func test_fetchWeatherInfo_cacheTest1() throws {
    let cityName = "Leeds"
    
    let expectation = self.expectation(description: "async stream has finished")
    
    mockWeatherDataProvider.setupWithForcastPreriodsWithIdenticalIcons()
    
    Task {
      let forecastStream = weatherInfoBusinessLogic.fetchWeatherForecast(cityName: cityName)
      var lastForecast: PeriodicWeatherForecast? = nil
      for try await forecast in forecastStream {
        lastForecast = forecast
      }
      
      XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
      XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
      XCTAssertEqual(lastForecast?.periods[2].iconData, mockWeatherDataProvider.testImageData2)
      
      mockWeatherDataProvider.assertIconRequest(count: 2)
      
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 3)
  }

  func test_fetchWeatherInfo_cacheTest2() async throws {
    let cityName = "Leeds"
    
    await iconCache.set(icon: mockWeatherDataProvider.testImageData1, key: "iid1")
    await iconCache.set(icon: mockWeatherDataProvider.testImageData2, key: "iid2")

    let expectation = self.expectation(description: "delegate method has been called")
    expectation.assertForOverFulfill = false
    
    mockWeatherDataProvider.setupWithForcastPreriodsWithIdenticalIcons()

    Task {
      let forecastStream = weatherInfoBusinessLogic.fetchWeatherForecast(cityName: cityName)
      var lastForecast: PeriodicWeatherForecast? = nil
      for try await forecast in forecastStream {
        lastForecast = forecast
      }

      XCTAssertEqual(lastForecast?.periods[0].iconData, mockWeatherDataProvider.testImageData1)
      XCTAssertEqual(lastForecast?.periods[1].iconData, mockWeatherDataProvider.testImageData2)
      XCTAssertEqual(lastForecast?.periods[2].iconData, mockWeatherDataProvider.testImageData2)
      
      mockWeatherDataProvider.assertIconRequest(count: 0)

      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation], timeout: 3)
  }
}
