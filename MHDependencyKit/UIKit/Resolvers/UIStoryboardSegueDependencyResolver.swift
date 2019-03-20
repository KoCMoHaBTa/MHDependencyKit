//
//  UIStoryboardSegueDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

public struct UIStoryboardSegueDependencyResolver<Sender>: DependencyResolver {
    
    private let handler: (Sender, UIStoryboardSegue) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Sender, UIStoryboardSegue) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Provider = Sender
    public typealias Consumer = UIStoryboardSegue
    
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.handler(provider, consumer)
    }
}

extension UIStoryboardSegueDependencyResolver where Sender == Void {
    
    public init(handler: @escaping (UIStoryboardSegue) -> Void) {
        
        self.handler = { (sender, segue) in
            
            handler(segue)
        }
    }
}

extension UIStoryboardSegueDependencyResolver {
    
    ///This is used to be called from extensions below
    private init<Source, Destination>(theHandler handler: @escaping (Sender, String?, Source, Destination) -> Void) {
        
        self.handler = { (sender, segue) in
            
            let identifier = segue.identifier
            UIViewControllerDependencyResolver(handler: { (source: Source, destination: Destination) in
                
                handler(sender, identifier, source, destination)
                
            }).resolveDependencies(from: segue.source, to: segue.destination)
        }
    }
    
    public init<Source, Destination>(handler: @escaping (Sender, String?, Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
    
    public init<Source, Destination: UIViewController>(handler: @escaping (Sender, String?, Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
    
    public init<Source: UIViewController, Destination>(handler: @escaping (Sender, String?, Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
    
    public init<Source: UIViewController, Destination: UIViewController>(handler: @escaping (Sender, String?, Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
}
