//
//  AnyDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

///A non-generic type erasure of DependencyResolver
public struct AnyDependencyResolver: DependencyResolver {
    
    private let handler: (Provider, Consumer) -> Void
    
    //MARK: - Init
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and Consumer types.
    private init<Provider, Consumer>(genericHandler: @escaping (Provider, Consumer) -> Void) {
        
        self.handler = { (provider, consumer) in
            
            guard let provider = provider as? Provider, let consumer = consumer as? Consumer else {
                
                return
            }
            
            genericHandler(provider, consumer)
        }
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a any Provider and any Consumer types.
    public init(handler: @escaping (Provider, Consumer) -> Void) {
        
        self.handler = handler
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and specific Consumer types.
    public init<Provider, Consumer>(handler: @escaping (Provider, Consumer) -> Void) {
        
        self.init(genericHandler: handler)
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for any Provider and specific Consumer types.
    public init<Consumer>(handler: @escaping (Provider, Consumer) -> Void) {

        self.init(genericHandler: handler)
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and any Consumer types.
    public init<Provider>(handler: @escaping (Provider, Consumer) -> Void) {
        
        self.init(genericHandler: handler)
    }
    
    ///Creates an instance of the receiver from another resolver's implementation.
    public init<T: DependencyResolver>(other dependencyResolver: T) {
        
        self.init(handler: dependencyResolver.resolveDependencies)
    }

    //MARK: - DependencyResolver
    
    public typealias Provider = Any
    public typealias Consumer = Any
    
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.handler(provider, consumer)
    }
}

