//
//  BusinessObjects.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 14/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

enum WeatherForecastError: Error {
  case recoverableError(underlyingErrors: [Error])
}

/// List of weather forecasts with each item of the list containing meteorologic data for a certain
/// point in time. The items are usually equally spaced in time. The time interval between can
/// be eg. 3 hours.
public struct PeriodicWeatherForecast {
  let periods: [WeatherForecastPeriod]
}

/// Contains meteorologic data for a certain point in time.
struct WeatherForecastPeriod {
  let iconData: Data?
  let temperature: Float
  let date: Date
  let iconIdentifier: String?
  init(iconData: Data? = nil,
       temperature: Float,
       date: Date,
       iconIdentifier: String?) {
    self.iconData = iconData
    self.temperature = temperature
    self.date = date
    self.iconIdentifier = iconIdentifier
  }
}

// MARK: -

/// Provides weather forecasts.
protocol WeatherDataProvider {

  /// Retrieves the weather forecast.
  /// - Parameters:
  ///   - cityName: The name of the city for which the weather forecast is requested.
  /// - Returns: The forecast.
  func fetchPeriodicWeatherForecast(cityName: String) async throws -> PeriodicWeatherForecast
  
  /// Creates an operation that provides weather icons.
  /// - Parameters:
  ///   - iconIdentifiers: A list of icon identifiers for which icons are required.
  /// - Returns: The data for the requested icon.
  func fetchWeatherIcon(iconIdentifier: String) async throws -> Data
}

// MARK: -

/// Caches images eg. wetter icons in a tread safe manner.
public actor IconCache {
  
  private let nsCache = NSCache<NSString, NSData>()
  
  
  /// Caches the given icon
  /// - Parameters:
  ///   - icon: The icon
  ///   - key: The key for the icon. This can be used to retrieve the icon from the cache.
  func set(icon: Data, key: String) {
    nsCache.setObject(icon as NSData, forKey: key as NSString)
  }
  
  /// Retrieves an image from the cache
  /// - Parameter key: The key. This must be the same as the one used when the image was inserted
  ///                  into the cache.
  /// - Returns: The cached image or nil if the image is not in the cache.
  func icon(key: String) -> Data? {
    return nsCache.object(forKey: key as NSString) as Data?
  }
}
