//
//  ReplaceAllSegue.swift
//  Example
//
//  Created by Milen Halachev on 21.01.20.
//  Copyright © 2020 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class ReplaceAllSegue: UIStoryboardSegue {
    
    override func perform() {
        
        self.source.navigationController?.setViewControllers([self.destination], animated: true)
    }
}
