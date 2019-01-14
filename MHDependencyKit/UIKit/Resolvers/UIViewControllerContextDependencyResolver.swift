//
//  UIViewControllerContextDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

public final class UIViewControllerContextDependencyResolver<Source, Destination>: DependencyResolver {
    
    private let handler: (Source, Destination) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Provider = UIViewController
    public typealias Consumer = UIViewController
    
    //holds the reference to the last recognized source
    private weak var source: AnyObject? = nil
    
    public func resolveDependencies(from source: Provider, to destination: Consumer) {
        
        //resolve the source
        UIViewControllerDependencyResolver(handler: { [weak self] (source: Source, _) in
            
            self?.source = source as AnyObject
            
        }).resolveDependencies(from: source, to: destination)
        
        //resolve the destination
        UIViewControllerDependencyResolver(handler: { [weak self] (_, destination: Destination) in
            
            if let source = self?.source as? Source {
                
                //if source matches - call the handler
                self?.handler(source, destination)
            }
            
        }).resolveDependencies(from: source, to: destination)
    }
}
