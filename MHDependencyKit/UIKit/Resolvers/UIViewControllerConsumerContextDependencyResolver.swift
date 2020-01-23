//
//  UIViewControllerConsumerContextDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 24.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation

///Resolves dependency between any Void to UIViewController, no matter when they appear in the workflow
public final class UIViewControllerConsumerContextDependencyResolver<Destination>: DependencyResolver {
    
    private let handler: (Destination) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Destination) -> Void) {
        
        self.handler = handler
    }
    
    ///This is used to be called from extensions below
    fileprivate init(theHandler handler: @escaping (Destination) -> Void) {
        
        self.handler = handler
    }
    
    //MARK: - DependencyResolver
    
    public typealias Provider = Any
    public typealias Consumer = UIViewController
    
    //holds the state whenever Void source was encountered
    private var stack: [WeakReferenceWrapper<UIViewController>] = []
    private weak var resolvedConsumer: AnyObject?
    
    public func resolveDependencies(from source: Provider, to destination: Consumer) {
        
        //the first source must be Void, then it can be anything until the destination is resolved
        if source is Void {

            //reset the stack at the begining
            self.stack = []
            self.resolvedConsumer = nil
        }

        //if the source is not in the stack - add it
        if let source = source as? UIViewController, !self.stack.contains(where: { $0.isTheSameReference(as: source) }) {

            self.stack.append(.init(reference: source))
        }
        
        guard self.resolvedConsumer == nil else {
            
            return
        }

        UIViewControllerConsumerDependencyResolver(handler: { [weak self] (consumer: Destination) in

            self?.handler(consumer)
            self?.resolvedConsumer = consumer as AnyObject

        }).resolveDependencies(to: destination)
    }
    
    public func copy() -> UIViewControllerConsumerContextDependencyResolver<Destination> {
        
        let copy = UIViewControllerConsumerContextDependencyResolver<Destination>.init(handler: self.handler)
        copy.stack = self.stack
        return copy
    }
}
