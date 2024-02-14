//
//  OpenWeatherMapAPI.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 12/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

class OpenWeatherMapAPI {
  
  let restDataProvider: RestDataProvider

  let apiKey: String
  let iconMultiplier: String

  init(restDataProvider: RestDataProvider, apiKey: String, iconMultiplier: String) {
    self.restDataProvider = restDataProvider
    self.apiKey = apiKey
    self.iconMultiplier = iconMultiplier
  }
}

extension OpenWeatherMapAPI {
  
  func fetch5Days3HoursForecast(city: String) async throws -> OpenWeatherMap5Days3HoursForecast {
    guard
      var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
    else {
      preconditionFailure("Open weather map URL must exist")
    }
    urlComponents.queryItems = [
      URLQueryItem(name: "q", value: city),
      URLQueryItem(name: "units", value: "metric"),
      URLQueryItem(name: "APPID", value: self.apiKey),
    ]
    guard let url = urlComponents.url else {
      preconditionFailure("Could not create url for 5 days 3 hour forecast")
    }
    
    let restDataProviderResult = try await self.restDataProvider.get(url: url)
    return try JSONDecoder().decode(
      OpenWeatherMap5Days3HoursForecast.self,
      from: restDataProviderResult.body
    )
  }

  func fetchIconData(iconIdentifier: String) async throws -> Data {
    guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconIdentifier).png") else {
      preconditionFailure("Open weather map URL must exist")
    }
    let restDAtaProviderResult = try await self.restDataProvider.get(url: url)
    return restDAtaProviderResult.body
  }
}

// MARK: -

public struct OpenWeatherMapForecastItem: Codable {
  
  public struct Main: Codable {
    var temp: Float // eg. 277.04,
  }
  
  public struct Weather: Codable {
    var main: String // eg. "Clouds"
    var description: String // eg. "scattered clouds"
    var icon: String // eg. "03n"
  }
  
  var dt: Int // Unix time stamp eg. 1576044000
  var main: Main
  var weather: [Weather]
}


public struct OpenWeatherMap5Days3HoursForecast: Codable {
  var list: [OpenWeatherMapForecastItem]  
}

// MARK: -

public protocol JsonDecodable {
  static func decodeFromJson(data: Data) throws -> Self
}

extension OpenWeatherMap5Days3HoursForecast: JsonDecodable {
  public static func decodeFromJson(data: Data) throws -> OpenWeatherMap5Days3HoursForecast {
    return try JSONDecoder().decode(OpenWeatherMap5Days3HoursForecast.self, from: data)
  }
}

extension Data: JsonDecodable {
  public static func decodeFromJson(data: Data) throws -> Data {
    return data
  }
}
