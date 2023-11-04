//
//  LaunchViewController.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 28/01/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet var constraintLogoBottom: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        UIView.animate(withDuration: 0.5) {
            self.constraintLogoBottom.constant = 400
        }
    }
    

   

}
