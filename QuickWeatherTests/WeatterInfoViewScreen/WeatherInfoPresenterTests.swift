//
//  WeatherInfoPresenterTests.swift
//  QuickWeatherTests
//
//  Created by Gabe on 18.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import XCTest
import Combine
@testable import QuickWeather

final class WeatherInfoPresenterTests: XCTestCase {
  
  private var mockWeatherDataProvider: MockWeatherDataProvider!
  private var iconCache: IconCache!
  private var interactorFactory: InteractorFactory!

  private var weatherInfoPresenter: WeatherInfoPresenterImpl!
  
  override func setUpWithError() throws {
    
    mockWeatherDataProvider = MockWeatherDataProvider()
    iconCache = IconCache()
    interactorFactory = InteractorFactory(weatherDataProvider: mockWeatherDataProvider, iconCache: iconCache)

  }
  

  func testWeatherInfoPresenterImpl() throws {
    
    mockWeatherDataProvider.setupWithPeriodicWeatherForecastForMultiplePeriodsPerDay()

    weatherInfoPresenter = WeatherInfoPresenterImpl(
      weatherInfoInteractor: interactorFactory.createWeatherInfoInteractor(),
      cityName: "London"
    )

    let expectation = expectation(description: "async stream finished")
    expectation.assertForOverFulfill = false
    
    var cancellables: Set<AnyCancellable> = []
    weatherInfoPresenter.objectWillChange.sink {
      if self.weatherInfoPresenter.viewModel != nil {
        expectation.fulfill()
      }
    }.store(in: &cancellables)
    
    wait(for: [expectation], timeout: 3)
    
    XCTAssertEqual(weatherInfoPresenter.viewModel?.count, 3)
    XCTAssertEqual(weatherInfoPresenter.viewModel?[0].date, "Friday 02/01/1970")
    XCTAssertEqual(weatherInfoPresenter.viewModel?[0].hours[0].time, "01:00")
    XCTAssertEqual(weatherInfoPresenter.viewModel?[0].hours[1].time, "04:00")
    XCTAssertEqual(weatherInfoPresenter.viewModel?[1].date, "Saturday 03/01/1970")
    XCTAssertEqual(weatherInfoPresenter.viewModel?[1].hours[0].time, "01:00")
    XCTAssertEqual(weatherInfoPresenter.viewModel?[1].hours[1].time, "04:00")
  }
}
