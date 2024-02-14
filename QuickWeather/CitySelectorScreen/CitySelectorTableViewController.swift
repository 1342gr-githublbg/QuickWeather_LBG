//
//  CitySelectorTableViewController.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 15/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

protocol CitySelectorTableViewControllerDelegate: AnyObject {
  func createWeatherInfoScreen(cityName: String) -> UIViewController
}

/// Lets the user select the city for which the weather forecast is displayed. This is not the
/// final version though and there is certainly room for further development and improvements.
class CitySelectorTableViewController: UITableViewController {

  weak var delegate: CitySelectorTableViewControllerDelegate?
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    guard 
      let cityName = cell?.textLabel?.text,
      let vewController = delegate?.createWeatherInfoScreen(cityName: cityName)
    else { return }
    navigationController?.pushViewController(vewController, animated: true)
  }
}

