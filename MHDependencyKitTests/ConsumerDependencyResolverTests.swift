//
//  ConsumerDependencyResolverTests.swift
//  MHDependencyKitTests
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import XCTest
@testable import MHDependencyKit

class ConsumerDependencyResolverTests: XCTestCase {
    
    /**
     When no explicit consumer type is defined:
     - the handler should be called with the given argument
     - the argument should match
     */
    func testAnyConsumerDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyConsumerDependencyResolver(handler: { (consumer) in
                
                XCTAssertEqual(consumer as? String, "5")
                e.fulfill()
            })
            
            resolver.resolveDependencies(to: "5")
        }
    }
    
    /**
     When no concrete consumer type is defined:
     - the handler should be called with the given argument only when the type match
     - the argument should match
     */
    func testConcreteConsumerDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyConsumerDependencyResolver(handler: { (consumer: String) in
                
                XCTAssertEqual(consumer, "5")
                e.fulfill()
            })
            
            resolver.resolveDependencies(to: "5")
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyConsumerDependencyResolver(handler: { (consumer: String) in
                
                XCTFail()
            })
            
            resolver.resolveDependencies(to: 5)
            e.fulfill()
        }
    }
    
    /**
     When AnyConsumerDependencyResolver is represented as AnyDependencyResolver:
     - it should resolve dependencies only when the provider is Void
     */
    func testAnyConsumerDependencyResolverAsAnyDependencyResolver() {
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer) in
                
                XCTAssertEqual(consumer as? Int, 5)
                e.fulfill()
            }))
            
            resolver.resolveDependencies(from: (), to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer) in
                
                XCTFail()
            }))
            
            resolver.resolveDependencies(from: "void", to: 5)
            e.fulfill()
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: Int) in
                
                XCTAssertEqual(consumer, 5)
                e.fulfill()
            }))
            
            resolver.resolveDependencies(from: (), to: 5)
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: Int) in
                
                XCTFail()
            }))
            
            resolver.resolveDependencies(from: "void".hashValue, to: 5)
            e.fulfill()
        }
        
        self.performExpectation { (e) in
            
            let resolver = AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer) in
                
                XCTFail()
            }))
            
            resolver.resolveDependencies(from: 5, to: ())
            e.fulfill()
        }
    }
    
    /**
     When AnyConsumerDependencyResolver is composed as AnyDependencyResolver with other instances of AnyDependencyResolver that have a provider:
     - it should resolve dependencies only when the provider is Void
     */
    func testIncorrectAnyConsumerDependencyResolverComposition() {
        
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
                }),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer) in
                    
                    XCTFail()
                })),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: Int) in
                    
                    XCTFail()
                })),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: String) in
                    
                    XCTFail()
                }))
            ]
            
            e.expectedFulfillmentCount = 4
            resolver.resolveDependencies(from: "5", to: 5)
        }
    }
    
    /**
     When AnyConsumerDependencyResolver is composed as AnyDependencyResolver with other instances of AnyDependencyResolver that have a provider:
     - it should resolve dependencies only when the provider is Void
     */
    func testCorrectAnyConsumerDependencyResolverComposition() {
        
        self.performExpectation { (e) in
            
            let resolver = [
                
                AnyDependencyResolver(handler: { (provider, consumer) in
                    
                    XCTAssertEqual(provider is Void, true)
                    XCTAssertEqual(consumer as? Int, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer: Int) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Int) in
                    
                    XCTAssertEqual(provider is Void, true)
                    XCTAssertEqual(consumer, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider: String, consumer) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(handler: { (provider: Void, consumer: Int) in
                    
                    XCTAssertEqual(consumer, 5)
                    
                    e.fulfill()
                }),
                AnyDependencyResolver(handler: { (provider, consumer: Void) in
                    
                    XCTFail()
                }),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer) in
                    
                    XCTAssertEqual(consumer as? Int, 5)
                    
                    e.fulfill()
                })),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: Int) in
                    
                    XCTAssertEqual(consumer, 5)
                    
                    e.fulfill()
                })),
                AnyDependencyResolver(other: AnyConsumerDependencyResolver(handler: { (consumer: String) in
                    
                    XCTFail()
                }))
            ]
            
            e.expectedFulfillmentCount = 5
            resolver.resolveDependencies(from: (), to: 5)
        }
    }
}
