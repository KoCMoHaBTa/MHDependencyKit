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
    public var dependencyCoordinator: DependencyCoordinator {
        
        get {
            
            return objc_getAssociatedObject(self, &UIViewController.dependencyCoordinatorKey) as? DependencyCoordinator ?? .default
        }
        
        set {
            
            objc_setAssociatedObject(self, &UIViewController.dependencyCoordinatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    ///Resolve the dependencies from the receiver to a given destination, usually the next view controller that will be shown
    public func resolveDependencies<T>(to destination: T) {
        
        self.dependencyCoordinator.resolveDependencies(from: self, to: destination)
    }
    
    public func resolveDependencies(fromSender sender: Any?, to segue: UIStoryboardSegue) {
        
        self.dependencyCoordinator.resolveDependencies(fromSender: sender, to: segue)
    }
}

extension UIViewController {
    
    ///Calls `self.dependencyCoordinator.prepare(for: segue, sender: sender)`. This method is used for objc compatibility
    @objc open dynamic func prepare(usingDependencyCoordinatorFromSender sender: Any?, toSegue segue: UIStoryboardSegue) {
        
        self.resolveDependencies(fromSender: sender, to: segue)
    }
}
