//
//  UIStoryboardSegueDependencyResolver.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

public struct UIStoryboardSegueDependencyResolver<Sender>: DependencyResolver {
    
    private let handler: (Sender, UIStoryboardSegue) -> Void
    
    //MARK: - Init
    
    public init(handler: @escaping (Sender, UIStoryboardSegue) -> Void) {
        
        self.handler = handler
    }
    
    //TODO: Consider adding overload with exploded segue -> (sender, id, source, destination)
    
    //MARK: - DependencyResolver
    
    public typealias Provider = Sender
    public typealias Consumer = UIStoryboardSegue
    
    public func resolveDependencies(from provider: Provider, to consumer: Consumer) {
        
        self.handler(provider, consumer)
    }
}

extension UIStoryboardSegueDependencyResolver where Sender == Void {
    
    public init(handler: @escaping (UIStoryboardSegue) -> Void) {
        
        self.handler = { (sender, segue) in
            
            handler(segue)
        }
    }
}
