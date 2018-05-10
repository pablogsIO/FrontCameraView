//
//  ViewController.swift
//  FrontCameraExample
//
//  Created by Pablo on 08/05/2018.
//  Copyright © 2018 Pablo Garcia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var capturePreview: FrontCameraView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        capturePreview = FrontCameraView(frame: CGRect(x: self.view.frame.size.width/2,
                                                       y: self.view.frame.size.height/2,
                                                       width: self.view.frame.size.width/4,
                                                       height: self.view.frame.size.height/4))

        self.view.addSubview(capturePreview!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
