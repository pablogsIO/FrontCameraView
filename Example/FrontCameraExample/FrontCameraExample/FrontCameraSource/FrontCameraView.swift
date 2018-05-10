//
//  FrontCameraView.swift
//  FrontCameraExample
//
//  Created by Pablo on 08/05/2018.
//  Copyright © 2018 Pablo Garcia. All rights reserved.
//

import UIKit
import AVFoundation

protocol FrontCameraDelegate: class {
    func videoRecorded(atURL: URL?)
}

class FrontCameraView: UIView {

    enum Position {
        case upleft
        case upright
        case downleft
        case downright
    }

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var cameraManager = CameraManager()
    private var draggGesture: UIPanGestureRecognizer?
    var delegate: FrontCameraDelegate?
    private var finalPosition = Position.upright

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.draggGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))

        self.addGestureRecognizer(draggGesture!)

        cameraManager.previewFrontCamera(onSuccess: { (previewView) in
            self.videoPreviewLayer = previewView
            self.videoPreviewLayer?.frame = (self.layer.bounds)
            self.layer.addSublayer(self.videoPreviewLayer!)
        }) { (_) in
            //Do something with the error
            self.backgroundColor = UIColor.black
        }
        translateView(to: .upright)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func draggedView(_ sender: UIPanGestureRecognizer) {

        if !(sender.state == UIGestureRecognizerState.ended) {
            let translation = sender.translation(in: self.superview)
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.superview)
        } else {
            switch viewPosition() {
            case .upleft:
                translateView(to: .upleft)
            case .upright:
                translateView(to: .upright)
            case .downleft:
                translateView(to: .downleft)
            case .downright:
                translateView(to: .downright)
            }
        }
    }

    func startRecording() {

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let fileUrl = paths[0].appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: fileUrl)

        //outputMovieFile?.startRecording(to: fileUrl, recordingDelegate: self as! AVCaptureFileOutputRecordingDelegate)
        if let gesture = self.draggGesture {
            self.removeGestureRecognizer(gesture)
        }
        finalPosition = viewPosition()
    }

    func stopRecording() {

        //outputMovieFile?.stopRecording()
    }

    private func viewPosition() -> Position {

        guard let superView = self.superview else { return Position.upleft}

        let xView = self.center.x
        let yView = self.center.y
        let width = superView.frame.size.width/2
        let height = superView.frame.size.height/2

        if xView<width {
            if yView < height {
                return Position.upleft
            } else {
                return Position.downleft
            }
        } else {
            if yView < height {
                return Position.upright
            } else {
                return Position.downright
            }
        }
    }

    private func translateView(to: Position) {

        guard let superView = self.superview else { return }

        var origin = CGPoint.zero
        var finalPlace = CGPoint.zero
        let offset: CGFloat = 5.0
        let duration: CFTimeInterval = 0.5
        switch to {
        case .upleft:
            origin = CGPoint(x: 0, y: superView.safeAreaInsets.top)
            finalPlace = CGPoint(x: offset, y: superView.safeAreaInsets.top+offset)
        case .upright:
            origin = CGPoint(x: superView.frame.size.width-self.frame.size.width, y: superView.safeAreaInsets.top)
            finalPlace = CGPoint(x: superView.frame.size.width-self.frame.size.width-offset,
                                 y: superView.safeAreaInsets.top+offset)
        case .downleft:
            origin = CGPoint(x: 0,
                             y: superView.frame.size.height-self.frame.size.height-superView.safeAreaInsets.bottom)
            finalPlace = CGPoint(x: offset,
                                 y: superView.frame.size.height-self.frame.size.height-offset-superView.safeAreaInsets.bottom)
        case .downright:
            origin = CGPoint(x: superView.frame.size.width-self.frame.size.width,
                             y: superView.frame.size.height-self.frame.size.height-superView.safeAreaInsets.bottom)
            finalPlace = CGPoint(x: superView.frame.size.width-self.frame.size.width-offset,
                                 y: superView.frame.size.height-self.frame.size.height-offset-superView.safeAreaInsets.bottom)
        }

        UIView.animate(withDuration: duration) {
            self.frame.origin = origin
        }
        UIView.animateKeyframes(withDuration: duration/2, delay: duration, options: [], animations: {

            self.frame.origin = CGPoint(x: finalPlace.x, y: finalPlace.y)
        })

    }
}

extension FrontCameraView: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {

        if error == nil {
            self.delegate?.videoRecorded(atURL: outputFileURL)
        } else {
            self.delegate?.videoRecorded(atURL: nil)
        }
    }
}
