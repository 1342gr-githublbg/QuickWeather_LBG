//
//  WeatherInfoViewModel.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 13/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

protocol WeatherInfoViewModelDelegate: AnyObject {
  func viewModelDidUpdate()
  func viewModelError(_ error: Error)
}

class WeatherInfoViewModel {

  var cityName: String

  private var weatherInfoBusinessLogic: WeatherInfoBusinessLogic {
    willSet { weatherInfoBusinessLogic.delegate = nil }
    didSet { weatherInfoBusinessLogic.delegate = self }
  }

  var dayViewModels: [WeatherInfoDayViewModel] = []
  weak var delegate: WeatherInfoViewModelDelegate?

  private let periodicWeatherForecastConverter = PeriodicWeatherForecastConverter()
  private let updateDispatchQueue = DispatchQueue(label: "WeatherInfoViewModel.updateDispatchQueue")

  init(weatherInfoBusinessLogic: WeatherInfoBusinessLogic, cityName: String) {
    self.cityName = cityName
    self.weatherInfoBusinessLogic = weatherInfoBusinessLogic
    weatherInfoBusinessLogic.delegate = self
  }

  func dayViewModel(indexPath: IndexPath) -> WeatherInfoDayViewModel {
    return dayViewModels[indexPath.section]
  }

  func iconTemperatureTimeViewModel(
    indexPath: IndexPath
  ) -> WeatherInfoIconTemperatureTimeViewModel {
    return dayViewModels[indexPath.section].iconTemperatureTimeViewModel[indexPath.row]
  }
  
  func update() {
    weatherInfoBusinessLogic.fetchWeatherInfo(cityName: cityName)
  }
}

extension WeatherInfoViewModel: WeatherInfoBusinessLogicDelegate {

  func weatherInfoBusinessLogicDidFetch(periodicWeatherForecast: PeriodicWeatherForecast) {
    updateDispatchQueue.async {
      self.dayViewModels = self.periodicWeatherForecastConverter.convert(
        periodicForecast: periodicWeatherForecast
      )
      self.delegate?.viewModelDidUpdate()
    }
  }

  func weatherInfoBusinessLogicError(_ error: Error) {
    DispatchQueue.main.async {
      self.delegate?.viewModelError(error)
    }
  }

}

// MARK: - WeatherInfoViewModel Utilities

extension WeatherInfoViewModel {
  private struct PeriodicWeatherForecastConverter {

    private let keyDateFormatter: DateFormatter 
      = PeriodicWeatherForecastConverter.createDateFormatter(dateFormat: "yyyy.MM.dd")
    private let dayDateFormatter: DateFormatter 
      = PeriodicWeatherForecastConverter.createDateFormatter(dateFormat: "EEEE dd/MM/yyyy")
    private let timeDateFormatter: DateFormatter 
      = PeriodicWeatherForecastConverter.createDateFormatter(dateFormat: "HH:mm")

    private static func createDateFormatter(dateFormat: String) -> DateFormatter {
      let formatter = DateFormatter()
      formatter.dateFormat = dateFormat
      return formatter
    }

    func convert(periodicForecast: PeriodicWeatherForecast) -> [WeatherInfoDayViewModel] {

      let dayViewModelDictionary = periodicForecast.periods
        .sorted(by: weatherForecastPeriodComparator)
        .reduce([String: WeatherInfoDayViewModel](), reducer)

      return dayViewModelDictionary.keys.sorted().map { (key) in
        dayViewModelDictionary[key]!
      }
    }

    private func weatherForecastPeriodComparator(
      period1: WeatherForecastPeriod,
      period2: WeatherForecastPeriod
    ) -> Bool {
      return period1.date <= period2.date
    }

    private func reducer(
      dayViewModelDictionary: [String: WeatherInfoDayViewModel],
      weatherForecastPeriod: WeatherForecastPeriod
    ) -> [String: WeatherInfoDayViewModel] {

      var dictionary = dayViewModelDictionary
      let dictionaryKey = keyDateFormatter.string(from: weatherForecastPeriod.date)
      var weatherInfoDayViewModel = dictionary[dictionaryKey]
        ?? WeatherInfoDayViewModel(date: dayDateFormatter.string(from: weatherForecastPeriod.date))

      weatherInfoDayViewModel.iconTemperatureTimeViewModel.append(
        WeatherInfoIconTemperatureTimeViewModel(
          icon: weatherForecastPeriod.iconData.flatMap { UIImage(data: $0) },
          temperature: "\(Int(weatherForecastPeriod.temperature))℃",
          time: timeDateFormatter.string(from: weatherForecastPeriod.date),
          date: keyDateFormatter.string(from: weatherForecastPeriod.date)
        )
      )

      dictionary[dictionaryKey] = weatherInfoDayViewModel

      return dictionary
    }
  }
}

// MARK: - WeatherInfoDayViewModel

struct WeatherInfoDayViewModel {
  var date: String
  var iconTemperatureTimeViewModel: [WeatherInfoIconTemperatureTimeViewModel] = []
}

extension WeatherInfoDayViewModel: Hashable {
  func hash(into hasher: inout Hasher) {
    date.hash(into: &hasher)
  }
  static func == (lhs: WeatherInfoDayViewModel, rhs: WeatherInfoDayViewModel) -> Bool {
    return lhs.date == rhs.date
  }
}

// MARK: - WeatherInfoIconTemperatureTimeViewModel

struct WeatherInfoIconTemperatureTimeViewModel {
  var icon: UIImage?
  var temperature: String
  var time: String
  var date: String
}

extension WeatherInfoIconTemperatureTimeViewModel: Hashable {
  var dateTime: String { date + time }
  func hash(into hasher: inout Hasher) {
    dateTime.hash(into: &hasher)
  }
  static func == (
    lhs: WeatherInfoIconTemperatureTimeViewModel,
    rhs: WeatherInfoIconTemperatureTimeViewModel
  ) -> Bool {
    return lhs.dateTime == rhs.dateTime && lhs.icon === rhs.icon
  }
}
