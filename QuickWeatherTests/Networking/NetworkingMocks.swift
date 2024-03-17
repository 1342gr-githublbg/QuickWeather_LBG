//
//  NetworkingMocks.swift
//  QuickWeatherTests
//
//  Created by Gabe on 17.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import Foundation
import XCTest
@testable import QuickWeather

class MockURLSessionWrapper: URLSessionWrapper {
  
  let responseBody = Data(base64Encoded: "adfaafeaerga")!
  let fakeError = FakeError()

  private var dataTaskRequest: URLRequest?
  private var dataTaskError: Error?
  private var dataTaskReturn: (Data, URLResponse)!
  
  func dataTask(request: URLRequest) async throws -> (Data, URLResponse) {
    dataTaskRequest = request
    if let dataTaskError {
      throw dataTaskError
    }
    return dataTaskReturn
  }
}

extension MockURLSessionWrapper {
  
  func setupWithResponse(url: URL, statusCode: Int) {
    dataTaskReturn = (
      self.responseBody,
      HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
      )!
    )
  }
  
  func setupWithError(_ error: Error? = nil) {
    dataTaskError = error ?? fakeError
  }
  
  func assertRequest(url: URL, httpMethod: String) {
    XCTAssertEqual(dataTaskRequest!.url, url)
    XCTAssertEqual(dataTaskRequest!.httpMethod, httpMethod)

  }
  
}

class FakeError: Error { }
