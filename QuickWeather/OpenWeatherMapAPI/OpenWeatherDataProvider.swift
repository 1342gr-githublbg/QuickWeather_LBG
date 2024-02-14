//
//  WeatherInfoDataProvider.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 14/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

class OpenWeatherMapAPIDataProvider {
  
  private let openWeatherMapAPI: OpenWeatherMapAPI

  init(
    restDataProvider: RestDataProvider,
    apiKey: String,
    iconMultiplier: String
  ) {
    openWeatherMapAPI = OpenWeatherMapAPI(
      restDataProvider: restDataProvider,
      apiKey: apiKey,
      iconMultiplier: iconMultiplier
    )
  }
}

extension OpenWeatherMapAPIDataProvider: WeatherDataProvider {
  
  
  func fetchPeriodicWeatherForecast(cityName: String) async throws -> PeriodicWeatherForecast {
    let openWeatherMap5Days3HoursForecast 
      = try await openWeatherMapAPI.fetch5Days3HoursForecast(city: cityName)
    return PeriodicWeatherForecast(
      periods: openWeatherMap5Days3HoursForecast.list.map({ (openWeatherMapForecastItem) in
        WeatherForecastPeriod(
          temperature: openWeatherMapForecastItem.main.temp,
          date: Date(timeIntervalSince1970: TimeInterval(openWeatherMapForecastItem.dt)),
          iconIdentifier: openWeatherMapForecastItem.weather.first?.icon
        )
      })
    )
  }

  func fetchWeatherIcon(iconIdentifier: String) async throws -> Data {
    return try await openWeatherMapAPI.fetchIconData(iconIdentifier: iconIdentifier)
  }
}
