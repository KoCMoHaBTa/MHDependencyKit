//
//  UIViewController+WorkflowDependencyCoordinator.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 9.10.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    ///Creates a new dependency coordinator, configured with the provided setupHandler, and associate it with the receiver. If there is an existing dependency coordinator - it is assigned as a child of the new one.
    ///- note: The workflow starts from the receiver
    open func setupWorkflowDependencyCoordinator(setupHandler: (DependencyCoordinator) -> Void) {
        
        let workflowDependencyCoordinator = DependencyCoordinator(kind: .workflow)
        setupHandler(workflowDependencyCoordinator)
        workflowDependencyCoordinator.childCoordinators.append(self.dependencyCoordinator)
        self.dependencyCoordinator = workflowDependencyCoordinator
    }
    
    ///Creates a new dependency coordinator, configured with the provided setupHandler, and associate it with the next destination for which dependencies are resolved. If there is an existing dependency coordinator - it is assigned as a child of the new one.
    ///- note: The workflow starts from the next destination for which dependencies are resolved.
    open func setupDestinationWorkflowDependencyCoordinator(setupHandler: @escaping (DependencyCoordinator) -> Void) {
        
        self.registerTemporaryContextDependencyResolver { (source, destination) in

            destination.setupWorkflowDependencyCoordinator(setupHandler: setupHandler)
        }
    }
}

extension UIViewController {

    ///Performs a segue by providing a prepare handler for setting up a workflow DependencyCoordinator. The function is internal in order to be unit tested
    func _performSegue(_ shouldPerformSegue: Bool, withIdentifier identifier: String, sender: Any?, setupHandler: @escaping (DependencyCoordinator) -> Void) {

        self.setupDestinationWorkflowDependencyCoordinator(setupHandler: setupHandler)

        if shouldPerformSegue {

            self.performSegue(withIdentifier: identifier, sender: sender)
        }
    }

//    ///Performs a segue by providing a prepare handler for setting up a workflow DependencyCoordinator. Since coordinators are transferred only in forward direction - this allows you to register workflow specific dependency resolvers that will be disposed along the workflow.
//    ///- important: The workflow dependency coordinator is associated with the segue's destination view controller.
//    ///- note: Useful to setup dependencies for the next workflow of screens.
//    public func performSegue(withIdentifier identifier: String, sender: Any?, setupHandler: @escaping (DependencyCoordinator) -> Void) {
//
//        self._performSegue(true, withIdentifier: identifier, sender: sender, setupHandler: setupHandler)
//    }
}
