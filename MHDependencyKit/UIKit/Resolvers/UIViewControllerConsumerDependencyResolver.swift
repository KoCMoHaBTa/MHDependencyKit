//
//  UIViewControllerConsumerDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

public struct UIViewControllerConsumerDependencyResolver<Destination>: ConsumerDependencyResolver {
    
    private let handler: (Destination) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Destination) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Consumer = UIViewController
    
    public func resolveDependencies(to destination: Consumer) {
        
        let destinations = destination.lookupAll(of: Destination.self)
        for destination in destinations {
            
            self.handler(destination)
        }
    }
}

extension UIViewControllerConsumerDependencyResolver where Destination: UIViewController {

    public init(handler: @escaping (Destination) -> Void) {

        self.handler = handler
    }
}
