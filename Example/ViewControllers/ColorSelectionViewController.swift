//
//  ColorSelectionViewController.swift
//  Example
//
//  Created by Milen Halachev on 21.01.20.
//  Copyright © 2020 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class ColorSelectionViewController: UIViewController, ColorConfigurable {
    
    @IBOutlet weak var coloredView: UIView!
    
    var color: UIColor!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.coloredView.backgroundColor = self.color
    }
    
    @IBAction func redAction() {
        
        self.performSegue(withIdentifier: "showRed", sender: nil) { (source, destination: ColorConfigurable) in
            
            destination.color = .red
        }
    }
    
    @IBAction func yellowAction() {
        
        self.performSegue(withIdentifier: "showYellow", sender: nil) { (source, destination: ColorConfigurable) in
            
            destination.color = .yellow
        }
    }
}
