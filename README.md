## Description

This project is a SwiftUI application designed to track and record your geographical locations over time. The app utilizes Core Location for gathering location data and MapKit for visualizing this data on a map. Users can select a date to view their recorded locations, making it easy to track movements and revisit places.

## Features
* Location Tracking: Start and stop location tracking with a single button. The app records your location every five minutes while tracking is active.

* Map Integration: Visualize recorded locations on a map, with interactive annotations that display details about each location.

* Date Selection: Users can choose a specific date to filter and view their recorded locations.

* Reverse Geocoding: Display location details (like address) when selecting a pin on the map.

* User Notifications: Receive notifications when location tracking starts and stops, enhancing user awareness.

* Mock Data Generation: (Commented out) Ability to generate and save mock location data for testing purposes.

## Technologies Used

* SwiftUI: For building the user interface.

* Core Location: For accessing and updating location data.


* MapKit: For displaying maps and annotations.

* User Notifications: To manage and display notifications for tracking status.

## Installation

* Clone the repository:

```sh
git clone https://github.com/mattfung1025/Location-Record-App.git
```
Open the project in Xcode.
Build and run on a physical device or simulator with location capabilities.

## Usage


Start the app and request location permissions.
Use the date picker to select a date and view recorded locations on the map.
Tap on map annotations to see more details about each location.

## Contribution

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again!

## License
This project is licensed under the MIT License. See the LICENSE file for details.

