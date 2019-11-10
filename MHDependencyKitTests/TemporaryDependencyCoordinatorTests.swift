//
//  TemporaryDependencyCoordinatorTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 9.10.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class TemporaryDependencyCoordinatorTests: XCTestCase {
    
    //this has been replaced with testTemporaryDependencyCoordinatorPrepareSegue
    func testTemporaryDependencyCoordinatorPrepareSegue_legacy() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            
            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            controller.registerTemporaryContextDependencyResolver { (source, destination) in
                e.fulfill()
            }
            
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
        }
    }
        
    //When using registerTemporaryContextDependencyResolver
    //  - and there are multiple maching destination
    //  - only the first one should be resolved
    func testTemporaryDependencyCoordinatorWithContextHandlersSingleMatchMultipleDestinations() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 2
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()

            //resolver 1
            controller.registerTemporaryContextDependencyResolver { (source: UIViewController, destination: UITableViewController) in
                
                e.fulfill()
            }
            
            //resolver 2
            controller.registerTemporaryContextDependencyResolver { (source: UIViewController, destination: UICollectionViewController) in
                
                e.fulfill()
            }
            
            let destinations: [UIViewController] = [
                
                UIViewController(),
                UINavigationController(rootViewController: UICollectionViewController()),
                UIViewController(),
                UIViewController(),
                UITableViewController(),
                { () -> UITabBarController in let tab = UITabBarController(); tab.viewControllers = [UINavigationController(rootViewController: UICollectionViewController()), UITableViewController()]; return tab }()
            ]
            
            //this should not trigger any resolver
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test0", source: controller, destination: destinations[0]))
            
            //this should trigger resolver 1
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test1", source: destinations[0], destination: destinations[1]))
            
            //this should not trigger any resolver
            destinations[1].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test2", source: destinations[1], destination: destinations[2]))
            
            //this should not trigger any resolver
            destinations[2].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test3", source: destinations[2], destination: destinations[3]))
            
            //this should trigger resolver 2
            destinations[3].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test4", source: destinations[3], destination: destinations[4]))
            
            //this should not trigger any resolver, because resolver 1 and resovler 2 have already been triggered
            destinations[4].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test5", source: destinations[4], destination: destinations[5]))
        }
    }
    
    func testTemporaryDependencyCoordinatorPrepareSegue() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()

            controller.dependencyCoordinator.register(dependencyResolver: UIViewControllerDependencyResolver(handler: { (provider, consumer) in
                
                e.fulfill()
            }))
            
            //step 1 - should resolve once
            controller._performSegue(false, withIdentifier: "test", sender: nil) { (source: UIViewController, destination: UIViewController) in
                
                e.fulfill()
            }
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
            
            //calling prepare for segue again should not resolve dependencies second time
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()))
        }
    }
    
    //test if we can match multiple destinations with context handlers - this functionality does not exist yet
    func testTemporaryDependencyCoordinatorWithContextHandlers() {

        self.performExpectation { (e) in

            e.expectedFulfillmentCount = 4

            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()

            let destinations: [UIViewController] = [

                UIViewController(),
                UINavigationController(rootViewController: UICollectionViewController()),
                UIViewController(),
                UIViewController(),
                UITableViewController(),
                { () -> UITabBarController in let tab = UITabBarController(); tab.viewControllers = [UINavigationController(rootViewController: UICollectionViewController()), UITableViewController()]; return tab }()
            ]

            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test0", source: controller, destination: destinations[0]))

            destinations[0]._performSegue(false, withIdentifier: "test1", sender: nil) { (source: UIViewController, destination: UICollectionViewController) in

                e.fulfill()
            }
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test1", source: destinations[0], destination: destinations[1]))

            destinations[1].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test2", source: destinations[1], destination: destinations[2]))

            destinations[2].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test3", source: destinations[2], destination: destinations[3]))

            destinations[3]._performSegue(false, withIdentifier: "test1", sender: nil) { (source: UIViewController, destination: UITableViewController) in

                e.fulfill()
            }
            destinations[3].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test4", source: destinations[3], destination: destinations[4]))

            destinations[4].registerTemporaryContextDependencyResolver { (source: UIViewController, destination: UITableViewController) in

                e.fulfill()
            }
            destinations[4].registerTemporaryContextDependencyResolver { (source: UIViewController, destination: UICollectionViewController) in

                e.fulfill()
            }
            destinations[4].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "test5", source: destinations[4], destination: destinations[5]))
        }
    }
    
    func testConsecutiveDependencyCoordinator() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            
            class MockViewController0: UIViewController {
                
                var value0: String?
            }
            
            class MockViewController1: UIViewController {
                
                var value1: String?
            }
            
            let destinations: [UIViewController] = [
                
                MockViewController0(),
                MockViewController1()
            ]
            
            //move from initial to destionation 0
            controller._performSegue(false, withIdentifier: "step0", sender: nil) { (source: UIViewController, destination: MockViewController0) in
                
                destination.value0 = "step0"
                e.fulfill()
            }
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step0", source: controller, destination: destinations[0]))
            
            //move from destination 0 to destination 1
            destinations[0]._performSegue(false, withIdentifier: "step1", sender: nil) { (source: UIViewController, destination: MockViewController1) in
                
                destination.value1 = "step1"
                e.fulfill()
            }
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: controller, destination: destinations[1]))
            
            DispatchQueue.main.async {
                
                e.fulfill()
                
                XCTAssertEqual((destinations[0] as? MockViewController0)?.value0, "step0")
                XCTAssertEqual((destinations[1] as? MockViewController1)?.value1, "step1")
            }
            
        }
    }
    
    func testHoppingWithTemporaryDependencyCoordinatorSimplified() {
        
        self.performExpectation { (e) in
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            
            class MockViewController: UIViewController {
                
                var value: String?
            }
            
            let destinations: [UIViewController] = [
                
                UIViewController(),
                MockViewController()
            ]
            
            controller._performSegue(false, withIdentifier: "step1", sender: nil) { (source: UIViewController, destination: MockViewController) in
                
                e.fulfill()
            }
            
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: controller, destination: destinations[0]))
            
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: destinations[0], destination: destinations[1]))
        }
    }
    
    func testHoppingWithTemporaryDependencyCoordinator() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 5
            
            let controller = UIViewController()
            controller.dependencyCoordinator = DependencyCoordinator()
            
            class MockViewController: UIViewController {
                
                var value0: String?
                var value2: String?
            }
            
            let destinations: [UIViewController] = [
                
                UIViewController(),
                UIViewController(),
                MockViewController(),
                UITableViewController()
            ]
            
            //move from initial to destionation 0 - resolve dependency for a future MockViewController
            controller._performSegue(false, withIdentifier: "step0", sender: nil) { (source: UIViewController, destination: MockViewController) in
                
                destination.value0 = "step0"
                e.fulfill()
            }
            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step0", source: controller, destination: destinations[0]))
            
            //move from destination 0 to destination 1
            destinations[0]._performSegue(false, withIdentifier: "step1", sender: nil) { (source: UIViewController, destination: UITableViewController) in
                
                destination.title = "step1"
                e.fulfill()
            }
            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: destinations[0], destination: destinations[1]))
            
            //move from destination 1 to destination 2
            destinations[1]._performSegue(false, withIdentifier: "step2", sender: nil) { (source: UIViewController, destination: MockViewController) in
                
                destination.value2 = "step2"
                e.fulfill()
            }
            destinations[1].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step2", source: destinations[1], destination: destinations[2]))
            
            //move from destination 2 to destination 3
            destinations[2]._performSegue(false, withIdentifier: "step3", sender: nil) { (source: UIViewController, destination: UIViewController) in
                
                //do nothing here
                e.fulfill()
            }
            destinations[2].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step3", source: destinations[2], destination: destinations[3]))
            
            DispatchQueue.main.async {
                
                e.fulfill()
                
                XCTAssertEqual((destinations[2] as? MockViewController)?.value0, "step0")
                XCTAssertEqual((destinations[2] as? MockViewController)?.value2, "step2")
                XCTAssertEqual((destinations[3] as? UITableViewController)?.title, "step1")
            }
            
        }
    }
}
