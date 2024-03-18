//
//  WeatherInfoInteractorsTests.swift
//  QuickWeatherTests
//
//  Created by Gabe on 18.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import XCTest
@testable import QuickWeather

final class WeatherInfoInteractorsTests: XCTestCase {
  
  private var mockWeatherDataProvider: MockWeatherDataProvider!
  private var iconCache: IconCache!
  private var interactorFactory: InteractorFactory!
  private var interactor: WeatherInfoInteractor!
  
  override func setUpWithError() throws {
    mockWeatherDataProvider = MockWeatherDataProvider()
    iconCache = IconCache()
    interactorFactory = InteractorFactory(weatherDataProvider: mockWeatherDataProvider, iconCache: iconCache)
    interactor = interactorFactory.createWeatherInfoInteractor()
  }
    
  func test() throws {
    mockWeatherDataProvider.setupWithPeriodicWeatherForecastForMultiplePeriodsPerDay()
    
    let expectation = expectation(description: "async stream finished")
    
    Task {
      let asyncStream = interactor.fetchGroupedWeatherForecast(cityName: "Munich")
      var lastWeatherInfo: WeatherInfoInteractor.GroupedWeatherForecast?
      for try await weatherInfo in asyncStream {
        lastWeatherInfo = weatherInfo
      }
      XCTAssertEqual(lastWeatherInfo?.keys.count, 3)
      XCTAssertEqual(lastWeatherInfo?[mockWeatherDataProvider.dates[0].day]?.count, 3)
      XCTAssertEqual(lastWeatherInfo?[mockWeatherDataProvider.dates[1].day]?.count, 2)
      XCTAssertEqual(lastWeatherInfo?[mockWeatherDataProvider.dates[2].day]?.count, 1)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 3)
  }
}

private extension Date {
  var day: Date {
    let dateComponents
      = Calendar.current.dateComponents([.day, .month, .year], from: self)
    guard let dayDate = Calendar.current.date(from: dateComponents) else {
      fatalError("WeatherInfoInteractor.fetchWeatherInfo(): Could not find the day of a date.")
    }
    return dayDate

  }
}
