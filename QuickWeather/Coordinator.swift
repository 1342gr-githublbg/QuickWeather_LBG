//
//  AppContext.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 14/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

class Coordinator {

  enum Constants {
    static let apiKey = "insert_your_key_here"
    static let resourceName = "5days_3hour_forecast_data"
    static let mainStoryboardName = "Main"
    static let weatherInfoScreenViewControllerId = "WeatherInfoViewController"
  }

  private let iconCache = IconCache()
  
  private lazy var mainStoryBoard = {
    UIStoryboard(name: Constants.mainStoryboardName, bundle: Bundle.main)
  }()

  private func weatherInfoBusinessLogic(useLocalFiles: Bool) -> WeatherInfoBusinessLogic {
    let openWeatherMapAPIDataProvider = OpenWeatherMapAPIDataProvider(
      restDataProvider: RestDataProviderImpl(
        urlSessionWrapper: useLocalFiles ? LocalSessionWrapperImpl() : URLSessionWrapperImpl()
      ),
      apiKey: Constants.apiKey,
      iconMultiplier: findIconMultiplier()
    )
    return WeatherInfoBusinessLogicImplementation(
      weatherDataProvider: openWeatherMapAPIDataProvider,
      iconCache: useLocalFiles ? IconCache() : iconCache
    )
  }
  
  private func findIconMultiplier() -> String {
    switch Int(round(UIScreen.main.scale)) {
    case 3: return "@x3"
    case 2: return "@x2"
    default: return ""
    }
  }
}

extension Coordinator: CitySelectorTableViewControllerDelegate {
  func createWeatherInfoScreen(cityName: String) -> UIViewController {
    guard
      let viewController  = mainStoryBoard.instantiateViewController(
        withIdentifier: Constants.weatherInfoScreenViewControllerId
      ) as? WeatherInfoViewController
    else {
      fatalError("Could not create WeatherInfoViewController")
    }
    
    // For test purposes we are reading files from the bundle if the name of the city
    // is London (local)
    let useLocalFiles = cityName == "London (local)"
    
    viewController.viewModel = WeatherInfoViewModel(
      weatherInfoBusinessLogic: weatherInfoBusinessLogic(
        useLocalFiles: useLocalFiles
      ),
      cityName: cityName
    )
    return viewController
  }
}

