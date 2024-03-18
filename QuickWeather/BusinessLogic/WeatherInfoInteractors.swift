//
//  WeatherInfoInteractors.swift
//  QuickWeather
//
//  Created by Gabe on 18.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import Foundation

/// Provides a weather forecast grouped per day
class WeatherInfoInteractor {
  
  typealias GroupedWeatherForecast = [Date: [WeatherForecastPeriod]]
  
  let businessLogic: WeatherInfoBusinessLogic
  
  init(businessLogic: WeatherInfoBusinessLogic) {
    self.businessLogic = businessLogic
  }
  
  
  /// Profides a weather forecast grouped per day.
  /// - Parameter cityName: The city for wihich the forecast will be provided
  /// - Returns: Async sttream that provides the grouped data. First element is likely to lack weather icons, the rest will have increasingly more icons.
  func fetchGroupedWeatherForecast(
    cityName: String
  ) -> AsyncThrowingStream<GroupedWeatherForecast, Error> {
    AsyncThrowingStream<GroupedWeatherForecast, Error> { continuation in
      Task {
        do {
          for try await periodicForecast in businessLogic.fetchWeatherForecast(cityName: cityName) {
            continuation.yield(convert(periodicForecast: periodicForecast))
          }
        } catch {
          continuation.finish(throwing: error)
        }
        continuation.finish()
      }
    }
  }
  
  
  private func convert(periodicForecast: PeriodicWeatherForecast) -> GroupedWeatherForecast {
    periodicForecast.periods
      .sorted(by: weatherForecastPeriodComparator)
      .reduce([Date: [WeatherForecastPeriod]](), reducer)
  }

  private func weatherForecastPeriodComparator(
    period1: WeatherForecastPeriod,
    period2: WeatherForecastPeriod
  ) -> Bool {
    return period1.date <= period2.date
  }

  private func reducer(
    dayViewModelDictionary: GroupedWeatherForecast,
    weatherForecastPeriod: WeatherForecastPeriod
  ) -> [Date: [WeatherForecastPeriod]] {

    var dictionary = dayViewModelDictionary
    let dictionaryKey = {
      let dateComponents 
        = Calendar.current.dateComponents([.day, .month, .year], from: weatherForecastPeriod.date)
      guard let dayDate = Calendar.current.date(from: dateComponents) else {
        fatalError("WeatherInfoInteractor.fetchWeatherInfo(): Could not find the day of a date.")
      }
      return dayDate
    }()
    var weatherForecastPeriods = dictionary[dictionaryKey] ?? []

    weatherForecastPeriods.append(weatherForecastPeriod)

    dictionary[dictionaryKey] = weatherForecastPeriods
    return dictionary
  }

}

class InteractorFactory {
  
  let businessLogic: WeatherInfoBusinessLogic
  
  init(weatherDataProvider: WeatherDataProvider, iconCache: IconCache) {
    self.businessLogic = WeatherInfoBusinessLogic(weatherDataProvider: weatherDataProvider, iconCache: iconCache)
  }
  
  func createWeatherInfoInteractor() -> WeatherInfoInteractor {
    WeatherInfoInteractor(businessLogic: businessLogic)
  }
}
