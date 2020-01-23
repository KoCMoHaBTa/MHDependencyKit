//
//  WorkflowDependencyCoordinatorTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 9.10.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class WorkflowDependencyCoordinatorTests: XCTestCase {
    
    func testSetupFromCodeForReceiver() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4 //main + workflow resolver calls
            
            let vc1 = UIViewController()
            vc1.dependencyCoordinator = DependencyCoordinator()
            vc1.dependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                
                e.fulfill() //should be called 3 times
            }))
            
            //present a new modal scene
            var vc2: UIViewController? = UIViewController()
            vc1.resolveDependencies(to: vc2) //this should trigger the main dependency resolver
            
            //setup workflow dependency coordinator for a new modal scene
            vc2!.setupWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in
                
                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                    
                    e.fulfill() //should be called 1 time
                }))
            }
            
            //push a new screen to the modal scene
            var vc3: UIViewController? = UIViewController()
            vc2!.resolveDependencies(to: vc3) //this should trigger the main and the workflow dependency resolvers

            //close the modal scene
            vc3 = nil
            vc2 = nil
            
            //push a new screen to screen 1 ->
            let vc4 = UIViewController()
            vc1.resolveDependencies(to: vc4) // this should NOT trigger the workflow depenency resolver - only the main one
        }
    }
    
    func testSetupFromCodeForDestination() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4 //main + workflow resolver calls
            
            let vc1 = UIViewController()
            vc1.dependencyCoordinator = DependencyCoordinator()
            vc1.dependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                
                e.fulfill() //should be called 3 times
            }))
            
            //setup workflow dependency coordinator for a new modal scene
            vc1.setupDestinationWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in
                
                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                    
                    e.fulfill() //should be called 1 time
                }))
            }
            
            //present a new modal scene
            var vc2: UIViewController? = UIViewController()
            vc1.resolveDependencies(to: vc2!) //this should trigger the main dependency resolver
            
            //push a new screen to the modal scene
            var vc3: UIViewController? = UIViewController()
            vc2!.resolveDependencies(to: vc3!) //this should trigger the main and the workflow dependency resolvers

            //close the modal scene
            vc3 = nil
            vc2 = nil
            
            //push a new screen to screen 1 ->
            let vc4 = UIViewController()
            vc1.resolveDependencies(to: vc4) // this should NOT trigger the workflow depenency resolver - only the main one
        }
    }
    
    func testSetupFromSegue() {
        
        class VC1: UIViewController {}
        class VC2: UIViewController {}
        class VC3: UIViewController {}
        class VC4: UIViewController {}
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4 //main + workflow resolver calls
            
            let vc1 = VC1()
            vc1.dependencyCoordinator = DependencyCoordinator()
            vc1.dependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                
                e.fulfill() //should be called 3 times
            }))
            
            //present a new modal scene
            var vc2: UIViewController? = VC2()
            vc1._performSegue(false, withIdentifier: "step1", sender: nil) { (workflowDependencyCoordinator) in
                
                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination) in
                    
                    e.fulfill() //should be called 1 times
                }))
            }
            vc1.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: vc1, destination: vc2!))  //this should trigger the main dependency resolver
            
            //push a new screen to the modal scene
            var vc3: UIViewController? = VC3()
            vc2!.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step2", source: vc2!, destination: vc3!)) //this should trigger the main and the workflow dependency resolvers

            //close the modal scene
            vc3 = nil
            vc2 = nil
            
            //push a new screen to screen 1 ->
            let vc4 = VC4()
            vc1.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step3", source: vc1, destination: vc4)) // this should NOT trigger the workflow depenency resolver - only the main one
        }
    }
    
    //should be able to open new workflow coordinator that support hopping
    func testGoingBackAndForwardWhileHoppingWithWorkflowDependencyCoordinatorUsingSegue() {

        self.performExpectation { (e) in

            e.expectedFulfillmentCount = 2

            let mainViewController = UIViewController()
            mainViewController.dependencyCoordinator = DependencyCoordinator()
            var exampleNavigationStack: [UIViewController] = []

            mainViewController._performSegue(false, withIdentifier: "test", sender: nil) { (workflowDependencyCoordinator) in

                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UIPageViewController) in

                    e.fulfill() //should be caled twice

                    destination.title = "this is the correct title"
                }))
            }

            //push 1 view controller
            exampleNavigationStack.append(UITableViewController())
            mainViewController.resolveDependencies(to: exampleNavigationStack[0])

            //push the second one, correct view controller
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            //go back once
            exampleNavigationStack.removeLast()

            //push again the second one, correct view controller - this should again trigger the context handler
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            XCTAssertEqual(exampleNavigationStack.last?.title, "this is the correct title")
        }
    }
    
    //this is the same as the above
    func testGoingBackAndForwardWhileHoppingWithDestinationWorkflowDependencyCoordinatorUsingCode() {

        self.performExpectation { (e) in

            e.expectedFulfillmentCount = 2

            let mainViewController = UIViewController()
            mainViewController.dependencyCoordinator = DependencyCoordinator()
            var exampleNavigationStack: [UIViewController] = []
            
            mainViewController.setupDestinationWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in

                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UIPageViewController) in

                    e.fulfill() //should be caled twice

                    destination.title = "this is the correct title"
                }))
            }

            //push 1 view controller
            exampleNavigationStack.append(UITableViewController())
            mainViewController.resolveDependencies(to: exampleNavigationStack[0])

            //push the second one, correct view controller
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            //go back once
            exampleNavigationStack.removeLast()

            //push again the second one, correct view controller - this should again trigger the context handler
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            XCTAssertEqual(exampleNavigationStack.last?.title, "this is the correct title")
        }
    }
    
    //this is the same as the above
    func testGoingBackAndForwardWhileHoppingWithDestinationWorkflowDependencyCoordinatorUsingCodeSimplified() {

        self.performExpectation { (e) in

            e.expectedFulfillmentCount = 1

            let mainViewController = UIViewController()
            mainViewController.dependencyCoordinator = DependencyCoordinator()
            var exampleNavigationStack: [UIViewController] = []
            
            mainViewController.setupDestinationWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in

                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UIPageViewController) in

                    e.fulfill() //should be caled twice

                    destination.title = "this is the correct title"
                }))
            }

            //push 1 view controller
            exampleNavigationStack.append(UITableViewController())
            mainViewController.resolveDependencies(to: exampleNavigationStack[0])

            //push the second one, correct view controller
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])
            
            XCTAssertEqual(exampleNavigationStack.last?.title, "this is the correct title")
        }
    }
    
    func testGoingBackAndForwardWhileHoppingWithWorkflowDependencyCoordinatorUsingCode() {

        self.performExpectation { (e) in

            e.expectedFulfillmentCount = 2

            let mainViewController = UIViewController()
            mainViewController.dependencyCoordinator = DependencyCoordinator()
            var exampleNavigationStack: [UIViewController] = []

            //push 1 view controller
            exampleNavigationStack.append(UITableViewController())
            mainViewController.resolveDependencies(to: exampleNavigationStack[0])
            
            exampleNavigationStack[0].setupWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in
                
                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UIPageViewController) in

                    e.fulfill() //should be caled twice

                    destination.title = "this is the correct title"
                }))
            }

            //push the second one, correct view controller
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            //go back once
            exampleNavigationStack.removeLast()

            //push again the second one, correct view controller - this should again trigger the context handler
            exampleNavigationStack.append(UIPageViewController())
            exampleNavigationStack[0].resolveDependencies(to: exampleNavigationStack[1])

            XCTAssertEqual(exampleNavigationStack.last?.title, "this is the correct title")
        }
    }
    
    func testTemporaryAndWorkflowCoordinatorCompositionWhenGoingBackAndForward() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 4
            
            let root = UIViewController()
            let rootDependencyCoordinator = DependencyCoordinator()
            rootDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (s, d) in
                //just to transfer the coordinators
            }))
            root.dependencyCoordinator = rootDependencyCoordinator
            
            XCTAssertEqual(root.dependencyCoordinator.kind, .custom)
            XCTAssertEqual(root.dependencyCoordinator.childCoordinators.count, 0)
            
            //iteration 1
            root.registerTemporaryContextDependencyResolver { (source, destination) in
                
                //this shold be called 2 times - 1 for UINavigationController and 1 for UIViewController
                e.fulfill()
                
                destination.setupWorkflowDependencyCoordinator { (workflowCoordiantor) in

                }
            }
            
            XCTAssertEqual(root.dependencyCoordinator.kind, .custom)
            XCTAssertEqual(root.dependencyCoordinator.childCoordinators.count, 1)
            
            root.resolveDependencies(to: UINavigationController(rootViewController: UIViewController()))
            
            XCTAssertEqual(root.dependencyCoordinator.kind, .custom)
            XCTAssertEqual(root.dependencyCoordinator.childCoordinators.count, 0)
            
            
            
            
            //iteration 2
            root.registerTemporaryContextDependencyResolver { (source, destination) in
                
                //this shold be called 2 times - 1 for UINavigationController and 1 for UIViewController
                e.fulfill()
                
                destination.setupWorkflowDependencyCoordinator { (workflowCoordiantor) in
                    
                }
            }
            
            XCTAssertEqual(root.dependencyCoordinator.kind, .custom)
            XCTAssertEqual(root.dependencyCoordinator.childCoordinators.count, 1)
            
            root.resolveDependencies(to: UINavigationController(rootViewController: UIViewController()))
            
            XCTAssertEqual(root.dependencyCoordinator.kind, .custom)
            XCTAssertEqual(root.dependencyCoordinator.childCoordinators.count, 0)
        }
    }
    
    func testContainerTransferOfWorkfldows() {
        
        let vc = UIViewController()
        let vcdc = DependencyCoordinator()
        vc.dependencyCoordinator = vcdc
        
        let nav = UINavigationController(rootViewController: vc)
        let navdc = DependencyCoordinator()
        nav.dependencyCoordinator = navdc
        
        var wdc: DependencyCoordinator?
        nav.setupWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in
            
            wdc = workflowDependencyCoordinator
        }
        
        XCTAssertEqual(nav.dependencyCoordinator, wdc)
        XCTAssertEqual(vc.dependencyCoordinator, wdc)
    }
    
    //Branches should have isolated dependencies
    func testBranchingWorkflowsConflicting() {
        
        let rootDC = DependencyCoordinator()
        rootDC.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UITableViewController, destination: UITableViewController) in
            
            destination.title = source.title
        }))
        
        let root = UITableViewController()
        root.dependencyCoordinator = rootDC
        root.title = "root"
        XCTAssertEqual(root.title, "root")
        
        let tab = UITabBarController()       //just a context placeholder, mimicing branching
        root.resolveDependencies(to: tab)
        XCTAssertEqual(tab.title, nil)
        
        let tab1 = UITableViewController()   //we want this to override root title
        tab.resolveDependencies(to: tab1)
        tab1.setupWorkflowDependencyCoordinator()
        tab1.title = "tab1"
        XCTAssertEqual(tab1.title, "tab1")
        
        let tab2 = UITableViewController()   //we want this to inherit the root title
        tab.resolveDependencies(to: tab2)
        tab2.setupWorkflowDependencyCoordinator()
        XCTAssertEqual(tab2.title, "root")
        
        //add new screen to tab1 that does not fulful the resolver
        let tab1_1 = UIViewController()
        tab1.resolveDependencies(to: tab1_1)
        XCTAssertEqual(tab1_1.title, nil)
        
        //add new screen to tab2 - this should not interfere with screens showing on the next tab
        let tab2_1 = UITableViewController()
        tab2.resolveDependencies(to: tab2_1)
        XCTAssertEqual(tab2_1.title, "root")
        
        //add new screen to tab1_1 - this shold inherit the tab1 title, but does not (the bug we are trying to fix)
        let tab1_2 = UITableViewController()
        tab1_1.resolveDependencies(to: tab1_2)
        XCTAssertEqual(tab1_2.title, "tab1")
    }
    
    //Branches should have isolated dependencies
    func testBranchingWorkflowsNotConflicting() {
        
        let rootDC = DependencyCoordinator()
        rootDC.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source: UITableViewController, destination: UITableViewController) in
            
            destination.title = source.title
        }))
        
        let root = UITableViewController()
        root.dependencyCoordinator = rootDC
        root.title = "root"
        XCTAssertEqual(root.title, "root")
        
        let tab = UITabBarController()       //just a context placeholder, mimicing branching
        root.resolveDependencies(to: tab)
        XCTAssertEqual(tab.title, nil)
        
        let tab1 = UITableViewController()   //we want this to override root title
        tab.resolveDependencies(to: tab1)
        tab1.title = "tab1"
        XCTAssertEqual(tab1.title, "tab1")
        
        let tab2 = UITableViewController()   //we want this to inherit the root title
        tab.resolveDependencies(to: tab2)
        XCTAssertEqual(tab2.title, "root")
        
        //add new screen to tab1 that does not fulful the resolver
        let tab1_1 = UIViewController()
        tab1.resolveDependencies(to: tab1_1)
        XCTAssertEqual(tab1_1.title, nil)
        
        //add new screen to tab1_1 - this shold inherit the tab1 title, but does not (the bug we are trying to fix)
        let tab1_2 = UITableViewController()
        tab1_1.resolveDependencies(to: tab1_2)
        XCTAssertEqual(tab1_2.title, "tab1")
    }
    
    //This is very special test case. It checks whenever the behaviour of the dependency coordinators is working properly when workflows and temporary resovers are used alongside
    //1) First things to be resolved should be the default dependencies
    //2) Second things to be resolved should be the workflow specific dependencies
    //3) Third thing to be resolved should be any temporary dependnecies
    func testBranchesAndTemporaryReolsvers() {
        
        let root = UIViewController()
        root.dependencyCoordinator = DependencyCoordinator()
        root.dependencyCoordinator.register(dependencyResolver: UIViewControllerDependencyResolver { (source, destination) in
            
            destination.title = source.title
        })
        root.title = "root"
        
        let workflow = UIViewController()
        root.resolveDependencies(to: workflow)
        XCTAssertEqual(workflow.title, "root")
        
        workflow.setupWorkflowDependencyCoordinator()
        
        workflow.registerTemporaryContextDependencyResolver { (source, destination) in
            
            destination.title = "temp"
        }
        
        let vc = UIViewController()
        workflow.resolveDependencies(to: vc)
        XCTAssertEqual(vc.title, "temp")
    }
    
    //NOTE: Should investigate if these test cases are valind in the future
//    func testMultipleContextDestinationsEGTabBarControllerWithWorkflowDependencyCoordinator() {
//
//        class Root: UIViewController {}
//        class VC0: UIViewController {}
//        class VC1: UITableViewController {}
//        class VC2: UITableViewController {}
//        class VC3: UIViewController {}
//        class VC4: UITableViewController {}
//        class VC5: UITableViewController {}
//        class VC6: UITableViewController {}
//        class VC7: UIPageViewController {}
//        class VC8: UITableViewController {}
//
//        self.performExpectation { (e) in
//
//            e.expectedFulfillmentCount = 6
//
//            let mainViewController = Root()
//            mainViewController.dependencyCoordinator = DependencyCoordinator()
//
//            mainViewController._performSegue(false, withIdentifier: "test", sender: nil) { (workflowDependencyCoordinator) in
//
//                workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UITableViewController) in
//
//                    e.fulfill() //should be caled twice
//
//                    destination.title = "this is the correct title"
//                }))
//            }
//
//            let tabBarController = UITabBarController()
//            tabBarController.viewControllers = [
//
//                VC0(),
//                VC1(),
//                VC2(),
//                UINavigationController(rootViewController: VC3()),
//                UINavigationController(rootViewController: VC4()),
//                UINavigationController(rootViewController: VC5()),
//                VC6(),
//                VC7(),
//                VC8()
//            ]
//
////            stranen use-case -> iskame ot mainViewController da startirame workflow ot tabBarController
////            + da resolvenem vsi4ki dependencies ot tabBarController nadolu 4rez workflow-a
////
////            da ama ne stava 6toto realno dependency-tata se resolvevat ot mainViewController nadolu, koito ne e v workflow-a
////
////            trqq go osmislq hubavo, 4e tova si e expected ama i unexpected behaviour
////
////            !!! po-prosta analogiq -> Root -> Nav(VC) --- > kak trqq se resolve-nat tiq deps ----> ot root kum vc ili ot root kum nav kum vc
////
////            moje v toq case da izvikame izkustveno resolve ot Root kum Nav s workflow-a .... hmm nz
//
//            //move to the tab bar -> should resolve all dependencies to tabs containing UITableViewController
//            mainViewController.resolveDependencies(to: tabBarController)
//
//            XCTAssertEqual(tabBarController.viewControllers![0].title, nil)
//            XCTAssertEqual(tabBarController.viewControllers![1].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![2].title, "this is the correct title")
//            XCTAssertEqual((tabBarController.viewControllers![3] as! UINavigationController).viewControllers[0].title, nil)
//            XCTAssertEqual((tabBarController.viewControllers![4] as! UINavigationController).viewControllers[0].title, "this is the correct title")
//            XCTAssertEqual((tabBarController.viewControllers![5] as! UINavigationController).viewControllers[0].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![6].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![7].title, nil)
//            XCTAssertEqual(tabBarController.viewControllers![8].title, "this is the correct title")
//
//
//            //push a UITableViewController to one of the tabs - this should not resolve the same dependency
//            //actually it really should NOT, compared to using UIViewControllerContextDependencyResolver directly -> this is due to the workflow dependency coordinator (isolating the mainViewController from the ongoing workflow)
//            (tabBarController.viewControllers![3] as! UINavigationController).viewControllers.append(UITableViewController())
//            (tabBarController.viewControllers![3] as! UINavigationController).viewControllers[0].resolveDependencies(to: (tabBarController.viewControllers![3] as! UINavigationController).viewControllers[1])
//
//            XCTAssertEqual(tabBarController.viewControllers![0].title, nil)
//            XCTAssertEqual(tabBarController.viewControllers![1].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![2].title, "this is the correct title")
//            XCTAssertEqual((tabBarController.viewControllers![3] as! UINavigationController).viewControllers[0].title, nil)
//            XCTAssertEqual((tabBarController.viewControllers![3] as! UINavigationController).viewControllers[1].title, nil) // this is the speical one
//            XCTAssertEqual((tabBarController.viewControllers![4] as! UINavigationController).viewControllers[0].title, "this is the correct title")
//            XCTAssertEqual((tabBarController.viewControllers![5] as! UINavigationController).viewControllers[0].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![6].title, "this is the correct title")
//            XCTAssertEqual(tabBarController.viewControllers![7].title, nil)
//            XCTAssertEqual(tabBarController.viewControllers![8].title, "this is the correct title")
//        }
//    }
//
//    func testHoppingWithDestinationWorkflowDependencyCoordinator() {
//
//        self.performExpectation { (e) in
//
//            e.expectedFulfillmentCount = 5
//
//            let controller = UIViewController()
//            controller.dependencyCoordinator = DependencyCoordinator()
//
//            class MockViewController: UIViewController {
//
//                var value0: String?
//                var value2: String?
//            }
//
//            let destinations: [UIViewController] = [
//
//                UIViewController(),
//                UIViewController(),
//                MockViewController(),
//                UITableViewController()
//            ]
//
////            controller.performSegue(withIdentifier: "step0", sender: nil) { (workflowDependencyCoordinator) in
////
////
////            }
//
//            //move from initial to destionation 0
//            controller._performSegue(false, withIdentifier: "step0", sender: nil) { (source: UIViewController, destination: MockViewController) in
//
//                destination.value0 = "step0"
//
//                destination.setupWorkflowDependencyCoordinator { (workflowDependencyCoordinator) in
//
//                    workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: UITableViewController) in
//
//                        destination.title = "step1"
//                        e.fulfill()
//                    }))
//
//                    workflowDependencyCoordinator.register(dependencyResolver: UIViewControllerContextDependencyResolver(handler: { (source, destination: MockViewController) in
//
//                        destination.title = "step2"
//                        e.fulfill()
//                    }))
//                }
//
//                e.fulfill()
//            }
//            controller.prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step0", source: controller, destination: destinations[0]))
//
//            //move from destination 0 to destination 1
////            destinations[0]._performSegue(withIdentifier: "step1", sender: nil, executePerformSegue: false) { (source: UIViewController, destination: UITableViewController) in
////
////                destination.title = "step1"
////                e.fulfill()
////            }
//            destinations[0].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step1", source: destinations[0], destination: destinations[1]))
//
//            //move from destination 1 to destination 2
////            destinations[1]._performSegue(withIdentifier: "step2", sender: nil, executePerformSegue: false) { (source: UIViewController, destination: MockViewController) in
////
////                destination.value2 = "step2"
////                e.fulfill()
////            }
//            destinations[1].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step2", source: destinations[1], destination: destinations[2]))
//
//            //move from destination 2 to destination 3
////            destinations[2]._performSegue(withIdentifier: "step3", sender: nil, executePerformSegue: false) { (source: UIViewController, destination: UIViewController) in
////
////                //do nothing here
////                e.fulfill()
////            }
//            destinations[2].prepare(usingDependencyCoordinatorFromSender: nil, toSegue: UIStoryboardSegue(identifier: "step3", source: destinations[2], destination: destinations[3]))
//
//            DispatchQueue.main.async {
//
//                e.fulfill()
//
//                XCTAssertEqual((destinations[2] as? MockViewController)?.value0, "step0")
//                XCTAssertEqual((destinations[2] as? MockViewController)?.value2, "step2")
//                XCTAssertEqual((destinations[3] as? UITableViewController)?.title, "step1")
//            }
//
//        }
//    }
}
