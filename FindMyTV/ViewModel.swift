//
//  ViewModel.swift
//  FindMyTV
//
//  Created by Alexander Lonsky on 02/09/2018.
//  Copyright © 2018 Alexander Lonsky. All rights reserved.
//

import Foundation

class ViewModel {
    enum UpdateReason {
        case append
        case clear
    }
    var onModelUpdate: ((_ reason: UpdateReason) -> Void)?
    private(set) var devices = [UPnPDevice]()
    private lazy var discoverer: UPnPDevicesDiscoverer = {
        let discoverer = UPnPDevicesDiscoverer()
        discoverer.subscribe(self)
        return discoverer
    }()

    func discover() {
        devices.removeAll()
        onModelUpdate?(.clear)

        discoverer.start(with: .root)
    }

    func stop() {
        discoverer.stop()
    }
}

extension ViewModel: UPnPDevicesDiscovererDelegate {
    func discoveredDevice(_ device: UPnPDevice) {
        // print("\(device)")
        guard devices.index(of: device) == nil else {
            print("tried to add existing device. ignore")
            return
        }
        devices.append(device)
        onModelUpdate?(.append)
    }
}
