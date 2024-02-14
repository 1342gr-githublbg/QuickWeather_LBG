//
//  URLSessionRestDataProvider.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 11/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

public final class RestDataProviderImpl {

  private let urlSessionWrapper: URLSessionWrapper
  
  public init(urlSessionWrapper: URLSessionWrapper) {
    self.urlSessionWrapper = urlSessionWrapper
  }
  
  public convenience init() {
    self.init(urlSessionWrapper: URLSessionWrapperImpl())
  }
}

extension RestDataProviderImpl: RestDataProvider {
  public func get(url: URL) async throws -> RestDataProviderResponse {
    let (data, response) = try await urlSessionWrapper.dataTask(request: URLRequest(url: url))
    
    guard let httpResponse = response as? HTTPURLResponse else {
      preconditionFailure("Response must be an HTTP Response.")
    }
    let restDataProviderResponse 
      = RestDataProviderResponse(statusCode: httpResponse.statusCode, body: data)
    if 200 <= httpResponse.statusCode && httpResponse.statusCode < 300 {
      return restDataProviderResponse
    }
    
    throw RestDataProviderError.errorStatusCode(response: restDataProviderResponse)
  }
}

// MARK: -

/// Abstracts the iOS URLSession, mostly for testing purposes.
public protocol URLSessionWrapper {
  func dataTask(request: URLRequest) async throws -> (Data, URLResponse)
}

/// Uses the URLSession to retrieve real data from the real API.
class URLSessionWrapperImpl: URLSessionWrapper {
  let urlSession = URLSession.shared
  public func dataTask(request: URLRequest) async throws -> (Data, URLResponse) {
    return try await urlSession.data(for: request)
  }
}


/// Retrieves data from fils store in bundle. For testing purposes only. The implementation of
/// this class could be improved.
class LocalSessionWrapperImpl: URLSessionWrapper {
  func dataTask(request: URLRequest) async throws -> (Data, URLResponse) {
    guard let url = request.url else {
      fatalError("Could not find local session wrapper url")
    }
    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: "2",
      headerFields: nil
    )
    
    if url.absoluteString.hasPrefix("https://api.openweathermap.org/data/2.5/forecast") {
      let jsonUrl = Bundle.main.url(forResource: "test_5days_3hour_forecast_data", withExtension: "json")
      guard let jsonUrl = jsonUrl else {
        fatalError("Could not decode URL")
      }
      let data = try? Data(contentsOf: jsonUrl)
      
      guard let response = response, let data = data else {
        fatalError("Could not create local session wrapper prerequisites")
      }
      
      return (data, response)
    }
    
    if url.absoluteString.hasPrefix("https://openweathermap.org/img/wn/") {
      
      let iconUrl = Bundle.main.url(forResource: "test_forecast_icon", withExtension: "png")
      guard let iconUrl = iconUrl else {
        fatalError("Could not decode URL")
      }
      let data = try? Data(contentsOf: iconUrl)
      
      guard let response = response, let data = data else {
        fatalError("Could not create local session wrapper prerequisites")
      }
      
      return (data, response)
    }
    
    fatalError("Unknown url received")
  }
}
