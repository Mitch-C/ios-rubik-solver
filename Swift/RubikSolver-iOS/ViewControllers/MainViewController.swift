//
//  MainViewControllerSwift.swift
//  RubikSolver-iOS
//
//  Created by Mitchell on 20/11/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Solve an example of a cube configuration at startup in order to create (and cache)
        // the necessary pruning tables for the solver
        KociembaWrapper().solveExampleCubeConfiguration()
    }

}

