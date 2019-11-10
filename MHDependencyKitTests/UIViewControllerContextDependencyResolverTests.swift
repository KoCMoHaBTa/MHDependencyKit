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
    
    func testProtocolsUsage() {
        
        let resolver = UIViewControllerContextDependencyResolver { (source: TestConfigurable, destination: TestConfigurable) in
            
            destination.data = source.data
        }
        
        class TC: UIViewController, TestConfigurable {
            
            var data: String?
            
            convenience init(data: String?) {
                
                self.init()
                self.data = data
            }
        }
        
        let tc1 = TC(data: "tc1")
        let tc2 = TC(data: "tc2")
        let tc3 = TC(data: "tc3")
        
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: tc1, to: UITabBarController())
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: UIViewController(), to: tc2)
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: UIViewController(), to: UITabBarController())
        resolver.resolveDependencies(from: tc2, to: tc3)
        XCTAssertEqual(tc1.data, "tc1")
        XCTAssertEqual(tc2.data, "tc1")
        XCTAssertEqual(tc3.data, "tc1")
    }
    
    func testContextLooseLinear() {
        
        let resolver = UIViewControllerContextDependencyResolver { (source: TestConfigurable, destination: TestConfigurable) in
            
            destination.data = source.data
        }
        
        class TC: UIViewController, TestConfigurable {
            
            var data: String?
            
            convenience init(data: String?) {
                
                self.init()
                self.data = data
            }
        }
        
        let tc1: TC! = TC(data: "tc1")
        var tc2: TC! = TC(data: nil)
        let tc3: UIViewController! = UIViewController()
        let tc4: UIViewController! = UIViewController()
        let tc5 = TC(data: nil)
        
        resolver.resolveDependencies(from: tc1, to: tc2!)
        resolver.resolveDependencies(from: tc2, to: tc3!)
        resolver.resolveDependencies(from: tc3, to: tc4)
        tc2 = nil
        resolver.resolveDependencies(from: tc4, to: tc5)
        
        XCTAssertEqual(tc5.data, "tc1")
    }
    
    func testContextLooseBranches() {
        
        let resolver = UIViewControllerContextDependencyResolver { (source: TestConfigurable, destination: TestConfigurable) in
            
            destination.data = source.data
        }
        
        class TC: UIViewController, TestConfigurable {
            
            var data: String?
            
            convenience init(data: String?) {
                
                self.init()
                self.data = data
            }
        }
        
        let root = TC(data: "tc1")
        
        var branch1: TC! = TC(data: nil)
        let branch1_1: UIViewController! = UIViewController()
        let branch1_2: UIViewController! = UIViewController()
        
        let branch2: UIViewController! = UIViewController()
        let branch2_2 = TC(data: nil)
        
        //resolve root to branch 1 and 2
        resolver.resolveDependencies(from: root, to: branch1)
        resolver.resolveDependencies(from: root, to: branch2)
        
        //dig into branch 1
        resolver.resolveDependencies(from: branch1, to: branch1_1)
        resolver.resolveDependencies(from: branch1_1, to: branch1_2)
        
        //close branch 1
        branch1 = nil
        
        //dig into branch 2
        resolver.resolveDependencies(from: branch2, to: branch2_2)
        
        XCTAssertEqual(branch2_2.data, "tc1")
    }
    
    //When using UIViewControllerContextDependencyResolver
    //  - and we change the coordinator in between
    //  - the chnaged dependency coordinator should be preserved from the changed to the destination and all intermediate view controllers
    //  eg. VC1(DC1) -> VC2(DC1) -> VC3(DC1 -> DC2) -> VC4(DC2) -> VC5(DC2)
    //                           -> VC6(DC1)
    func testPreservingOfDependencyCoordinator() {
        
        let dc1 = DependencyCoordinator()
        let dc2 = DependencyCoordinator()
        
        let resolver = UIViewControllerContextDependencyResolver { (source: UITableViewController, destination: UICollectionViewController) in
            
        }
        
        let vc1 = UIViewController()
        vc1.dependencyCoordinator = dc1
        
        let vc2 = UIViewController()
        resolver.resolveDependencies(from: vc1, to: vc2)
        XCTAssertEqual(vc2.dependencyCoordinator, dc1)
        
        let vc3 = UIViewController()
        resolver.resolveDependencies(from: vc2, to: vc3)
        XCTAssertEqual(vc3.dependencyCoordinator, dc1)
        
        vc3.dependencyCoordinator = dc2
        XCTAssertEqual(vc3.dependencyCoordinator, dc2)
        
        let vc4 = UIViewController()
        resolver.resolveDependencies(from: vc3, to: vc4)
        XCTAssertEqual(vc4.dependencyCoordinator, dc2)
        
        let vc5 = UIViewController()
        resolver.resolveDependencies(from: vc4, to: vc5)
        XCTAssertEqual(vc5.dependencyCoordinator, dc2)
        
        let vc6 = UIViewController()
        resolver.resolveDependencies(from: vc2, to: vc6)
        XCTAssertEqual(vc6.dependencyCoordinator, dc1)
    }
}

private protocol TestConfigurable: class {
    
    var data: String? { get set }
}
