//
//  ColorConfigurable.swift
//  Example
//
//  Created by Milen Halachev on 21.01.20.
//  Copyright © 2020 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

protocol ColorConfigurable: UIViewController {
    
    var color: UIColor! { get set }
}
