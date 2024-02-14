//
//  RestDataProvider.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 11/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import Foundation

public struct RestDataProviderResponse {
  let statusCode: Int
  let body: Data
}

enum RestDataProviderError: Error {
  case errorStatusCode(response: RestDataProviderResponse)
  case error(underlyingError: Error)
}

/// Generic abstraction for a REST service.
public protocol RestDataProvider {
  func get(url: URL) async throws -> RestDataProviderResponse
  // Post, put and delete method can be added in the future as needed.
}
