//
//  WeatherInfoViewModelTests.swift
//  QuickWeatherTests
//
//  Created by Gabriel Radu on 14/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import XCTest
@testable import QuickWeather

class WeatherInfoViewModelTests: XCTestCase {

  private var mockWeatherInfoViewModelDelegate: MockWeatherInfoViewModelDelegate!
  private var mockWeatherInfoBusinessLogic: MockWeatherInfoBusinessLogic!
  private var weatherInfoViewModel: WeatherInfoViewModel!

  override func setUp() {
    mockWeatherInfoViewModelDelegate = MockWeatherInfoViewModelDelegate()
    mockWeatherInfoBusinessLogic = MockWeatherInfoBusinessLogic()
    weatherInfoViewModel = WeatherInfoViewModel(
      weatherInfoBusinessLogic: mockWeatherInfoBusinessLogic,
      cityName: "test city"
    )
    weatherInfoViewModel.delegate = mockWeatherInfoViewModelDelegate
  }

  func test_update_fromBusinessObjects() {

    let periodicForecast = PeriodicWeatherForecast(periods: [
      WeatherForecastPeriod(
        temperature: 20.0,
        date: Date(timeIntervalSince1970: 1576324800),
        iconIdentifier: "test icon identifier 1"
      ),
      WeatherForecastPeriod(
        temperature: 25.5,
        date: Date(timeIntervalSince1970: 1576335600),
        iconIdentifier: "test icon identifier 2"
      ),
      WeatherForecastPeriod(
        temperature: 27.0,
        date: Date(timeIntervalSince1970: 1576411200),
        iconIdentifier: "test icon identifier 3"
      ),
    ])

    let expectation = self.expectation(description: "update method finishes")
    mockWeatherInfoViewModelDelegate.viewModelDidUpdateBlock = {
      expectation.fulfill()
    }
    mockWeatherInfoBusinessLogic.fetchWeatherInfoBlock = { (cityName) in
      XCTAssertEqual(cityName, "test city")
      self.mockWeatherInfoBusinessLogic.delegate?.weatherInfoBusinessLogicDidFetch(
        periodicWeatherForecast: periodicForecast
      )
    }
    weatherInfoViewModel.update()
    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(weatherInfoViewModel.dayViewModels.count, 2)
    XCTAssertEqual(weatherInfoViewModel.dayViewModels[0].iconTemperatureTimeViewModel.count, 2)
    XCTAssertEqual(weatherInfoViewModel.dayViewModels[0].date, "Saturday 14/12/2019")
    XCTAssertEqual(weatherInfoViewModel.dayViewModels[1].iconTemperatureTimeViewModel.count, 1)
    XCTAssertEqual(weatherInfoViewModel.dayViewModels[1].date, "Sunday 15/12/2019")
  }

}

private class MockWeatherInfoViewModelDelegate: WeatherInfoViewModelDelegate {

  func viewModelError(_ error: Error) {
  }

  var viewModelDidUpdateBlock: (() -> Void)!
  func viewModelDidUpdate() {
    viewModelDidUpdateBlock()
  }
}

private class MockWeatherInfoBusinessLogic: WeatherInfoBusinessLogic {
  weak var delegate: WeatherInfoBusinessLogicDelegate?
  var fetchWeatherInfoBlock: ((String) -> Void)!
  func fetchWeatherInfo(cityName: String) {
    fetchWeatherInfoBlock(cityName)
  }
}
