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
    var recordButton: RecordButton?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        capturePreview = FrontCameraView(frame: CGRect(x: self.view.frame.size.width/2,
                                                       y: self.view.frame.size.height/2,
                                                       width: self.view.frame.size.width/4,
                                                       height: self.view.frame.size.height/4))

        capturePreview?.delegate = self

        self.view.addSubview(capturePreview!)

        let recordButtonSide = self.view.bounds.size.height/10
        recordButton = RecordButton(frame: CGRect(x: self.view.bounds.width/2-recordButtonSide/2,
                                                  y: self.view.bounds.height/2-recordButtonSide/2,
                                                  width: recordButtonSide,
                                                  height: recordButtonSide))
        recordButton?.delegate = self

        self.view.addSubview(recordButton!)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ViewController: FrontCameraDelegate {

    func videoRecorded(atURL: URL?) {
        guard let url = atURL else { return }
        print("Video has been recorded at: \(url)")
    }

}

extension ViewController: RecordButtonDelegate {

    func tapButton(isRecording: Bool) {

        if isRecording {
            capturePreview?.startRecording()
        } else {
            capturePreview?.stopRecording()
        }
    }
}
