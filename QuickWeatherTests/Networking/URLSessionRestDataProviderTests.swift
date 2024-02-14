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
  
  let testURL = URL(string: "http://example.com")!
  let responseBody = Data(base64Encoded: "adfaafeaerga")!
  
  override func setUp() {
    mockURLSessionWrapper = MockURLSessionWrapper()
    urlSessionRestDataProvider = RestDataProviderImpl(urlSessionWrapper: mockURLSessionWrapper)
  }
  
  func test_getURLCompletionHandler_statusCode200() async throws {
    
    let responseStatusCode = 200
    
    mockURLSessionWrapper.dataTaskReturn = (
      self.responseBody,
      HTTPURLResponse(
        url: self.testURL,
        statusCode: responseStatusCode,
        httpVersion: nil,
        headerFields: nil
      )!
    )
    
    let restDataProviderResponse = try await urlSessionRestDataProvider.get(url: testURL)
    
    XCTAssertEqual(mockURLSessionWrapper.dataTaskRequest!.url, self.testURL)
    XCTAssertEqual(mockURLSessionWrapper.dataTaskRequest!.httpMethod, "GET")
    
    XCTAssertEqual(restDataProviderResponse.statusCode, responseStatusCode)
    XCTAssertEqual(restDataProviderResponse.body, self.responseBody)
  }
  
  func test_getURLCompletionHandler_statusCode400() async throws {
    
    let responseStatusCode = 400
    
    mockURLSessionWrapper.dataTaskReturn = (
      self.responseBody,
      HTTPURLResponse(
        url: self.testURL,
        statusCode: responseStatusCode,
        httpVersion: nil,
        headerFields: nil
      )!
    )
    
    do {
      let _ = try await urlSessionRestDataProvider.get(url: testURL)
    } catch let error as RestDataProviderError {
      switch error {
      case .errorStatusCode(let restDataProviderResponse):
        XCTAssertEqual(restDataProviderResponse.statusCode, responseStatusCode)
        XCTAssertEqual(restDataProviderResponse.body, self.responseBody)
      case .error(_):
        XCTFail()
      }
    }

    XCTAssertEqual(mockURLSessionWrapper.dataTaskRequest!.url, self.testURL)
    XCTAssertEqual(mockURLSessionWrapper.dataTaskRequest!.httpMethod, "GET")
  }
  
  func test_getURLCompletionHandler_withUnderlyingError() async {
    
    let fakeError = FakeError()

    mockURLSessionWrapper.dataTaskError = fakeError

    do {
      let _ = try await urlSessionRestDataProvider.get(url: testURL)
      XCTFail("urlSessionRestDataProvider.get(url: testURL) must throw")
    } catch {
      XCTAssert((error as? FakeError) === fakeError)
    }
  }
}

private class MockURLSessionWrapper: URLSessionWrapper {
  
  var dataTaskRequest: URLRequest?
  var dataTaskError: Error?
  var dataTaskReturn: (Data, URLResponse)!
  
  func dataTask(request: URLRequest) async throws -> (Data, URLResponse) {
    dataTaskRequest = request
    if let dataTaskError {
      throw dataTaskError
    }
    return dataTaskReturn
  }
}

private class FakeError: Error { }
