//
//  TextInputConfigurable.swift
//  Example
//
//  Created by Milen Halachev on 23.01.19.
//  Copyright © 2019 KoCMoHaBTa. All rights reserved.
//

import Foundation

protocol TextInputConfigurable: AnyObject {
    
    var textInputValue: String? { get set }
}
