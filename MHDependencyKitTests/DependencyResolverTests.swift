//
//  DependencyResolverTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class DependencyResolverTests: XCTestCase {
    
    /**
     When no explicit types are defined:
     - the handler should be called with the given arguments
     - the arguments should match
     */
    func testAnyAnyDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider, consumer) in
                
                XCTAssertEqual(provider as? String, "5")
                XCTAssertEqual(consumer as? Int, 5)
                
                e.fulfill()
            }
                
            resolver.resolveDependencies(from: "5", to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider, consumer) in
                
                XCTAssertEqual(provider is Void, true)
                XCTAssertEqual(consumer is UIView.Type, true)
                
                e.fulfill()
            }
            
            resolver.resolveDependencies(from: (), to: UIView.self)
        }
    }
    
    /**
     When any provider and concrete consumer is defined:
     - the handler should not care about the provider type
     - the handler should be called only when a consumer from the matching type is given
     */
    func testAnyConcreteDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider, consumer: Int) in
                
                XCTAssertEqual(provider as? String, "5")
                XCTAssertEqual(consumer, 5)
                
                e.fulfill()
            }
            
            resolver.resolveDependencies(from: "5", to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider, consumer: Int) in
                
                XCTFail()
            }
            
            resolver.resolveDependencies(from: 5, to: "five")
            e.fulfill()
        }
    }
    
    /**
     When concrete provider and any consumer is defined:
     - the handler should be called only when a provider from the matching type is given
     - the handler should not care about the consumer type
     */
    func testConcreteAnyDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer) in
                
                XCTAssertEqual(provider, "5")
                XCTAssertEqual(consumer as? Int, 5)
                
                e.fulfill()
            }
            
            resolver.resolveDependencies(from: "5", to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer) in
                
                XCTFail()
            }
            
            resolver.resolveDependencies(from: 5, to: "five")
            e.fulfill()
        }
    }
    
    /**
     When concrete provider and consumer is defined:
     - the handler should be called only when a consumer and a provider from the respective matching types are given
     */
    func testConcreteConcreteDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer: Int) in
                
                XCTAssertEqual(provider, "5")
                XCTAssertEqual(consumer, 5)
                
                e.fulfill()
            }
            
            resolver.resolveDependencies(from: "5", to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer: Int) in
                
                XCTFail()
            }
            
            resolver.resolveDependencies(from: 5, to: "five")
            e.fulfill()
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer: Int) in
                
                XCTFail()
            }
            
            resolver.resolveDependencies(from: "5", to: ())
            e.fulfill()
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver { (provider: String, consumer: Int) in
                
                XCTFail()
            }
            
            resolver.resolveDependencies(from: String.self, to: 5)
            e.fulfill()
        }
    }
    
    /**
     When multiple instance of AnyDependencyResolver are composed
     And correct arguments are given
     - only the matchin ones should be triggered, based on the provider and the consumer types
     - the arguments should match
     */
    func testCorrectDependencyResolverComposition() {
        
        self.performExpectation { (e) in
            
            let resolver = [
                
                AnyDependencyResolver(handler: { (provider, consumer) in
                    
                    XCTAssertEqual(provider as? String, "5")
                    XCTAssertEqual(consumer as? Int, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer: Int) in
                    
                    XCTAssertEqual(provider, "5")
                    XCTAssertEqual(consumer, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Int) in
                    
                    XCTAssertEqual(provider as? String, "5")
                    XCTAssertEqual(consumer, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer) in
                    
                    XCTAssertEqual(provider, "5")
                    XCTAssertEqual(consumer as? Int, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: Void, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Void) in
                    
                    XCTFail()
                })
            ]
            
            e.expectedFulfillmentCount = 4
            resolver.resolveDependencies(from: "5", to: 5)
        }
    }
    
    /**
     When multiple instance of AnyDependencyResolver are composed
     And partially correct arguments are given
     - only the matchin ones should be triggered, based on the provider and the consumer types
     - the arguments should match
     */
    func testPartiallyCorrectDependencyResolverComposition() {
        
        self.performExpectation { (e) in
            
            let resolver = [
                
                AnyDependencyResolver(handler: { (provider, consumer) in
                    
                    XCTAssertEqual(provider as? String, "5")
                    XCTAssertEqual(consumer is Void, true)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer) in
                    
                    XCTAssertEqual(provider, "5")
                    XCTAssertEqual(consumer is Void, true)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: Void, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Void) in
                    
                    XCTAssertEqual(provider as? String, "5")
                    
                    e.fulfill()
                })
            ]
            
            e.expectedFulfillmentCount = 3
            resolver.resolveDependencies(from: "5", to: ())
        }
    }
    
    /**
     When multiple instance of AnyDependencyResolver are composed
     And incorrect arguments are given
     - nothing should be matched, except if there is Any/Any handler
     */
    func testIncorrectDependencyResolverComposition() {
        
        self.performExpectation { (e) in
            
            let resolver = [
                
                AnyDependencyResolver(handler: { (provider, consumer) in
                    
                    XCTAssertEqual(provider is String.Type, true)
                    XCTAssertEqual(consumer is AnyHashable.Type, true)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider: Void, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Void) in
                    
                    XCTFail()
                })
            ]
            
            resolver.resolveDependencies(from: String.self, to: AnyHashable.self)
        }
    }
}
