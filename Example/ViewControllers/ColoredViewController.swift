//
//  ColoredViewController.swift
//  Example
//
//  Created by Milen Halachev on 20.01.20.
//  Copyright © 2020 KoCMoHaBTa. All rights reserved.
//

import Foundation
import UIKit

class ColoredViewController: UIViewController, ColorConfigurable {
    
    @IBInspectable var color: UIColor!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = self.color
    }
}

class SplashViewController: ColoredViewController {}

class NewsfeedViewController: ColorSelectionViewController {}
class SingleUserFeedViewController: ColoredViewController {}

class EngageSummaryViewController: UIViewController {}
class ScheduledBroadcastsViewController: ColoredViewController {}
class SentBroadcastsViewController: ColoredViewController {}
class ComposeBroadcastsViewController: ColoredViewController {}

class ProfileViewController: ColoredViewController {}
