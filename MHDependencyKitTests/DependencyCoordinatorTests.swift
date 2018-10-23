//
//  DependencyCoordinatorTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class DependencyCoordinatorTests: XCTestCase {
    
    let iterations = 1000
    
    func testHandlerPerformance() {
        
        let coordinator = DependencyCoordinator()
        
        for i in 0...self.iterations {
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination) in
                
                destination.title = "\(String(describing: source.title)) - \(i)"
            }))
        }
        
        self.measure {
            
            coordinator.resolveDependencies(from: UIViewController(), to: UIViewController())
        }
    }
    
    func testContextHandlerPerformance() {
        
        let coordinator = DependencyCoordinator()
        
        for i in 0...self.iterations {
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination) in
                
                destination.title = "\(String(describing: source.title)) - \(i)"
            }))
        }
        
        coordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIPageViewController, destination: UITableViewController) in
            
            destination.toolbarItems = source.toolbarItems
        }))
        
        self.measure {
            
            coordinator.resolveDependencies(from: UINavigationController(rootViewController: UIPageViewController()), to: UIViewController())
            coordinator.resolveDependencies(from: UINavigationController(rootViewController: ViewController()), to: ViewController())
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: ViewController()))
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: nil, source: ViewController(), destination: ViewController()))
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: nil, source: ViewController(), destination: UITableViewController()))
        }
    }
    
    func testChildCoordinatosComposition() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let c1 = DependencyCoordinator()
            let c2 = DependencyCoordinator()
            let c3 = DependencyCoordinator()
            
            c1.childCoordinators.append(c2)
            c1.childCoordinators.append(c3)
            
            c1.register(dependencyResolver: AnyDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            c2.register(dependencyResolver: AnyDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            c3.register(dependencyResolver: AnyDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            c1.resolveDependencies(from: UIViewController(), to: UIViewController())
        }
    }
    
    func testTemporarySegueCoordinatorPrepareSegue() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            controller.temporaryDependencyCoordinator = DependencyCoordinator()
            
            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            controller.temporaryDependencyCoordinator?.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
        }
    }
    
    func testTemporarySegueCoordinatorWithContextHandlers() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            controller.temporaryDependencyCoordinator = DependencyCoordinator()
            
            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination) in
                
                destination.temporaryDependencyCoordinator = source.temporaryDependencyCoordinator
            }))
            
            controller.temporaryDependencyCoordinator?.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIViewController, destination: UITableViewController) in
                
                e.fulfill()
            }))
            
            controller.temporaryDependencyCoordinator?.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIViewController, destination: UICollectionViewController) in
                
                e.fulfill()
            }))
            
            let destinations: [UIViewController] = [
                
                UIViewController(),
                UINavigationController(rootViewController: UICollectionViewController()),
                UIViewController(),
                UIViewController(),
                UITableViewController(),
                { () -> UITabBarController in let tab = UITabBarController(); tab.viewControllers = [UINavigationController(rootViewController: UICollectionViewController()), UITableViewController()]; return tab }()
            ]
            
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test0", source: controller, destination: destinations[0]))
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test1", source: destinations[0], destination: destinations[1]))
            destinations[1].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test2", source: destinations[1], destination: destinations[2]))
            destinations[2].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test3", source: destinations[2], destination: destinations[3]))
            destinations[3].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test4", source: destinations[3], destination: destinations[4]))
            destinations[4].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test5", source: destinations[4], destination: destinations[5]))
        }
    }
}
