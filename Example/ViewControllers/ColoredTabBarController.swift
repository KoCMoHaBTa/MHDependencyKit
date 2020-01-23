//
//  ColoredTabBarController.swift
//  Example
//
//  Created by Milen Halachev on 21.01.20.
//  Copyright © 2020 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class ColoredTabBarController: UITabBarController, ColorConfigurable {
    
    var color: UIColor!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tabBar.tintColor = self.color
        self.viewControllers?.forEach({ (viewController) in
            
            self.resolveDependencies(to: viewController)
            viewController.setupWorkflowDependencyCoordinator()
        })
    }
}
