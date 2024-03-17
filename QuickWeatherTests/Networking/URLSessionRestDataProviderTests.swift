//
//  URLSessionRestDataProviderTests.swift
//  QuickWeatherTests
//
//  Created by Gabriel Radu on 12/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import XCTest
@testable import QuickWeather

class URLSessionRestDataProviderTests: XCTestCase {
  
  
  private var mockURLSessionWrapper: MockURLSessionWrapper!
  private var urlSessionRestDataProvider: RestDataProviderImpl!
  
  private let testURL = URL(string: "http://example.com")!

  override func setUp() {
    mockURLSessionWrapper = MockURLSessionWrapper()
    urlSessionRestDataProvider = RestDataProviderImpl(urlSessionWrapper: mockURLSessionWrapper)
  }
  
  func test_getURLCompletionHandler_statusCode200() async throws {
    
    let responseStatusCode = 200
    mockURLSessionWrapper.setupWithResponse(url: testURL, statusCode: responseStatusCode)
    
    let restDataProviderResponse = try await urlSessionRestDataProvider.get(url: testURL)
    
    mockURLSessionWrapper.assertRequest(url: testURL, httpMethod: "GET")
    
    XCTAssertEqual(restDataProviderResponse.statusCode, responseStatusCode)
    XCTAssertEqual(restDataProviderResponse.body, mockURLSessionWrapper.responseBody)
  }
  
  func test_getURLCompletionHandler_statusCode400() async throws {
    
    let responseStatusCode = 400
    mockURLSessionWrapper.setupWithResponse(url: testURL, statusCode: responseStatusCode)

    do {
      let _ = try await urlSessionRestDataProvider.get(url: testURL)
    } catch let error as RestDataProviderError {
      switch error {
      case .errorStatusCode(let restDataProviderResponse):
        XCTAssertEqual(restDataProviderResponse.statusCode, responseStatusCode)
        XCTAssertEqual(restDataProviderResponse.body, mockURLSessionWrapper.responseBody)
      case .error(_):
        XCTFail()
      }
    }

    mockURLSessionWrapper.assertRequest(url: testURL, httpMethod: "GET")
  }
  
  func test_getURLCompletionHandler_withUnderlyingError() async {
    
    mockURLSessionWrapper.setupWithError()

    do {
      let _ = try await urlSessionRestDataProvider.get(url: testURL)
      XCTFail("urlSessionRestDataProvider.get(url: testURL) must throw")
    } catch {
      XCTAssert((error as? FakeError) === mockURLSessionWrapper.fakeError)
    }
  }
}
