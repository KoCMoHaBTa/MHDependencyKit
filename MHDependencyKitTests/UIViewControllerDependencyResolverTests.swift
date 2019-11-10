//
//  UIViewControllerDependencyResolverTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class UIViewControllerDependencyResolverTests: XCTestCase {
    
    //The basic handler should only be called
    //- when both source and destination are view controllers
    //- when both source and destination are matching the type
    func testHandler() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 1
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination) in
               
                e.fulfill()
            }))
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: UITabBarController) in
                
                XCTFail()
            }))
            
            coordinator.resolveDependencies(from: UIViewController(), to: UIViewController())
            coordinator.resolveDependencies(from: "", to: UIViewController())
            coordinator.resolveDependencies(from: UIViewController(), to: 5)
        }
    }
    
    //When resolving dependencies to containers,
    //- their childs sohuld also be configured appropriately
    func testChildLookup() {
        
        self.performExpectation { (e) in
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source: UINavigationController, destination) in
                
                e.fulfill()
            }))

            coordinator.resolveDependencies(from: UINavigationController(rootViewController: UIViewController()), to: UIViewController())
        }
        
        //destination only
        self.performExpectation { (e) in
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: ViewController) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(from: UINavigationController(rootViewController: UIViewController()), to: UINavigationController(rootViewController: ViewController()))
        }
        
        //mixed
        self.performExpectation { (e) in
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source: ViewController, destination: UINavigationController) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(from: UINavigationController(rootViewController: ViewController()), to: UINavigationController(rootViewController: ViewController()))
        }
    }
    
    //When resolving dependencies to containers,
    //- all of their childs sohuld also be configured appropriately
    func testMultipleChildLookup() {
        
        func makeNav(pushing: Int) -> UINavigationController {
            
            let nav = UINavigationController(rootViewController: ViewController())
            
            for _ in 0...pushing {
                
                nav.pushViewController(ViewController(), animated: false)
            }
            
            return nav
        }
        
        func makeTab(with viewControllers: [UIViewController]) -> UITabBarController {
            
            let tab = UITabBarController()
            tab.viewControllers = viewControllers
            return tab
        }
        
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 1
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: UINavigationController) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(from: UIViewController(), to: makeNav(pushing: 2))
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let coordinator = DependencyCoordinator()
            
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: ViewController) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(from: UIViewController(), to: makeNav(pushing: 2))
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let coordinator = DependencyCoordinator()
            
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: ViewController) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(from: UIViewController(), to: makeNav(pushing: 2))
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 2
            
            let coordinator = DependencyCoordinator()
            
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: ViewController) in
                
                e.fulfill()
            }))
            
            let tab = makeTab(with: [ViewController(), ViewController()])
            coordinator.resolveDependencies(from: UIViewController(), to: tab)
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 5
            
            let coordinator = DependencyCoordinator()
            
            
            coordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (source, destination: ViewController) in
                
                e.fulfill()
            }))
            
            let tab = makeTab(with: [ViewController(), ViewController(), makeNav(pushing: 1)])
            coordinator.resolveDependencies(from: UIViewController(), to: tab)
        }
    }
    
    //When using UIViewControllerDependencyResolver
    //    - the dependency coordinator should always be transfered from the source to the destination, no matter if the resolver is successful or not
    func testPreservingOfDependencyCoordinator() {
        
        let resolver = UIViewControllerDependencyResolver(handler: { (source: UITableViewController, destionation: UICollectionViewController) in
            
        })
        
        let coordinator = DependencyCoordinator()
        coordinator.register(dependencyResolver: resolver)
        
        let root = UIViewController()
        root.dependencyCoordinator = coordinator
        
        //resolve using the convenioence controller function
        let vc1 = UIViewController()
        root.resolveDependencies(to: vc1)
        XCTAssertEqual(vc1.dependencyCoordinator, coordinator)
        
        //resolve using the coordinator
        let vc2 = UIPageViewController()
        coordinator.resolveDependencies(from: vc1, to: vc2)
        XCTAssertEqual(vc2.dependencyCoordinator, coordinator)
        
        let vc3 = UINavigationController(rootViewController: UITableViewController())
        resolver.resolveDependencies(from: vc2, to: vc3)
        XCTAssertEqual(vc3.dependencyCoordinator, coordinator)
        XCTAssertEqual(vc3.viewControllers.first?.dependencyCoordinator, coordinator)
    }
}
