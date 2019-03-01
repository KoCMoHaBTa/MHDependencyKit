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
    
    ///This is used to be called from extensions below
    fileprivate init(theHandler handler: @escaping (Source, Destination) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Provider = UIViewController
    public typealias Consumer = UIViewController
    
    //holds the reference to the last recognized sources
    private var stack: [WeakReferenceWrapper<AnyObject>] = [] {
        
        didSet {
            
            self.stack = self.stack.filter({ $0.reference != nil })
        }
    }
    
    public func resolveDependencies(from source: Provider, to destination: Consumer) {
        
        //resolve the source
        UIViewControllerDependencyResolver(handler: { [weak self] (source: Source, _) in
            
            self?.stack.append(.init(reference: source as AnyObject))
            
        }).resolveDependencies(from: source, to: destination)
        
        //resolve the destination
        UIViewControllerDependencyResolver(handler: { [weak self] (_, destination: Destination) in
            
            if let source = self?.stack.last(where: { $0.reference is Source })?.reference as? Source {

                //if source matches - call the handler
                self?.handler(source, destination)
            }
            
        }).resolveDependencies(from: source, to: destination)
    }
}

extension UIViewControllerContextDependencyResolver where Source: UIViewController, Destination: UIViewController {
    
    public convenience init(handler: @escaping (Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
}

extension UIViewControllerContextDependencyResolver where Source: UIViewController {
    
    public convenience init(handler: @escaping (Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
}

extension UIViewControllerContextDependencyResolver where Destination: UIViewController {
    
    public convenience init(handler: @escaping (Source, Destination) -> Void) {
        
        self.init(theHandler: handler)
    }
}
