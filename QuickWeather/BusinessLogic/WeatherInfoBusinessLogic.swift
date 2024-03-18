//
//  WeatherInfoBusinessLogic.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 13/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

final class WeatherInfoBusinessLogic {

  private let weatherDataProvider: WeatherDataProvider
  private let iconCache: IconCache
  
  private var iconFetcher: IconFetcher?

  init(weatherDataProvider: WeatherDataProvider, iconCache: IconCache) {
    self.weatherDataProvider = weatherDataProvider
    self.iconCache = iconCache
  }

  func fetchWeatherForecast(cityName: String) -> AsyncThrowingStream<PeriodicWeatherForecast, Error> {
    AsyncThrowingStream<PeriodicWeatherForecast, Error> { continuation in
      Task {
        await iconFetcher?.cancelFetch()
        do {
          let forecast
            = try await weatherDataProvider.fetchPeriodicWeatherForecast(cityName: cityName)
          continuation.yield(forecast)
          let iconFetcher = IconFetcher(
            weatherDataProvider: weatherDataProvider,
            cache: iconCache,
            periodicWeatherForecast: forecast,
            continuation: continuation
          )
          self.iconFetcher = iconFetcher
          await iconFetcher.fetchIcons()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }
}

// MARK: -

private actor IconFetcher {
  
  typealias ContinuationType = AsyncThrowingStream<PeriodicWeatherForecast, Error>.Continuation
  
  private(set) var task: Task<Void, Never>?
  
  private var periodicWeatherForecast: PeriodicWeatherForecast
  private let continuation: ContinuationType
  
  private let weatherDataProvider: WeatherDataProvider
  private let cache: IconCache
  
  private var downloadsSet: Set<String> = []
  
  private var recoverableErrors: [Error] = []
  
  init(
    weatherDataProvider: WeatherDataProvider,
    cache: IconCache,
    periodicWeatherForecast: PeriodicWeatherForecast,
    continuation: ContinuationType
  ) {
    self.weatherDataProvider = weatherDataProvider
    self.cache = cache
    self.periodicWeatherForecast = periodicWeatherForecast
    self.continuation = continuation
  }
    
  func fetchIcons() {
    task = Task {
      await withTaskGroup(of: Void.self) { taskGroup in
        for period in periodicWeatherForecast.periods {
          if let iconId = period.iconIdentifier {
            taskGroup.addTask {
              if Task.isCancelled { return }
              await self.fetchIcon(iconId: iconId)
            }
          }
        }
      }
      if recoverableErrors.count > 0 {
        continuation.finish(throwing: WeatherForecastError.recoverableError(underlyingErrors: recoverableErrors))
      } else {
        continuation.finish()
      }
      task = nil
    }
  }
  
  func cancelFetch() {
    task?.cancel()
    task = nil
  }
  
  private func fetchIcon(iconId: String) async {
    if let cachedIcon = await cachedIcon(iconId: iconId) {
      if Task.isCancelled { return }
      setIconAndCallback(iconId: iconId, icon: cachedIcon)
      return
    }
    
    if downloadInProgress(iconId: iconId) {
      return
    }
    
    addToDownloadList(iconId: iconId)

    do {
      let iconData = try await weatherDataProvider.fetchWeatherIcon(iconIdentifier: iconId)
      await updateCache(iconId: iconId, icon: iconData)
      if Task.isCancelled { return }
      setIconAndCallback(iconId: iconId, icon: iconData)
    } catch {
      recoverableErrors.append(error)
    }
    
  }
  
  private func cachedIcon(iconId: String) async -> Data? {
    return await cache.icon(key: iconId)
  }
  
  private func updateCache(iconId: String, icon: Data) async {
    await cache.set(icon: icon, key: iconId)
  }
  
  private func downloadInProgress(iconId: String) -> Bool {
    return downloadsSet.contains(iconId)
  }
  
  private func addToDownloadList(iconId: String) {
    downloadsSet.insert(iconId)
  }
  
  private func setIconAndCallback(iconId: String, icon: Data) {
    let newPeriodicWeatherForecast = PeriodicWeatherForecast(
      periods: periodicWeatherForecast.periods.map { period in
        if period.iconIdentifier == iconId {
          return WeatherForecastPeriod(
            iconData: icon,
            temperature: period.temperature,
            date: period.date,
            iconIdentifier: period.iconIdentifier
          )
        }
        return period
      }
    )
    periodicWeatherForecast = newPeriodicWeatherForecast
    continuation.yield(periodicWeatherForecast)
  }
}
