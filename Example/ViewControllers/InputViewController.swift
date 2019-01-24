//
//  InputViewController.swift
//  Example
//
//  Created by Milen Halachev on 23.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class InputViewController: UIViewController, UITextFieldDelegate, TextInputConfigurable, AppVersionConfigurable {
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var versionLabel: UILabel!
    
    var textInputValue: String?
    var appVersion: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.versionLabel.text = self.appVersion
        
        if self.navigationController?.viewControllers.first === self {
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedTextDidChangeNotification(_:)), name: UITextField.textDidChangeNotification, object: self.textField)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func receivedTextDidChangeNotification(_ notification: Notification) {
        
        self.textInputValue = self.textField.text
    }
}
