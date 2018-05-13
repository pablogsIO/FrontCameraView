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
    private var finalPosition = Position.upright

    weak var delegate: FrontCameraDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.draggGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))

        self.addGestureRecognizer(draggGesture!)
        cameraManager.delegate = self

        cameraManager.previewFrontCamera(onSuccess: { (previewView) in
            self.videoPreviewLayer = previewView
            self.videoPreviewLayer?.frame = (self.layer.bounds)
            self.layer.addSublayer(self.videoPreviewLayer!)
        }, onError: { (_) in
            //Do something when there is an error
            self.backgroundColor = UIColor.black
        })

        translateView(toPosition: .upright)
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
                translateView(toPosition: .upleft)
            case .upright:
                translateView(toPosition: .upright)
            case .downleft:
                translateView(toPosition: .downleft)
            case .downright:
                translateView(toPosition: .downright)
            }
        }
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

    private func translateView(toPosition: Position) {

        guard let superView = self.superview else { return }

        var origin = CGPoint.zero
        var finalPlace = CGPoint.zero
        let offset: CGFloat = 5.0
        let duration: CFTimeInterval = 0.5
        let superviewWidth = superView.frame.size.width
        let superviewHeight = superView.frame.size.height

        switch toPosition {
        case .upleft:
            origin = CGPoint(x: 0, y: superView.safeAreaInsets.top)
            finalPlace = CGPoint(x: offset, y: superView.safeAreaInsets.top+offset)
        case .upright:
            origin = CGPoint(x: superviewWidth-self.frame.size.width, y: superView.safeAreaInsets.top)
            finalPlace = CGPoint(x: superviewWidth-self.frame.size.width-offset,
                                 y: superView.safeAreaInsets.top+offset)
        case .downleft:
            origin = CGPoint(x: 0,
                             y: superviewHeight-self.frame.size.height-superView.safeAreaInsets.bottom)
            finalPlace = CGPoint(x: offset,
                                 y: superviewHeight-self.frame.size.height-offset-superView.safeAreaInsets.bottom)
        case .downright:
            origin = CGPoint(x: superviewWidth-self.frame.size.width,
                             y: superviewHeight-self.frame.size.height-superView.safeAreaInsets.bottom)
            finalPlace = CGPoint(x: superviewWidth-self.frame.size.width-offset,
                                 y: superviewHeight-self.frame.size.height-offset-superView.safeAreaInsets.bottom)
        }

        UIView.animate(withDuration: duration) {
            self.frame.origin = origin
        }
        UIView.animateKeyframes(withDuration: duration/2, delay: duration, options: [], animations: {

            self.frame.origin = CGPoint(x: finalPlace.x, y: finalPlace.y)
        })

    }

    func startRecording() {
        self.cameraManager.startRecording()
    }

    func stopRecording() {
        self.cameraManager.stopRecording()
    }
}

extension FrontCameraView: CameraManagerDelegate {

    func videoHasBeenRecorded(atURL: URL?) {
        self.delegate?.videoRecorded(atURL: atURL)
    }

}
