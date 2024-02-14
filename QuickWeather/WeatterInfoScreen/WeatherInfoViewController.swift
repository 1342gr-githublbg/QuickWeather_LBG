//
//  WeatherInfoViewController.swift
//  QuickWeather
//
//  Created by Gabriel Radu on 11/12/2019.
//  Copyright © 2019 Gabriel Radu. All rights reserved.
//

import UIKit

class WeatherInfoViewController: UICollectionViewController {
  
  var dataSource: UICollectionViewDiffableDataSource<WeatherInfoDayViewModel, WeatherInfoIconTemperatureTimeViewModel>! = nil
  var viewModel: WeatherInfoViewModel!
  
  var alertController: UIAlertController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView?.collectionViewLayout = createCollectionViewLayout()
    collectionView?.dataSource = createDataSource()
    viewModel.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.update()
  }
  
  func createDataSource(
  ) -> UICollectionViewDiffableDataSource<WeatherInfoDayViewModel, WeatherInfoIconTemperatureTimeViewModel> {
    dataSource 
      = UICollectionViewDiffableDataSource<WeatherInfoDayViewModel, WeatherInfoIconTemperatureTimeViewModel>(
      collectionView: collectionView) {
        [weak self] (
          collectionView: UICollectionView,
          indexPath: IndexPath,
          identifier: WeatherInfoIconTemperatureTimeViewModel
        ) -> UICollectionViewCell? in
        
        guard
          let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "IconTemperatureTimeCollectionViewCell",
            for: indexPath
          ) as? IconTemperatureTimeCollectionViewCell
        else {
          fatalError("Cannot create new cell")
        }
        guard let self = self else { return cell }
        
        cell.update(dataSource: self.viewModel.iconTemperatureTimeViewModel(indexPath: indexPath))
        return cell
      }
    dataSource.supplementaryViewProvider = { [weak self] (
      collectionView: UICollectionView,
      kind: String,
      indexPath: IndexPath
    ) -> UICollectionReusableView? in
      
      guard let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: "DateCollectionReusableView",
        for: indexPath
      ) as? DateCollectionReusableView
      else {
        fatalError("Cannot create new header")
      }
      guard let self = self else { return header }
      
      header.update(dataSource: self.viewModel.dayViewModel(indexPath: indexPath))
      return header
    }
    return dataSource
  }
  
  func applySnapshot(
    weatherInfoDayViewModels: [WeatherInfoDayViewModel],
    animatingDifferences: Bool = false
  ) {
    var snapshot = NSDiffableDataSourceSnapshot<WeatherInfoDayViewModel, WeatherInfoIconTemperatureTimeViewModel>()
    weatherInfoDayViewModels.forEach { (weatherInfoDayViewModel) in
      snapshot.appendSections([weatherInfoDayViewModel])
      snapshot.appendItems(weatherInfoDayViewModel.iconTemperatureTimeViewModel)
    }
    dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
  }
  
  func createCollectionViewLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(20)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top)
      
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(100),
          heightDimension: .estimated(100)
        )
      )
      item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
        leading: .fixed(1),
        top: .fixed(1),
        trailing: .fixed(1),
        bottom: .fixed(1)
      )
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .estimated(100),
          heightDimension: .estimated(100)
        ),
        subitems: [item])
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]
      section.orthogonalScrollingBehavior = .continuous
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: 16,
        bottom: 0,
        trailing: 16
      )
      
      return section
    }
  }
}

extension WeatherInfoViewController: WeatherInfoViewModelDelegate {
  
  func viewModelDidUpdate() {
    self.applySnapshot(weatherInfoDayViewModels: self.viewModel.dayViewModels)
  }
  
  func viewModelError(_ error: Error) {
    guard alertController == nil else { return }
    let alertController = UIAlertController(
      title: "Error",
      message: "A problem has occurred. Perhaps a glitch in the network communication.",
      preferredStyle: .alert
    )
    self.alertController = alertController
    alertController.addAction(
      UIAlertAction(
        title: "Reload",
        style: .default,
        handler: { [weak self] (_) in
          self?.viewModel.update()
        }
      )
    )
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
    }))
    present(alertController, animated: true) { [weak self] in
      self?.alertController = nil
    }
  }
  
}

extension WeatherInfoDayViewModel: DateCollectionReusableViewDataSource {
}
extension WeatherInfoIconTemperatureTimeViewModel: IconTemperatureTimeCollectionViewCellDataSource {
}
