//
//  DependencyCoordinator+UIStoryboardSegue.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

extension DependencyCoordinator {
    
    open func resolveDependencies(fromSender sender: Any?, to segue: UIStoryboardSegue) {
        
        if let sender = sender {
            
            self.resolveDependencies(from: sender, to: segue)
        }
        
        self.resolveDependencies(to: segue)
        self.resolveDependencies(from: segue.source, to: segue.destination)
    }
}
