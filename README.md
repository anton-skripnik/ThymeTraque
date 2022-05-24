#  ThymeTraque

Simple time tracking app.

## Supported Platforms

iOS

## Running the app

- Open `ThymeTraque.xcodeproj` in Xcode.
- Choose `ThymeTraque` scheme and a suitable destination.
- Click `Run` or `Cmd+R`.

## Running the tests

- Open `ThumeTraque.xcodeproj` in Xcode.
- Click `Product` > `Test` or `Cmd+U`.

## Running the performance tests

The app has a dedicated Performance Tests bundle. It is disabled by default due to the considerable amount of time they take.
In order to run them:
- Choose `ThymeTraque` scheme in Xcode. 
- Navigate to `Edit Scheme...`. Open the `Test` tab in the sidebar.
- In the main section in the `Info` pane check the `Enabled` column of `ThymeTraquePerformanceTests`.
- Close the scheme editor and run the tests as usual.

## Project layout and structure

- `Model` contains the `HistoryEntry` struct, which is the sole model object shared by all the features.
- `Features` correspond to primary app's functionality bits:
  - `App` contains the general glue setting up the app and dispatching between Tracking functionalty and the History.
  - `History` provides a way to communicate with previously tracked entries / activities.
  - `Track` gives a way to track new activities.
- `Services` are dependencies of the main features:
  - `DateProvider` is utilized to inject `Date`s into reducers. Especially useful with tests.
  - `DateFormatter` configures and stores a shared DateFormatter in order not to recreate it all the time.
  - `HistoryEntryPersistence` hosts the types that handle entries persistence between the app launches.
  - `Logger` does logging.
  - `ReducerProducer` is a set of types to make Reducers more OOP (personal preference).
  - `TimeIntervalFormatter` deals with converting seconds into displayable text.

## Attributions

- Thyme [icon](https://www.flaticon.com/free-icons/thyme) created by Icongeek26 - Flaticon.
