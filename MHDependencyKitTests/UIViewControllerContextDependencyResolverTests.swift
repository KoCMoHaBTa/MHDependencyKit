//
//  UIViewControllerContextDependencyResolverTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class UIViewControllerContextDependencyResolverTests: XCTestCase {
    
    //When using context handers
    //- the first occurance of destination has to be resolved after a given source
    func testSingleTrigger() {
        
        self.performExpectation { (e) in
            
            let stack = [
                
                UIViewController(),
                UINavigationController(rootViewController: UIPageViewController()),     //this should be marked as source
                UIViewController(),
                ViewController(),
                ViewController(),
                UIViewController(),
                ViewController(),
                ViewController(),
                ViewController(),
                UITableViewController()                                                 //this should trigger the handler
            ]
            
            let conditions = [
                
                "s=\(stack[1].children[0]);d=\(stack[9])"
            ]
            
            e.add(conditions: conditions)
            
            let coordinator = DependencyCoordinator()
            coordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIPageViewController, destination: UITableViewController) in
                
                e.fulfill(condition: "s=\(source);d=\(destination)")
            }))
            
            stack.enumerated().forEach({ (offset: Int, element: UIViewController) in
                
                let destinationIndex = offset + 1
                guard destinationIndex != stack.endIndex  else { return }
                
                let source = element
                let destination = stack[destinationIndex]
                
                coordinator.resolveDependencies(from: source, to: destination)
            })
        }
    }
    
    //When using context handers
    //- the handler should resolve all destinations after a given source
    func testMultipleTriggers() {
        
        self.performExpectation { (e) in
            
            let stack = [
                
                UIViewController(),
                UINavigationController(rootViewController: UIPageViewController()),     //source 1
                UITableViewController(),                                                //destination 1.0
                UIViewController(),
                UITableViewController(),                                                //destination 1.1
                ViewController(),
                ViewController(),
                UIPageViewController(),                                                 //source 2
                UITableViewController(),                                                //destination 2.0
                UIViewController(),
                ViewController(),
                UITableViewController(),                                                //destination 2.1
                ViewController(),
                ViewController(),
                UITableViewController()                                                 //destination 2.2
            ]
            
            let conditions = [
                
                "s=\(stack[1].children[0]);d=\(stack[2])",
                "s=\(stack[1].children[0]);d=\(stack[4])",
                "s=\(stack[7]);d=\(stack[8])",
                "s=\(stack[7]);d=\(stack[11])",
                "s=\(stack[7]);d=\(stack[14])"
            ]
            
            //make sure that the first source is not used any more when a second one is found
            let exceptions = [
                
                "s=\(stack[1].children[0]);d=\(stack[8])",
                "s=\(stack[1].children[0]);d=\(stack[11])",
                "s=\(stack[1].children[0]);d=\(stack[14])"
            ]
            
            e.add(conditions: conditions)
            
            let coordinator = DependencyCoordinator()
            coordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIPageViewController, destination: UITableViewController) in
                
                let condition = "s=\(source);d=\(destination)"
                e.fulfill(condition: condition)
                
                //make sure that the first source is not used any more when a second one is found
                XCTAssertFalse(exceptions.contains(condition))
            }))
            
            stack.enumerated().forEach({ (offset: Int, element: UIViewController) in
                
                let destinationIndex = offset + 1
                guard destinationIndex != stack.endIndex  else { return }
                
                let source = element
                let destination = stack[destinationIndex]
                
                coordinator.resolveDependencies(from: source, to: destination)
            })
        }
    }
    
    //When using context handlers and custom coordinator
    //- segues should be resolved and update the coordinator accordingly
    func testSeguesWithCustomCoordinator() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            
            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIViewController, destination: UITableViewController) in
                
                e.fulfill()
            }))
            
            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UIViewController, destination: UICollectionViewController) in
                
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
