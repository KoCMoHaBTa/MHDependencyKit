//
//  AnyConsumerDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

///A non-generic type erasure of DependencyResolver that resolves dependencies directly to a consumer. The provider for this implementation is Void.
public struct AnyConsumerDependencyResolver: ConsumerDependencyResolver {
    
    private let handler: (Consumer) -> Void
    
    //MARK: - Init
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and Consumer types.
    private init<Consumer>(genericHandler: @escaping (Consumer) -> Void) {
        
        self.handler = { (consumer) in
            
            guard let consumer = consumer as? Consumer else {
                
                return
            }
            
            genericHandler(consumer)
        }
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler.
    public init(handler: @escaping (Consumer) -> Void) {
        
        self.handler = handler
    }
    
    ///Creates an instance of the receiver by providing a dependency resolving handler for a specific Provider and specific Consumer types.
    public init<Consumer>(handler: @escaping (Consumer) -> Void) {
        
        self.init(genericHandler: handler)
    }
    
    //MARK: - DependencyResolver
    
    public typealias Consumer = Any
    
    public func resolveDependencies(to consumer: Consumer) {
        
        self.handler(consumer)
    }
}
