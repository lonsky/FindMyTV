//
//  ViewController.swift
//  FindMyTV
//
//  Created by Alexander Lonsky on 31/08/2018.
//  Copyright © 2018 Alexander Lonsky. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    @IBOutlet private var refreshBarButtonItem: UIBarButtonItem!

    private let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onModelUpdate = { [weak self] updateReason in
            switch updateReason
            {
            case .append:
                guard let viewModel = self?.viewModel else {
                    return
                }
                let indexPath = IndexPath(row: viewModel.devices.count - 1, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: .fade)
            case .clear:
                self?.tableView.reloadData()
            }
        }
        performDiscovery()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath)
        let device = viewModel.devices[indexPath.row]
        DeviceCellConfigarator.configure(cell, for: device)
        return cell
    }

    private func showActivity() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.startAnimating()
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func hideActivity() {
        navigationItem.rightBarButtonItem = refreshBarButtonItem
    }

    private func performDiscovery() {
        viewModel.discover()
        showActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.hideActivity()
        }
    }

    @IBAction func onRefresh(_ sender: Any) {
        performDiscovery()
    }
}
