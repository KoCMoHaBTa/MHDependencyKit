//
//  ConsumerDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

/**
 A type that resolvers dependencies directly to a consumer.
 This type is inherits from DependencyResolver where the provider is Void.
 */
public protocol ConsumerDependencyResolver: DependencyResolver where Provider == Void {
    
    func resolveDependencies(to consumer: Consumer)
}

extension ConsumerDependencyResolver {
    
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.resolveDependencies(to: consumer)
    }
}
