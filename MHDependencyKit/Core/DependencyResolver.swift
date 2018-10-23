//
//  DependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

/**
 A type that resolvers dependencies from a provider to a consumer.
 
 The concept of this type is to define the resolution of dependencies in a direct way between a dependcy provider and dependency consumer.
 The `consumer` is the type that requires some dependencies to be resolved (provided).
 The `provider` is the type that provides the dependencies to the consumer.
 The provider and the consumer are not tied to any specific type, so its up to the implementation to decide how to deal with them.
 */
public protocol DependencyResolver {
    
    associatedtype Provider
    associatedtype Consumer
    
    ///Resolves the depndencies from the provider to the consumer.
    func resolveDependencies(from provider: Provider, to consumer: Consumer)
}

extension Array: DependencyResolver where Element: DependencyResolver {
    
    public typealias Provider = Element.Provider
    public typealias Consumer = Element.Consumer
    
    public func resolveDependencies(from provider: Element.Provider, to consumer: Element.Consumer) {
        
        self.forEach { (element) in
            
            element.resolveDependencies(from: provider, to: consumer)
        }
    }
}
