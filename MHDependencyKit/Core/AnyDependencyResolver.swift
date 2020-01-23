//
//  AnyDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

///A non-generic type erasure of DependencyResolver
public struct AnyDependencyResolver: DependencyResolver, CustomDebugStringConvertible {
    
    private let handler: (Provider, Consumer) -> Void
    private var copyHandler: () -> Self
    public private(set) var debugDescription: String
    
    //MARK: - Init
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and Consumer types.
    private init<Provider, Consumer>(genericHandler: @escaping (Provider, Consumer) -> Void) {
        
        self.handler = { (provider, consumer) in
            
            guard let provider = provider as? Provider, let consumer = consumer as? Consumer else {
                
                return
            }
            
            genericHandler(provider, consumer)
        }
        
        self.copyHandler = {
            
            return AnyDependencyResolver(genericHandler: genericHandler)
        }
        
        self.debugDescription = "AnyDependencyResolver<\(Provider.self), \(Consumer.self)>"
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a any Provider and any Consumer types.
    public init(handler: @escaping (Provider, Consumer) -> Void) {
        
        self.handler = handler
        
        self.copyHandler = {
            
            return AnyDependencyResolver(handler: handler)
        }
        
        self.debugDescription = "AnyDependencyResolver<\(Provider.self), \(Consumer.self)>"
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
        self.copyHandler = {
            
            return AnyDependencyResolver(genericHandler: dependencyResolver.copy().resolveDependencies)
        }
        self.debugDescription = "AnyDependencyResolver(other: \(String(reflecting: dependencyResolver))"
    }

    //MARK: - DependencyResolver
    
    public typealias Provider = Any
    public typealias Consumer = Any
    
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.handler(provider, consumer)
    }
    
    public func copy() -> AnyDependencyResolver {
        
        return self.copyHandler()
    }
}

