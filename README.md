#  Quick Weather

## Intro

This app uses the OpenWeatherMap API to display a forecast. 

It requires an API key which is **not** provided in the public repository. Nevertheless one can be obtained from the OpenWeatherMap site, and inserted in the Coordinator class in line 14 ie.:

```swift
static let apiKey = "insert_your_key_here"
```

This has been developed as a test around the end of 2019, and has recently been updated to the use the new Swift concurrency model and partially to SwiftUI.

The app has 2 screens: one where the user can choose a city and a second that shows the wether info for the selected city. The city selector screen was not part of the requirements of this project, and hence not much attention has been paid to it. It has been created with the minimum amount of effort and code quality could be improved.

## Code structure

The project implements mostly a clean architecture (as described in Robert C. Martin's book). The view and view models are managed by the presenter. The later uses the Interactor to obtained from a factory to call into the business logic. The for the network communication the business logic provides abstractions. It is the networking layer that needs to conform to these abstractions so it can be injected int he business logic by the coordinator. 

## Components

### Coordinator 

In order to avoid multiple singletons a coordinator is used. It contains most of the classes that need to live as long as the app. The app uses some dependency inversion in that most other things depend on the business logic. Thus if eg. another weather provider needs to be used, this can be incorporated without much effort. The coordinator helps in this respect as well.

### UI layer

It includes views, view models and presenter which depend on the Business Logic or abstractions thereof. 

### Business logic

Does not depend on anything other than the core iOS classes. Details such as the cache storage and network communication is injected by the Coordinator.

### OpenWeatherMapAPI (OpenWeatherMapAPIDataProvider)

Implements the logic that fetches data from the OpenWeatherMap api. 

Depends on the Business Logic and only on one protocol from Networking. Thus it is abstracted from the network implementation which is injected. This has the added benefit that in stead of the real network implementation, a class that reads from local files can be used for test purposes.

### Networking 

This module provides functionality for executing REST APIs calls. It also has a class that can provide data from local files.

## Testing

Part of this project has been developed in a TDD manner, however towards the end I have deviated a bit from this principle. There are unit tests for most of the classes.

The unit tests can be further improved as only positive scenarios are tested. 

Also in order to test controllers UI tests should be written.

## Error handling 

The application handles any kind of error by displaying a generic alert. This is not ideal because the alert popups are quite annoying for the user. In order to facilitate a better error handling, that selectively informs the user of errors through let's say pop ups and "toasts", the business logic should be more specific with the type of errors it sends to the view models, and should perhaps translate some low level errors before sending them up to the view model.
