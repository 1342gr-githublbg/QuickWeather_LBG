//
//  WeatherInfoView.swift
//  QuickWeather
//
//  Created by Gabe on 17.03.24.
//  Copyright © 2024 Gabriel Radu. All rights reserved.
//

import SwiftUI

struct PeriodOf3HoursViewModel {
  let time: String
  let temperature: String
  let icon: Image?
}

struct DayViewModel {
  let date: String
  let hours: [PeriodOf3HoursViewModel]
}
  
struct WeatherInfoView: View {
  
  fileprivate struct PeriodOf3HoursView: View {
    let viewModel: PeriodOf3HoursViewModel
    var body: some View {
      VStack(alignment: .center) {
        if let icon = viewModel.icon {
          icon.frame(width: 24, height: 24)
        } else {
          Spacer(minLength: 24)
        }
        Text(viewModel.temperature)
        Text(viewModel.time)
      }
      .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
      .background(Color.blue.opacity(0.6))
    }
  }
  
  fileprivate struct DayView: View {
    let viewModel: DayViewModel
    var body: some View {
      VStack(alignment: .leading){
        Text(viewModel.date)
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 1) {
            ForEach(viewModel.hours, id: \.time) {
              PeriodOf3HoursView(viewModel: $0)
            }
          }
        }
      }
      .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
    }
  }
  
  fileprivate let viewModel: [DayViewModel]

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(viewModel, id: \.date) {
          DayView(viewModel: $0)
        }
      }
    }.padding()
  }
}

struct WeatherInfoScreen<P: WeatherInfoPresenter>: View {
  @ObservedObject
  var presenter: P
    
  var body: some View {
    ZStack {
      if let viewModel = presenter.viewModel {
        WeatherInfoView(viewModel: viewModel)
      } else {
        ProgressView()
      }
    }
    .alert("An error has occured", isPresented: $presenter.errorPresented) {
      Button("Cancel", role: .cancel) { }
    } message: {
      Text(presenter.errorDescription ?? "An unknown error has happned.")
    }
  }
}

protocol WeatherInfoPresenter: ObservableObject {
  var viewModel: [DayViewModel]? { get set }
  var errorPresented: Bool { get set }
  var errorDescription: String? { get set }
}

class WeatherInfoPresenterImpl: WeatherInfoPresenter {
  
  @Published
  var viewModel: [DayViewModel]?
  
  @Published
  var errorPresented: Bool = false
  
  @Published
  var errorDescription: String?
  
  let weatherInfoInteractor: WeatherInfoInteractor
  
  init(weatherInfoInteractor: WeatherInfoInteractor, cityName: String) {
    self.weatherInfoInteractor = weatherInfoInteractor
    let groupedWeatherForecastStream = weatherInfoInteractor.fetchGroupedWeatherForecast(cityName: cityName)
    Task {
      do {
        for try await groupedWeatherForecast in groupedWeatherForecastStream {
          await MainActor.run {
            viewModel = convert(groupedWeatherForecast: groupedWeatherForecast)
          }
        }
      } catch {
        await MainActor.run {
          errorDescription = error.localizedDescription
          errorPresented = true
        }
      }
    }
  }

  private func convert(
    groupedWeatherForecast: WeatherInfoInteractor.GroupedWeatherForecast
  ) -> [DayViewModel] {
    var dayViewModels: [DayViewModel] = []
    for (dayDate, day) in groupedWeatherForecast.sorted(by: { $0.0 < $1.0 }) {
      let formatedDayDate = dayDateFormatter.string(from: dayDate)
      let periods = day.map { period in
        let image = period.iconData.flatMap { UIImage(data: $0 )}
        return PeriodOf3HoursViewModel(
          time: timeDateFormatter.string(from: period.date),
          temperature: "\(Int(period.temperature))℃",
          icon: image.map { Image(uiImage: $0) }
        )
      }
      dayViewModels.append(.init(date: formatedDayDate, hours: periods))
    }
    return dayViewModels
  }
  
  private let dayDateFormatter: DateFormatter
    = WeatherInfoPresenterImpl.createDateFormatter(dateFormat: "EEEE dd/MM/yyyy")
  private let timeDateFormatter: DateFormatter
    = WeatherInfoPresenterImpl.createDateFormatter(dateFormat: "HH:mm")

  private static func createDateFormatter(dateFormat: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    return formatter
  }
}

// MARK: -

private class PreviewPresenterImpl: WeatherInfoPresenter {
  
  var errorPresented: Bool = false
  var errorDescription: String?
  
  @Published
  var viewModel: [DayViewModel]?
  
  init(viewModel: [DayViewModel]?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.viewModel = viewModel
    }
  }
}

#Preview {
  let viewModel: [DayViewModel] = [
    .init(date: "Wednesday 12/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
    .init(date: "Wednesday 13/12/2024", hours: [
      .init(time: "01:00", temperature: "4C", icon: nil),
      .init(time: "04:00", temperature: "5C", icon: nil),
      .init(time: "07:00", temperature: "6C", icon: nil),
      .init(time: "10:00", temperature: "7C", icon: nil),
      .init(time: "13:00", temperature: "8C", icon: nil),
      .init(time: "16:00", temperature: "9C", icon: nil),
      .init(time: "19:00", temperature: "10C", icon: nil),
      .init(time: "22:00", temperature: "12C", icon: nil),
    ]),
    .init(date: "Wednesday 14/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
    .init(date: "Wednesday 15/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
    .init(date: "Wednesday 16/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
    .init(date: "Wednesday 17/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
    .init(date: "Wednesday 18/12/2024", hours: [
      .init(time: "01:00", temperature: "3C", icon: nil),
      .init(time: "04:00", temperature: "3C", icon: nil),
      .init(time: "07:00", temperature: "3C", icon: nil),
      .init(time: "10:00", temperature: "3C", icon: nil),
      .init(time: "13:00", temperature: "3C", icon: nil),
      .init(time: "16:00", temperature: "3C", icon: nil),
      .init(time: "19:00", temperature: "3C", icon: nil),
      .init(time: "22:00", temperature: "3C", icon: nil),
    ]),
  ]
    
  return WeatherInfoScreen(presenter: PreviewPresenterImpl(viewModel: viewModel))
}
