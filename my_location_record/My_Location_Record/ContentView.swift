//
//  ContentView.swift
//  My_Location_Record
//
//  Created by Fung Matthew on 17/10/2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var locations: [LocationAnnotation] = []
    @State private var selectedDate = Date()
    @State private var selectedLocation: LocationAnnotation?
    @State private var isTracking = false
    
    var body: some View {
        ZStack {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                
                Map(coordinateRegion: $region, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                HStack {
                    Button(isTracking ? "Stop Tracking" : "Start Tracking") {
                        if isTracking {
                            locationManager.stopTracking()
                        } else {
                            locationManager.startTracking()
                        }
                        isTracking.toggle()
                    }
                    .padding()
                    
//                    Button("Generate Mock Data") {
//                        generateMockData()
//                    }
//                    .padding()
                }
            }
            
            if let location = selectedLocation {
                VStack {
                    Spacer()
                    LocationInfoView(location: location) {
                        selectedLocation = nil
                    }
                }
            }
        }
        .onAppear {
            fetchLocations(for: selectedDate)
            settingNotification()
        }
        .onChange(of: selectedDate) { _ in
            fetchLocations(for: selectedDate)
        }
    }

    
    func fetchLocations(for date: Date) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let savedLocations = UserDefaults.standard.array(forKey: "savedLocations") as? [[String: Any]] ?? []
            
            self.locations = savedLocations.compactMap { locationData in
                guard let latitude = locationData["latitude"] as? Double,
                      let longitude = locationData["longitude"] as? Double,
                      let timestamp = locationData["timestamp"] as? TimeInterval else {
                    return nil
                }
                
                let date = Date(timeIntervalSince1970: timestamp)
                if date >= startOfDay && date < endOfDay {
                    return LocationAnnotation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), timestamp: date)
                }
                return nil
            }
            
            if let firstLocation = self.locations.first?.coordinate {
                self.region = MKCoordinateRegion(center: firstLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            }
        }
    
    func settingNotification() {
            UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
            
            NotificationCenter.default.addObserver(forName: Notification.Name("StopTracking"), object: nil, queue: .main) { _ in
                locationManager.stopTracking()
                isTracking = false
            }
        }
    
    func generateMockData() {
            // Clear existing data
//            UserDefaults.standard.removeObject(forKey: "savedLocations")
//            
//            // Generate mock data for the last 7 days
//            let calendar = Calendar.current
//            let today = Date()
//            var mockLocations: [[String: Any]] = []
//            
//            for day in 0..<7 {
//                let date = calendar.date(byAdding: .day, value: -day, to: today)!
//                let startOfDay = calendar.startOfDay(for: date)
//                
//                // Generate 5 random locations for each day
//                for _ in 0..<5 {
//                    let randomTime = Double.random(in: 0..<86400) // Random seconds in a day
//                    let timestamp = startOfDay.addingTimeInterval(randomTime)
//                    
//                    let latitude = 37.7749 + Double.random(in: -0.1...0.1)
//                    let longitude = -122.4194 + Double.random(in: -0.1...0.1)
//                    
//                    let locationData: [String: Any] = [
//                        "latitude": latitude,
//                        "longitude": longitude,
//                        "timestamp": timestamp.timeIntervalSince1970
//                    ]
//                    
//                    mockLocations.append(locationData)
//                }
//            }
//            
//            // Save mock data to UserDefaults
//            UserDefaults.standard.set(mockLocations, forKey: "savedLocations")
//            
//            // Refresh the map with new data
//            fetchLocations(for: selectedDate)
        
                }
    }


struct LocationAnnotation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
}

struct LocationInfoView: View {
    let location: LocationAnnotation
    let onDismiss: () -> Void
    @State private var locationName: String = "Loading..."
    
    var body: some View {
        VStack {
            Text("Location Details")
                .font(.headline)
                .padding()
            
            Text("Time: \(formattedTime)")
            Text("Location: \(locationName)")
            
            Button("Dismiss") {
                onDismiss()
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .onAppear {
            getLocationName()
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: location.timestamp)
    }
    
    func getLocationName() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                locationName = "Unable to find address"
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                locationName = "No address found"
                return
            }
            
            let addressComponents = [
                placemark.name,
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }
            
            locationName = addressComponents.joined(separator: ", ")
        }
    }
}
    
#Preview {
    ContentView()
}
