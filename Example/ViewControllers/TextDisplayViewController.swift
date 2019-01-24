//
//  TextDisplayViewController.swift
//  Example
//
//  Created by Milen Halachev on 24.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class TextDisplayViewController: UIViewController, TextDisplaConfigurable, AppVersionConfigurable {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var appVersion: String?
    var textToDisplay: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.label.text = self.textToDisplay
        self.versionLabel.text = self.appVersion
    }
}
