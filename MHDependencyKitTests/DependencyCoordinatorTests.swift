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
            
            c1.resolveDependencies(from: String(), to: Int())
        }
    }
}
