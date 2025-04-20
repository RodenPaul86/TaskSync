//
//  AppReviewRequest.swift
//  TaskSync
//
//  Created by Paul  on 4/20/25.
//

import SwiftUI

enum AppReviewRequest {
    static let threshold: Int = 3
    @AppStorage("runSinceLastRequest") static var runSinceLastRequest: Int = 0
    @AppStorage("storedVersion") static var storedVersion: String = ""
    
    static var requestAvailable: Bool {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        runSinceLastRequest += 1
        print("Run Count: \(runSinceLastRequest)")
        print("App Version: \(appVersion)")
        print("Stored Version: \(storedVersion)")
        
        guard storedVersion != appVersion else {
            print("There has been no update since the last request.")
            runSinceLastRequest = 0
            return false
        }
        
        if runSinceLastRequest >= threshold {
            print("Threshold reached so make request for this version")
            storedVersion = appVersion
            runSinceLastRequest = 0
            return true
        }
        
        print("Waiting for threshold to be reached...")
        return false
    }
}
