//
//  ViewController.swift
//  Example
//
//  Created by Milen Halachev on 15.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import UIKit
import MHDependencyKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func manualStoryboard() {
        
        self.performSegue(withIdentifier: "push", sender: nil)
    }
    
    @IBAction func manualConfiguredStoryboard() {
        
        self.performSegue(withIdentifier: "modal", sender: nil) { (_, destination: AppVersionConfigurable) in
            
            destination.appVersion = "this custom configured app version 111"
        }
    }
    
    @IBAction func manualResolve() {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "InputNavigationController")
        self.dependencyCoordinator.resolveDependencies(from: self, to: controller)
        self.present(controller, animated: true, completion: nil)
    }
}

