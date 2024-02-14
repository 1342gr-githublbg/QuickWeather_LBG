//
//  URLSessionWrapperAdaptorTests.swift
//  QuickWeatherTests
//
//  Created by Gabriel Radu on 12/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import XCTest
@testable import QuickWeather

class URLSessionWrapperAdaptorTests: XCTestCase {
  
  var urlSessionWrapperAdaptor: URLSessionWrapperImpl!
  
  override func setUp() {
    urlSessionWrapperAdaptor = URLSessionWrapperImpl()
  }
  
  func test_dataTaskRequestCompletionHandler() async throws {
    
    let (_, response) = try await urlSessionWrapperAdaptor.dataTask(
      request: URLRequest(url: URL(string: "https://httpbin.org/get")!)
    )
    XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
  }
  
}
