//
//  AlertHelper.swift
//  TaskSync
//
//  Created by Paul  on 12/10/24.
//

import UIKit

struct AlertHelper {
    /// Presents an alert with the specified title, message, and actions.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - actions: An array of UIAlertAction to add to the alert.
    ///   - viewController: The view controller on which to present the alert.
    static func showAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)],
        on viewController: UIViewController
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add all actions to the alert
        for action in actions {
            alertController.addAction(action)
        }
        
        // Present the alert on the specified view controller
        viewController.present(alertController, animated: true, completion: nil)
    }
}

extension AlertHelper {
    static func showGlobalAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]
    ) {
        guard let topVC = getTopViewController() else {
            print("No top view controller found.")
            return
        }
        
        // Present the alert
        showAlert(title: title, message: message, actions: actions, on: topVC)
    }
    
    /// Retrieves the top-most view controller in the app.
    private static func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topVC = keyWindow.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}
