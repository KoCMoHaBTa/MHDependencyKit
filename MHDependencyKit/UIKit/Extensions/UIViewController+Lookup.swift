//
//  UIViewController+Lookup.swift
//  MHDependencyKit
//
//  Created by Milen Halachev on 3.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func lookupAll<T>(of type: T.Type) -> [T] {
        
        var result = [T]()
        
        if let controller = self as? T {
            
            result.append(controller)
        }
        
        for child in self.children {
            
            let matches = child.lookupAll(of: type)
            result.append(contentsOf: matches)
        }
        
        return result
    }
    
    func lookupFirst<T>(of type: T.Type) -> T? {
        
        if let controller = self as? T {
            
            return controller
        }
        
        if let child = self.children.first as? T {
            
            return child
        }
        
        return nil
    }
}
