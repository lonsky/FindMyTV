//
//  UPnPDevice.swift
//  FindMyTV
//
//  Created by Alexander Lonsky on 02/09/2018.
//  Copyright © 2018 Alexander Lonsky. All rights reserved.
//

import Foundation

struct UPnPDevice: Equatable, CustomStringConvertible {

    var friendlyName: String?
    var manufacturer: String?
    var modelDescription: String?
    var modelName: String?
    var modelNumber: String?
    var serialNumber: String?

    var description: String {
        return """
        friendlyName = \(friendlyName ?? "-")
        manufacturer = \(manufacturer ?? "-")
        modelDescription = \(modelDescription ?? "-")
        modelName = \(modelName ?? "-")
        modelNumber = \(modelNumber ?? "-")
        serialNumber = \(serialNumber ?? "-")

        """
    }
}

// MARK: - Swisscom TV

extension UPnPDevice {
    private struct Constant {
        static let swisscomTV = "Swisscom TV"
    }
    
    var isSwisscomTV: Bool {
        return modelDescription?.range(of: Constant.swisscomTV) != nil ||
            modelName?.range(of: Constant.swisscomTV) != nil
    }
}
