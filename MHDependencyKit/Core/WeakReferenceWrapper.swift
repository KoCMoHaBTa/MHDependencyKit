//
//  WeakReferenceWrapper.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 1.03.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation

class WeakReferenceWrapper<T: AnyObject> {
    
    weak var reference: T?
    
    init(reference: T) {
        
        self.reference = reference
    }
    
    func isTheSameReference(as object: T) -> Bool {
        
        guard let reference = self.reference else {
            
            return false
        }
        
        return reference === object
    }
}
