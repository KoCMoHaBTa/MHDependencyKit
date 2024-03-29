//
//  DependencyCoordinator.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.09.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation

/**
 DependencyCoordinator is used to register depndency resolving handlers and resolve dependencies between 2 objects.
 There are various UIKit resolvers, used to resolve dependencies between 2 view controllers and segues.
 
 It solves the problem of the dependecy hell management between view controllers in any app.
 
 - note: The automatic dependecy segue resolver works by swizzling the `prepareForSegue:sender:` method
 - note: In order for automatic dependecy segue resolver to work - you must use segues and you must call super if you override `prepareForSegue:sender:` method
 
 How to use:
 - register your resolvers that resolve your dependencies between 2 view controllers
 - automatic - when any segue is triggered - all handlers that are applying to the source and destination will be called
 - manual - by calling any of the provided `resolveDependencies` methods on the receiver
 
 */

open class DependencyCoordinator: Identifiable {
    
    open var id: String = NSUUID().uuidString
    
    ///The underlaying storage of all prepare handlers
    fileprivate(set) var dependencyResolvers: [AnyDependencyResolver] = []
    
    ///A DependencyCoordinator can be composed of multiple childs
    open var childCoordinators: [DependencyCoordinator] = [] {
        
        didSet {
            
            //associate the children with their parent
            self.childCoordinators.forEach({ $0.parentCoordinator = self })
        }
    }
    
    ///If the receiver is composed - this is the parent reference
    open weak var parentCoordinator: DependencyCoordinator?
    
    ///A value that can be used by the client to store custom data
    open var userInfo: Any? = nil
    
    //Defines the internal kind of the dependency coordinator
    enum Kind {
        
        case `default`      //used for the default shared coordinator
        case custom         //used for any instance of the coordinator, made by the user
        case temporary      //used for temporary coordinators
        case workflow       //used for workflow coordinators
    }
    
    var kind: Kind = .custom
    
    init(kind: Kind) {
        
        self.kind = kind
    }
    
    public init() {
        
    }
}

extension DependencyCoordinator {
    
    public func addChild(_ coordinator: DependencyCoordinator) {
        
        self.childCoordinators.append(coordinator)
    }
    
    public func removeChild(_ coordinator: DependencyCoordinator) {
        
        self.removeChild(withID: coordinator.id)
    }
    
    public func removeChild(withID id: DependencyCoordinator.ID) {
        
        self.childCoordinators.removeAll { (child) -> Bool in
            
            child.removeChild(withID: id)
            return child.id == id
        }
    }
    
    public func removeFromParent() {
        
        self.parentCoordinator?.removeChild(self)
    }
}

extension DependencyCoordinator: Equatable {
    
    public static func ==(lhs: DependencyCoordinator, rhs: DependencyCoordinator) -> Bool {
        
        return lhs.id == rhs.id
    }
}

extension DependencyCoordinator {
    
    ///A default shared instance of DependencyCoordinator
    public static let `default` = DependencyCoordinator(kind: .default)
}

//MARK: - Combining all available resolve handlers from the coordinator's composition

extension Collection where Element == DependencyCoordinator {
    
    ///Combined and flattened collection of all resolve handlers for the receiver's composition
    fileprivate var dependencyResolvers: [AnyDependencyResolver] {
        
        return self.reduce([]) { (resolveHandlers, coordinator) -> [AnyDependencyResolver] in
            
            var resolveHandlers = resolveHandlers
            resolveHandlers.append(contentsOf: coordinator.dependencyResolvers)
            resolveHandlers.append(contentsOf: coordinator.childCoordinators.dependencyResolvers)
            return resolveHandlers
        }
    }
}

//MARK: - Resolving dependencies

extension DependencyCoordinator {
    
    public typealias Provider = Any
    public typealias Consumer = Any
    
    ///Resolves the registered dependencies from the given provider to the given consumer.
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.dependencyResolvers.resolveDependencies(from: provider, to: consumer)
        self.childCoordinators.dependencyResolvers.resolveDependencies(from: provider, to: consumer)
    }
    
    /**
     Resolves the registered dependencies to the given consumer, where no explicit provider exists.
     - parameter consumer: The consumer to which to resolve dependencies.
     - note: The provider specified to each resolver is of Void type.
     */
    public func resolveDependencies(to consumer: Consumer) {
        
        self.resolveDependencies(from: (), to: consumer)
    }
}

//MARK: - Registering dependency resolvers

extension DependencyCoordinator {
    
    ///Registers an existing dependency resolver.
    public func register(dependencyResolver: AnyDependencyResolver) {
        
        self.dependencyResolvers.append(dependencyResolver)
    }
    
    ///Registers an existing dependency resolver.
    public func register<T: DependencyResolver>(dependencyResolver: T) {
        
        self.register(dependencyResolver: AnyDependencyResolver(other: dependencyResolver))
    }
}

//MARK: - Copying

extension DependencyCoordinator {
    
    func copy(as kind: Kind? = nil) -> DependencyCoordinator {
    
        let copy = DependencyCoordinator()
        copy.dependencyResolvers = self.dependencyResolvers.copy()
        copy.childCoordinators = self.childCoordinators.map({ $0.copy() })
        copy.userInfo = self.userInfo
        copy.kind = kind ?? self.kind
        
        return copy
    }
}

