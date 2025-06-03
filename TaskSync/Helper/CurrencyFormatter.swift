//
//  CurrencyFormatter.swift
//  TaskSync
//
//  Created by Paul  on 6/3/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class CurrencyFormatter: NSObject, ObservableObject, @preconcurrency CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currencyCode: String = "USD" // default fallback

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchCurrencyCode(from: location)
        locationManager.stopUpdatingLocation()
    }

    private func fetchCurrencyCode(from location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let countryCode = placemarks?.first?.isoCountryCode {
                let localeID = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
                let locale = Locale(identifier: localeID)
                if let currency = locale.currency?.identifier {
                    self.currencyCode = currency
                }
            }
        }
    }

    func format(_ value: Double) -> String {
        value.formatted(
            .currency(code: currencyCode)
                .notation(.compactName)
                .precision(.fractionLength(0...2))
        )
    }
}
