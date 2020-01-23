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
            
            //remove nil references and duplicates
            self.stack = self.stack.reduce(into: [], { (result, element) in
                
                guard element.reference != nil && result.contains(where: { $0.isTheSameReference(as: element.reference!) }) == false else {
                    
                    return
                }
                
                result.append(element)
            })
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
    
    public func copy() -> UIViewControllerContextDependencyResolver<Source, Destination> {
        
        let copy = UIViewControllerContextDependencyResolver<Source, Destination>.init(handler: self.handler)
        copy.stack = self.stack
        return copy
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

extension UIViewControllerContextDependencyResolver: CustomDebugStringConvertible {
    
    public func description(withPrefix prefix: String) -> String {
        
        return "\(prefix)" + "\(type(of: self)): " + "["
             + "\n" + self.stack.map({ $0.reference != nil ? "\(prefix)\t\(type(of: $0.reference!))" : "nil" }).joined(separator: ",\n")
             + "\n\(prefix)]"
    }

    public var debugDescription: String {
        
        return self.description(withPrefix: debugPrefix)
    }
}
