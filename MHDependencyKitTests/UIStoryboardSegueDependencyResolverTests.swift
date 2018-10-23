//
//  UIStoryboardSegueDependencyResolverTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class UIStoryboardSegueDependencyResolverTests: XCTestCase {
    
    //When resolving dependnecies using segue and sender
    //- the sender should match the expected type
    func testWithExpectedSender() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 1
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIStoryboardSegueDependencyResolver(handler: { (sender: Int, segue) in
                
                XCTAssertEqual(sender, 5)
                XCTAssertEqual(segue.identifier, "5")
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(fromSender: 5, to: UIStoryboardSegue(identifier: "5", source: UIViewController(), destination: UIViewController()))
            coordinator.resolveDependencies(fromSender: "5", to: UIStoryboardSegue(identifier: "6", source: UIViewController(), destination: UIViewController()))
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: "7", source: UIViewController(), destination: UIViewController()))
        }
    }
    
    //When resolving dependnecies using segue and sender
    //- handler should be called when no particular sender is expeted
    func testWithUnexpectedSender() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 3
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIStoryboardSegueDependencyResolver(handler: { (segue) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(fromSender: 5, to: UIStoryboardSegue(identifier: "5", source: UIViewController(), destination: UIViewController()))
            coordinator.resolveDependencies(fromSender: "5", to: UIStoryboardSegue(identifier: "6", source: UIViewController(), destination: UIViewController()))
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: "7", source: UIViewController(), destination: UIViewController()))
        }
    }
    
    //When resolving dependnecies using segue without sender
    //- the sender should match
    func testWithoutSender() {
        
        self.performExpectation { (e) in
            
            e.expectedFulfillmentCount = 1
            
            let coordinator = DependencyCoordinator()
            
            coordinator.register(dependencyResolver: UIStoryboardSegueDependencyResolver(handler: { (sender: Int, segue) in
                
                XCTFail()
            }))
            
            coordinator.register(dependencyResolver: UIStoryboardSegueDependencyResolver(handler: { (segue) in
                
                e.fulfill()
            }))
            
            coordinator.resolveDependencies(fromSender: nil, to: UIStoryboardSegue(identifier: "7", source: UIViewController(), destination: UIViewController()))
        }
    }
}
