//
//  UPnPDevicesDiscoverer.swift
//  FindMyTV
//
//  Created by Alexander Lonsky on 02/09/2018.
//  Copyright © 2018 Alexander Lonsky. All rights reserved.
//

import Foundation
import SwiftyXMLParser

protocol UPnPDevicesDiscovererDelegate: class {
    func discoveredDevice(_ device: UPnPDevice)
}

class UPnPDevicesDiscoverer {

    enum DiscoveryMode {
        case all
        case root
    }

    private let client: SSDPClient
    private lazy var processingQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = String(describing: self)
        return operationQueue
    }()

    init() {
        client = SSDPClient()
        client.delegate = self
    }

    func start(with mode: DiscoveryMode = .root) {
        stop()

        switch mode {
        case .all:
            client.discoverAllDevices()
        case .root:
            client.discoverRootDevices()
        }
    }

    func stop() {
        client.stopDiscovery()
        processingQueue.cancelAllOperations()
    }

    private func processResponse(_ response: SSDPResponse) {
        guard let link = response.responseDictionary["LOCATION"] else {
            print("couldn't find LOCATION parameter")
            return
        }

        guard let url = URL(string: link) else {
            print("couldn't build URL from string:\(link)")
            return
        }

        let processingOperation = {
            guard let xmlText = try? String(contentsOf: url) else {
                print("couldn't download xml from url:\(url.absoluteString)")
                return
            }

            guard let device = UPnPDevicesDiscoverer.createUPnPDevice(from: xmlText) else {
                return
            }

            DispatchQueue.main.async {
                self.notify(with: device)
            }
        }
        processingQueue.addOperation(processingOperation)
    }

    private static func createUPnPDevice(from xmlString: String) -> UPnPDevice? {
        guard let xml = try? XML.parse(xmlString) else {
            print("couldn't parse XML from string: \(xmlString)")
            return nil
        }

        let element = xml["root", "device"]

        var device = UPnPDevice()
        device.friendlyName = element["friendlyName"].text ?? "-"
        device.manufacturer = element["manufacturer"].text ?? "-"
        device.modelDescription = element["modelDescription"].text ?? "-"
        device.modelName = element["modelName"].text ?? "-"
        device.modelNumber = element["modelNumber"].text ?? "-"
        device.serialNumber = element["serialNumber"].text ?? "-"
        return device
    }

    // MARK: - Subscribers

    private var subscribers = [UPnPDevicesDiscovererDelegate]()

    func subscribe(_ subscriber: UPnPDevicesDiscovererDelegate) {
        self.subscribers.append(subscriber)
    }

    func unsubscribe(_ subscriber: UPnPDevicesDiscovererDelegate) {
        guard let index = self.subscribers.index(where: { $0 === subscriber }) else {
            return
        }
        self.subscribers.remove(at: index)
    }

    private func notify(with device: UPnPDevice) {
        self.subscribers.forEach { subscriber in
            subscriber.discoveredDevice(device)
        }
    }
}

extension UPnPDevicesDiscoverer: SSDPClientDelegate {
    func received(_ response: SSDPResponse) {
        self.processResponse(response)
    }

    func received(_ request: SSDPRequest) {
        print("we don't support discovery requests. just ignore")
    }
}
