//
//  DeviceCellConfigarator.swift
//  FindMyTV
//
//  Created by Alexander Lonsky on 02/09/2018.
//  Copyright © 2018 Alexander Lonsky. All rights reserved.
//

import UIKit

struct DeviceCellConfigarator {
    static func configure(_ cell: UITableViewCell, for device: UPnPDevice) {
        cell.textLabel?.text = device.friendlyName
        cell.detailTextLabel?.text = DeviceCellConfigarator.details(for: device)
        if device.isSwisscomTV {
            cell.backgroundColor = UIColor(red: 0.267, green: 0.612, blue: 0.451, alpha: 1.00)
            cell.textLabel?.textColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor(white: 0.200, alpha: 1.00)
        }
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor
    }

    private static func details(for device: UPnPDevice) -> String {
        return """
        manufacturer = \(device.manufacturer ?? "-")
        modelDescription = \(device.modelDescription ?? "-")
        modelName = \(device.modelName ?? "-")
        modelNumber = \(device.modelNumber ?? "-")
        serialNumber = \(device.serialNumber ?? "-")
        """
    }
}
