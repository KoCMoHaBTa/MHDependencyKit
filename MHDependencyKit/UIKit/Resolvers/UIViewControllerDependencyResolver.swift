//
//  UIViewControllerDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

public struct UIViewControllerDependencyResolver<Source, Destination>: DependencyResolver {
    
    private let handler: (Source, Destination) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Provider = UIViewController
    public typealias Consumer = UIViewController
    
    public func resolveDependencies(from source: Provider, to destination: Consumer) {

        destination.dependencyCoordinator = source.dependencyCoordinator
        
        guard let source = source.lookupFirst(of: Source.self) else {

            return
        }

        let destinations = destination.lookupAll(of: Destination.self)
        for destination in destinations {

            self.handler(source, destination)
        }
    }
}

extension UIViewControllerDependencyResolver where Source: UIViewController, Destination: UIViewController {
    
    public init(handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
}

extension UIViewControllerDependencyResolver where Source: UIViewController {
    
    public init(handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
}

extension UIViewControllerDependencyResolver where Destination: UIViewController {
    
    public init(handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
}
