//
//  IconTemperatureTimeCollectionViewCell.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 13/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

class IconTemperatureTimeCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private var icon: UIImageView!
  @IBOutlet private var temperature: UILabel!
  @IBOutlet private var time: UILabel!
  
  func update(dataSource: IconTemperatureTimeCollectionViewCellDataSource) {
    icon.image = dataSource.icon
    temperature.text = dataSource.temperature
    time.text = dataSource.time
  }
}

protocol IconTemperatureTimeCollectionViewCellDataSource {
  var icon: UIImage? { get }
  var temperature: String { get }
  var time: String { get }
}
