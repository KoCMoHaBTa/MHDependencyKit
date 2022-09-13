//
//  UIViewController+TemporaryDependencyCoordinator.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 9.10.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    private static let temporaryDependencyCoordinatorID = "com.KoCMoHaBTa.MHDependencyKit.temporaryDependencyCoordinatorID"
    private static var temporaryDependencyCoordinatorKey = ""
    
    ///An additional, temporary, one time usable dependency coordinator. Once it is used, its reference is set to nil. Can be used to fine tune next segue. Used in condjuction with `performSegue(withIdentifier:sender:prepareHandler)`
    @available(*, deprecated, message: "Use registerTemporaryContextDependencyResolver(handler:) instead")
    public var temporaryDependencyCoordinator: DependencyCoordinator? {
        
        get {
            
            return self.dependencyCoordinator.childCoordinators.first(where: { $0.id == Self.temporaryDependencyCoordinatorID })
        }
        
        set {
                        
            newValue?.removeFromParent()

            if let newValue = newValue {

                self.dependencyCoordinator.removeChild(newValue)
                newValue.id = Self.temporaryDependencyCoordinatorID
                self.dependencyCoordinator.childCoordinators.append(newValue)
            }
        }
    }
}

extension UIViewController {
    
    ///Performs a segue by providing a prepare handler for setting up a one time usable temporray DependencyCoordinator
    @available(*, deprecated, message: "Use registerTemporaryContextDependencyResolver(handler:) instead")
    public func performSegue(withIdentifier identifier: String, sender: Any?, prepareHandler: (DependencyCoordinator) -> Void) {
        
        let temporaryDependencyCoordinator = DependencyCoordinator(kind: .temporary)
        prepareHandler(temporaryDependencyCoordinator)
        self.temporaryDependencyCoordinator = temporaryDependencyCoordinator
    }
}

extension UIViewController {
    
    private func _registerTemporaryContextDependencyResolver<Source, Destination>(handler: @escaping (Source, Destination) -> Void) {
        
        let temporaryDependencyCoordinator = DependencyCoordinator(kind: .temporary)
        self.dependencyCoordinator.childCoordinators.append(temporaryDependencyCoordinator)
        
        temporaryDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { [weak temporaryDependencyCoordinator] (source: Source, destination: Destination) in
            
            handler(source, destination)
            temporaryDependencyCoordinator?.removeFromParent()
        }))
    }
    
    public func registerTemporaryContextDependencyResolver<Source, Destination>(handler: @escaping (Source, Destination) -> Void) {
        
        self._registerTemporaryContextDependencyResolver(handler: handler)
    }
    
    public func registerTemporaryContextDependencyResolver<Source, Destination>(handler: @escaping (Source, Destination) -> Void) where Source: UIViewController {
        
        self._registerTemporaryContextDependencyResolver(handler: handler)
    }
    
    public func registerTemporaryContextDependencyResolver<Source, Destination>(handler: @escaping (Source, Destination) -> Void) where Destination: UIViewController {
        
        self._registerTemporaryContextDependencyResolver(handler: handler)
    }
    
    public func registerTemporaryContextDependencyResolver<Source, Destination>(handler: @escaping (Source, Destination) -> Void) where Source: UIViewController, Destination: UIViewController {
        
        self._registerTemporaryContextDependencyResolver(handler: handler)
    }
}

extension UIViewController {
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    func _performSegue<Source, Destination>(_ shouldPerformSegue: Bool, withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) {
        
        self.registerTemporaryContextDependencyResolver(handler: contextHandler)
        
        if shouldPerformSegue {

            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) {
        
        self._performSegue(true, withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Source: UIViewController {
        
        self._performSegue(true, withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Destination: UIViewController {
        
        self._performSegue(true, withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Source: UIViewController, Destination: UIViewController {
        
        self._performSegue(true, withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
}

