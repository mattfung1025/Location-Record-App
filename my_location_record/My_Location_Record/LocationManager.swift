//
//  LocationManager.swift
//  My_Location_Record
//
//  Created by Fung Matthew on 17/10/2024.
//

import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    private var timer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        requestNotificationPermission()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        startRecordingTimer()
        showPersistentNotification()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        removePersistentNotification()
    }
    
    private func startRecordingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.recordLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    private func recordLocation() {
        guard let location = self.location else {
            print("No location available to record")
            return
        }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        var savedLocations = UserDefaults.standard.array(forKey: "savedLocations") as? [[String: Any]] ?? []
        savedLocations.append(locationData)
        UserDefaults.standard.set(savedLocations, forKey: "savedLocations")
        
        print("Location recorded successfully at \(Date())")
    }
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func showPersistentNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Location Tracking Active"
        content.body = "Your location is being recorded every 5 minutes."
        content.sound = nil
        
        let stopAction = UNNotificationAction(identifier: "STOP_TRACKING", title: "Stop Tracking", options: .foreground)
        let category = UNNotificationCategory(identifier: "TRACKING", actions: [stopAction], intentIdentifiers: [], options: [])
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "TRACKING"
        
        let request = UNNotificationRequest(identifier: "persistentNotification", content: content, trigger: nil)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func removePersistentNotification() {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: ["persistentNotification"])
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["persistentNotification"])
    }
}
