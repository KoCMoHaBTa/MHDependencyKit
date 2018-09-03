//
//  SegueCoordinatorTests.swift
//  MHAppKit
//
//  Created by Milen Halachev on 10/18/16.
//  Copyright © 2016 Milen Halachev. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class SegueCoordinatorTests: XCTestCase {
    
    func testPrepareHandler() {
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler { (id, source, destination, sender) in
                
                expectation.fulfill()
            }
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: UIViewController()), sender: nil)
        }
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler { (source, destination) in
                
                expectation.fulfill()
            }
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: UIViewController()), sender: nil)
        }
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source: UINavigationController, destination: UITableViewController, sender) in
                
                expectation.fulfill()
            })
            
            coordinator.addPrepareHandler { (id, source, destination: UITabBarController, sender) in
                
                XCTFail("This should not be called, beucase there is no AmountViewController in our sample")
            }
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UINavigationController(), destination: UITableViewController()), sender: nil)
        }
    }
    
    func testPrepareHandlerChildLookup() {
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source: UINavigationController, destination, sender) in
                
                expectation.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UINavigationController(rootViewController: UIViewController()), destination: UIViewController()), sender: nil)
        }
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: ViewController, sender) in
                
                expectation.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UINavigationController(rootViewController: UITableViewController()), destination: UINavigationController(rootViewController: ViewController())), sender: nil)
        }
        
        self.performExpectation { (expectation) in
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source: ViewController, destination: UINavigationController, sender) in
                
                expectation.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UINavigationController(rootViewController: ViewController()), destination: UINavigationController(rootViewController: ViewController())), sender: nil)
        }
    }
    
    func testPrepareHandlerMultipleChildsLookup() {
        
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
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: UINavigationController, sender) in
                
                e.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: makeNav(pushing: 2)), sender: nil)
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: ViewController, sender) in
                
                e.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: makeNav(pushing: 2)), sender: nil)
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: ViewController, sender) in
                
                print("gg")
                e.fulfill()
            })
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: makeNav(pushing: 2)), sender: nil)
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 2
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: ViewController, sender) in
                
                e.fulfill()
            })
            
            let tab = makeTab(with: [ViewController(), ViewController()])
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: tab), sender: nil)
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 5
            
            let coordinator = SegueCoordinator()
            
            coordinator.addPrepareHandler({ (id, source, destination: ViewController, sender) in
                
                e.fulfill()
            })
            
            let tab = makeTab(with: [ViewController(), ViewController(), makeNav(pushing: 1)])
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: tab), sender: nil)
        }
    }
    
    func testContextHandler() {
        
        self.performExpectation { (expectation) in
            
            let stack = [
                
                UIViewController(),
                UINavigationController(rootViewController: UIPageViewController()),
                UIViewController(),
                ViewController(),
                ViewController(),
                UIViewController(),
                ViewController(),
                ViewController(),
                ViewController(),
                UITableViewController()
            ]
            
            let conditions = [
            
                "s=\(stack[1].childViewControllers[0]);d=\(stack[9])"
            ]
            
            expectation.add(conditions: conditions)
            
            let coordinator = SegueCoordinator()
            coordinator.addContextHandler({ (source: UIPageViewController, destination: UITableViewController) in
                
                expectation.fulfill(condition: "s=\(source);d=\(destination)")
            })

            stack.enumerated().forEach({ (offset: Int, element: UIViewController) in
                
                let destinationIndex = offset + 1
                guard destinationIndex != stack.endIndex  else { return }
                
                let source = element
                let destination = stack[destinationIndex]
                let segue = UIStoryboardSegue(identifier: nil, source: source, destination: destination)
                
                coordinator.prepare(for: segue, sender: nil)
            })
        }
        
        self.performExpectation { (expectation) in
            
            let stack = [
                
                UIViewController(),
                UINavigationController(rootViewController: UIPageViewController()),
                UITableViewController(),
                UIViewController(),
                UITableViewController(),
                ViewController(),
                ViewController(),
                UIPageViewController(),
                UITableViewController(),
                UIViewController(),
                ViewController(),
                UITableViewController(),
                ViewController(),
                ViewController(),
                UITableViewController()
            ]
            
            let conditions = [
            
                "s=\(stack[1].childViewControllers[0]);d=\(stack[2])",
                "s=\(stack[1].childViewControllers[0]);d=\(stack[4])",
                "s=\(stack[7]);d=\(stack[8])",
                "s=\(stack[7]);d=\(stack[11])",
                "s=\(stack[7]);d=\(stack[14])"
            ]
            
            //make sure that the first source is not used any more when a second one is found
            let exceptions = [
                
                "s=\(stack[1].childViewControllers[0]);d=\(stack[8])",
                "s=\(stack[1].childViewControllers[0]);d=\(stack[11])",
                "s=\(stack[1].childViewControllers[0]);d=\(stack[14])"
            ]
            
            expectation.add(conditions: conditions)
            
            let coordinator = SegueCoordinator()
            coordinator.addContextHandler({ (source: UIPageViewController, destination: UITableViewController) in
                
                let condition = "s=\(source);d=\(destination)"
                expectation.fulfill(condition: condition)
                
                //make sure that the first source is not used any more when a second one is found
                XCTAssertFalse(exceptions.contains(condition))
            })

            stack.enumerated().forEach({ (offset: Int, element: UIViewController) in
                
                let destinationIndex = offset + 1
                guard destinationIndex != stack.endIndex  else { return }
                
                let source = element
                let destination = stack[destinationIndex]
                let segue = UIStoryboardSegue(identifier: nil, source: source, destination: destination)
                
                coordinator.prepare(for: segue, sender: nil)
            })
        }
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let controller = UIViewController()
            controller.segueCoordinator = SegueCoordinator()
            
            controller.segueCoordinator.addContextHandler({ (source: UIViewController, destination: UITableViewController) in
                
                e.fulfill()
            })
            
            controller.segueCoordinator.addContextHandler({ (source: UIViewController, destination: UICollectionViewController) in
                
                e.fulfill()
            })
            
            let destinations: [UIViewController] = [
            
                UIViewController(),
                UINavigationController(rootViewController: UICollectionViewController()),
                UIViewController(),
                UIViewController(),
                UITableViewController(),
                { () -> UITabBarController in let tab = UITabBarController(); tab.viewControllers = [UINavigationController(rootViewController: UICollectionViewController()), UITableViewController()]; return tab }()
            ]
            
            controller.prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test0", source: controller, destination: destinations[0]), sender: nil)
            destinations[0].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test1", source: destinations[0], destination: destinations[1]), sender: nil)
            destinations[1].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test2", source: destinations[1], destination: destinations[2]), sender: nil)
            destinations[2].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test3", source: destinations[2], destination: destinations[3]), sender: nil)
            destinations[3].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test4", source: destinations[3], destination: destinations[4]), sender: nil)
            destinations[4].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test5", source: destinations[4], destination: destinations[5]), sender: nil)
        }
    }
    
    let iterations = 1000
    
    func testPrepareHandlerPerformance() {
        
        let coordinator = SegueCoordinator()
        
        for i in 0...self.iterations {
            
            coordinator.addPrepareHandler({ (_, source, destination, _) in
                
                destination.title = "\(String(describing: source.title)) - \(i)"
            })
        }
        
        self.measure {
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: UIViewController()), sender: nil)
        }
    }
    
    func testContextHandlerPerformance() {
        
        let coordinator = SegueCoordinator()
        
        for i in 0...self.iterations {
            
            coordinator.addPrepareHandler({ (_, source, destination, _) in
                
                destination.title = "\(String(describing: source.title)) - \(i)"
            })
        }
        
        coordinator.addContextHandler { (source: UIPageViewController, destination: UITableViewController) in
            
            destination.toolbarItems = source.toolbarItems
        }
        
        self.measure {
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UINavigationController(rootViewController: UIPageViewController()), destination: UIViewController()), sender: nil)
            
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: ViewController(), destination: ViewController()), sender: nil)
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: ViewController()), sender: nil)
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: ViewController(), destination: ViewController()), sender: nil)
            coordinator.prepare(for: UIStoryboardSegue(identifier: nil, source: ViewController(), destination: UITableViewController()), sender: nil)
        }
    }
    
    func testChildCoordinatosComposition() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let c1 = SegueCoordinator()
            let c2 = SegueCoordinator()
            let c3 = SegueCoordinator()
            
            c1.childCoordinators.append(c2)
            c1.childCoordinators.append(c3)
            
            c1.addPrepareHandler { (source, destination) in
                
                e.fulfill()
            }
            
            c2.addPrepareHandler { (source, destination) in
                
                e.fulfill()
            }
            
            c3.addPrepareHandler { (source, destination) in
                
                e.fulfill()
            }
            
            c1.prepare(for: UIStoryboardSegue(identifier: "test", source: UIViewController(), destination: UIViewController()))
        }
    }
    
    func testTemporarySegueCoordinatorPrepareSegue() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let controller = UIViewController()
            controller.segueCoordinator = SegueCoordinator()
            controller.temporarySegueCoordinator = SegueCoordinator()
            
            controller.segueCoordinator.addPrepareHandler({ (source, destination) in
                
                e.fulfill()
            })
            
            controller.temporarySegueCoordinator?.addPrepareHandler({ (source, destination) in
                
                e.fulfill()
            })
            
            controller.prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()), sender: nil)
            controller.prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test", source: controller, destination: UIViewController()), sender: nil)
        }
    }
    
    func testTemporarySegueCoordinatorWithContextHandlers() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let controller = UIViewController()
            controller.segueCoordinator = SegueCoordinator()
            controller.temporarySegueCoordinator = SegueCoordinator()
            
            controller.segueCoordinator.addPrepareHandler({ (source, destination) in

                destination.temporarySegueCoordinator = source.temporarySegueCoordinator
            })
            
            controller.temporarySegueCoordinator?.addContextHandler({ (source: UIViewController, destination: UITableViewController) in
                
                e.fulfill()
            })
            
            controller.temporarySegueCoordinator?.addContextHandler({ (source: UIViewController, destination: UICollectionViewController) in
                
                e.fulfill()
            })
            
            let destinations: [UIViewController] = [
                
                UIViewController(),
                UINavigationController(rootViewController: UICollectionViewController()),
                UIViewController(),
                UIViewController(),
                UITableViewController(),
                { () -> UITabBarController in let tab = UITabBarController(); tab.viewControllers = [UINavigationController(rootViewController: UICollectionViewController()), UITableViewController()]; return tab }()
            ]
            
            controller.prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test0", source: controller, destination: destinations[0]), sender: nil)
            destinations[0].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test1", source: destinations[0], destination: destinations[1]), sender: nil)
            destinations[1].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test2", source: destinations[1], destination: destinations[2]), sender: nil)
            destinations[2].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test3", source: destinations[2], destination: destinations[3]), sender: nil)
            destinations[3].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test4", source: destinations[3], destination: destinations[4]), sender: nil)
            destinations[4].prepare(usingCoordinatorFor: UIStoryboardSegue(identifier: "test5", source: destinations[4], destination: destinations[5]), sender: nil)
        }
    }
}
