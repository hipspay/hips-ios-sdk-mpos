//
//  ViewController.swift
//  HipsSDKSampleApp
//
//  Created by Petre Lameski on 3/17/21.
//

import UIKit
import HipsSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let deviceSettingsVC = HipsSDK.deviceSettings() else { return }
        self.navigationController?.pushViewController(deviceSettingsVC, animated: true)
    }
}

