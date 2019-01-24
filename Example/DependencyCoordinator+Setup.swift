//
//  DependencyCoordinator+Setup.swift
//  Example
//
//  Created by Milen Halachev on 23.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import MHDependencyKit

extension DependencyCoordinator {
    
    func setup() {
        
        //resolves the appVersion in case no source is provided - check AppDelegate for more information
        self.register(dependencyResolver: UIViewControllerConsumerContextDependencyResolver(handler: { (consumer: AppVersionConfigurable) in
            
            consumer.appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        }))
        
        //make the app version transfer between all objects, no matter if they are directly related
        self.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: AppVersionConfigurable, destination: AppVersionConfigurable) in
            
            destination.appVersion = source.appVersion
        }))
        
        //transfer input text from one screen to display label to next one
        self.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source: TextInputConfigurable, destination: TextDisplaConfigurable) in
            
            destination.textToDisplay = source.textInputValue
        }))
        
        //transfer input text from one screen to display label to next one, no matter if they are directly related
        self.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: TextInputConfigurable, destination: ContextTextDisplaConfigurable) in
            
            destination.textToDisplay = source.textInputValue
        }))
    }
}
