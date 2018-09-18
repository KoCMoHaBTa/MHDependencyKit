//
//  SegueCoordinator.swift
//  MHAppKit
//
//  Created by Milen Halachev on 10/18/16.
//  Copyright © 2016 Milen Halachev. All rights reserved.
//

import Foundation

/**
 SegueCoordinator is used to register depndency resolving handlers and resolve dependencies between 2 view controllers.
 
 It solves the problem of the dependecy hell management between view controllers in any app.
 
 - note: The automatic dependecy segue resolver works by swizzling the `prepareForSegue:sender:` method
 - note: In order for automatic dependecy segue resolver to work - you must use segues and you must call super if you override `prepareForSegue:sender:` method
 
 How to use:
    - register your prepare handlers that resolve your dependencies between 2 view controllers
    - automatic - when any segue is triggered - all handlers that are applying to the source and destination will be called
    - manual - by calling any of the provided `prepare` methods on the receiver
 
 Check `SegueCoordinatorTests` for more info and details.
 
 */

open class SegueCoordinator {
    
    public typealias Identifier = String
    public typealias Sender = Any
    
    ///The underlaying storage of all prepare handlers
    fileprivate var prepareHandlers: [PrepareHandler] = []
    
    ///A SegueCoordinator can be composed of multiple childs
    public var childCoordinators: [SegueCoordinator] = []
    
    ///A value that can be used by the client to store custom data
    public var userInfo: Any?
}

extension SegueCoordinator {
    
    fileprivate struct PrepareHandler {
        
        private let handler: (UIStoryboardSegue, Sender?) -> Void
        
        init(handler: @escaping (UIStoryboardSegue, Sender?) -> Void) {
            
            self.handler = handler
        }
        
        func prepare(for segue: UIStoryboardSegue, sender: Sender?) {
            
            self.handler(segue, sender)
        }
    }
}

extension SegueCoordinator {
    
    ///A default shared instance of SegueCoordinator
    public static let `default` = SegueCoordinator()
}

//MARK: - Preparing Segues

extension Collection where Element == SegueCoordinator {
    
    fileprivate var prepareHandlers: [SegueCoordinator.PrepareHandler] {
        
        return self.reduce([]) { (prepareHandlers, coordinator) -> [SegueCoordinator.PrepareHandler] in
            
            var prepareHandlers = prepareHandlers
            prepareHandlers.append(contentsOf: coordinator.prepareHandlers)
            prepareHandlers.append(contentsOf: coordinator.childCoordinators.prepareHandlers)
            return prepareHandlers
        }
    }
}

extension SegueCoordinator {
     
    ///Prepares a segue's source and destination based on all stored handlers. Also updates the destination `segueCoordinator` reference
    open func prepare(for segue: UIStoryboardSegue, sender: Sender? = nil) {
        
        //associate the coordinator with the destination
        segue.destination.segueCoordinator = segue.source.segueCoordinator
        
        //try to find an instance of SeguePrepareHandler based on any combination of criterias, like segue identifier, source, destination, sender
        self.prepareHandlers.forEach { (handler) in
            
            handler.prepare(for: segue, sender: sender)
        }
        
        //also iterate over the child coordnators
        self.childCoordinators.prepareHandlers.forEach { (handler) in
            
            handler.prepare(for: segue, sender: sender)
        }
    }
    
    ///Creates a segue based on the arguments and prepare for it
    open func prepare(identifier: Identifier? = nil, source: UIViewController, destination: UIViewController, sender: Sender? = nil) {
        
        let segue = UIStoryboardSegue(identifier: identifier, source: source, destination: destination)
        self.prepare(for: segue, sender: sender)
    }
}

//MARK: - Adding Prepare Handlers

extension SegueCoordinator {
    
    private func lookupAll<T>(controller: UIViewController, ofType type: T.Type) -> [T] {
        
        var result = [T]()
        
        if let controller = controller as? T {
            
            result.append(controller)
        }
        
        for child in controller.children {
            
            let matches = lookupAll(controller: child, ofType: type)
            result.append(contentsOf: matches)
        }
        
        return result
    }
    
    private func lookupFirst<T>(controller: UIViewController, ofType type: T.Type) -> T? {
        
        if let controller = controller as? T {
            
            return controller
        }
        
        if let child = controller.children.first as? T {
            
            return child
        }
        
        return nil
    }
    
    private func _addPrepareHandler<Source, Destination>(_ handler: @escaping (Identifier?, Source, Destination, Sender?) -> Void) {
        
        let seguePrepareHandler = PrepareHandler { [weak self] (segue, sender) in
            
            guard let source = self?.lookupFirst(controller: segue.source, ofType: Source.self) else {
                
                return
            }
            
            let destinations = self?.lookupAll(controller: segue.destination, ofType: Destination.self) ?? []
            for destination in destinations {
                
                let identifier = segue.identifier
                handler(identifier, source, destination, sender)
            }
        }
        
        self.prepareHandlers.append(seguePrepareHandler)
    }
    
    ///Adds a prepare handler for Any Source and Any Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Identifier?, Source, Destination, Sender?) -> Void) {
        
        _addPrepareHandler(handler)
    }
    
    ///Adds a prepare handler for UIViewController Source and UIViewController Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Identifier?, Source, Destination, Sender?) -> Void)
    where Source: UIViewController, Destination: UIViewController {
        
        _addPrepareHandler(handler)
    }
    
    ///Adds a prepare handler for Any Source and UIViewController Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Identifier?, Source, Destination, Sender?) -> Void)
    where Destination: UIViewController {
        
        _addPrepareHandler(handler)
    }
    
    ///Adds a prepare handler for UIViewController Source and Any Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Identifier?, Source, Destination, Sender?) -> Void)
    where Source: UIViewController {
        
        _addPrepareHandler(handler)
    }
}

extension SegueCoordinator {
    
    ///Adds a prepare handler for Any Source and Any Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Source, Destination) -> Void) {
        
        self.addPrepareHandler { (_, source: Source, destination: Destination, _) in
            
            handler(source, destination)
        }
    }
    
    ///Adds a prepare handler for UIViewController Source and UIViewController Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Source, Destination) -> Void)
    where Source: UIViewController, Destination: UIViewController {
        
        self.addPrepareHandler { (_, source: Source, destination: Destination, _) in
            
            handler(source, destination)
        }
    }
    
    ///Adds a prepare handler for Any Source and UIViewController Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Source, Destination) -> Void)
    where Destination: UIViewController {
        
        self.addPrepareHandler { (_, source: Source, destination: Destination, _) in
            
            handler(source, destination)
        }
    }
    
    ///Adds a prepare handler for UIViewController Source and Any Destination
    public func addPrepareHandler<Source, Destination>(_ handler: @escaping (Source, Destination) -> Void)
    where Source: UIViewController {
        
        self.addPrepareHandler { (_, source: Source, destination: Destination, _) in
            
            handler(source, destination)
        }
    }
}

//MARK: - Context Handlers

extension SegueCoordinator {

    /**
     Adds a context handler to the receiver. A context handler is such handler that will be applied to any combination of relationship between source and destination.
     For example if you present 5 screens - a context handler can be used to resolve dependencies between the first and the last one.
     
     - note: The source must be of class type.
     */
    
    public func addContextHandler<Source, Destination>(_ handler: @escaping (Source, Destination) -> Void) {
                
        weak var weakSource: AnyObject? = nil
        
        self.addPrepareHandler { (_, source: Source, _, _) in
         
            weakSource = source as AnyObject
        }
        
        self.addPrepareHandler { (_, _, destination: Destination, _) in
            
            if let source = weakSource as? Source {
                
                handler(source, destination)
            }
        }
    }
}

