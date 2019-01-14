//
//  UIViewController+DependencyCoordinator.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    private static var dependencyCoordinatorKey = ""
    
    ///The dependency coordinator associated with the receiver - default to the shared instance `DependencyCoordinator.default`
    open var dependencyCoordinator: DependencyCoordinator {
        
        get {
            
            return objc_getAssociatedObject(self, &UIViewController.dependencyCoordinatorKey) as? DependencyCoordinator ?? .default
        }
        
        set {
            
            objc_setAssociatedObject(self, &UIViewController.dependencyCoordinatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {
    
    private static var temporaryDependencyCoordinatorKey = ""
    
    ///An additional, temporary, one time usable dependency coordinator. Once it is used, its reference is set to nil. Can be used to fine tune next segue. Used in condjuction with `performSegue(withIdentifier:sender:prepareHandler)`
    open var temporaryDependencyCoordinator: DependencyCoordinator? {
        
        get {
            
            return objc_getAssociatedObject(self, &UIViewController.temporaryDependencyCoordinatorKey) as? DependencyCoordinator
        }
        
        set {
            
            objc_setAssociatedObject(self, &UIViewController.temporaryDependencyCoordinatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {
    
    ///Calls `self.segueCoordinator.prepare(for: segue, sender: sender)`. This method is used for objc compatibility
    @objc open dynamic func prepare(usingDependencyCoordinatorFromSender sender: Any?, toSegue segue: UIStoryboardSegue) {
        
        self.dependencyCoordinator.resolveDependencies(fromSender: sender, to: segue)
        self.temporaryDependencyCoordinator?.resolveDependencies(fromSender: sender, to: segue)
        self.temporaryDependencyCoordinator = nil
    }
    
    //ZAGREI - this conflicts with legacy implementation - enable it at the end, when legacy is scapped
    ///Performs a segue by providing a prepare handler for setting up a one time usable temporray SegueCoordinator
    public func performSegue(withIdentifier identifier: String, sender: Any?, prepareHandler: (DependencyCoordinator) -> Void) {

        let temporaryDependencyCoordinator = DependencyCoordinator()
        prepareHandler(temporaryDependencyCoordinator)
        self.temporaryDependencyCoordinator = temporaryDependencyCoordinator

        self.performSegue(withIdentifier: identifier, sender: sender)
    }

    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    private func _performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) {

        self.performSegue(withIdentifier: identifier, sender: sender) { (coordinator) in
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination) in
                
                destination.temporaryDependencyCoordinator = source.temporaryDependencyCoordinator
            }))
            
            coordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: Source, destination: Destination) in
                
                contextHandler(source, destination)
                (destination as? UIViewController)?.temporaryDependencyCoordinator = nil
            }))
        }
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) {
        
        self._performSegue(withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Source: UIViewController {
        
        self._performSegue(withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Destination: UIViewController {
        
        self._performSegue(withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
    
    ///Performs a segue by providing a single one time context handler for setting up dependencies from a given source to a given destination
    public func performSegue<Source, Destination>(withIdentifier identifier: String, sender: Any?, contextHandler: @escaping (Source, Destination) -> Void) where Source: UIViewController, Destination: UIViewController {
        
        self._performSegue(withIdentifier: identifier, sender: sender, contextHandler: contextHandler)
    }
}

