//
//  DateCollectionReusableView.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 13/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

class DateCollectionReusableView: UICollectionReusableView {
  @IBOutlet private var date: UILabel!

  func update(dataSource: DateCollectionReusableViewDataSource) {
    date.text = dataSource.date
  }
}

protocol DateCollectionReusableViewDataSource {
  var date: String { get }
}
