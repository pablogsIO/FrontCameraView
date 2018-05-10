//
//  CameraManager.swift
//  FrontCameraExample
//
//  Created by Pablo on 10/05/2018.
//  Copyright © 2018 Pablo Garcia. All rights reserved.
//

import AVFoundation

protocol CameraManagerProtocol {

    func previewFrontCamera(onSuccess: @escaping (AVCaptureVideoPreviewLayer) -> Void, onError: ((Error) -> Void)?)
}

class CameraManager: CameraManagerProtocol {

    enum CameraPreviewError: Swift.Error {
        case videoInputNotValid
        case audioInputNotValid
        case cameraNotFound
        case microphoneNotFound
        case noVideoInputAvailable
        case noAudioInputAvalilable
    }

    private lazy var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var inputVideo: AVCaptureInput?
    private var inputAudio: AVCaptureInput?
    private var outputMovieFile: AVCaptureMovieFileOutput?

    func previewFrontCamera(onSuccess: @escaping (AVCaptureVideoPreviewLayer) -> Void, onError: ((Error) -> Void)?) {

        DispatchQueue(label: "configuration").async {
            do {
                try self.configureDeviceInputs()
                try self.configureSessionInputs()
                try self.configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    onError!(error)
                }
                return
            }
            DispatchQueue.main.async {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.captureSession.startRunning()
                onSuccess(self.videoPreviewLayer!)
            }
        }
    }

    private func configureDeviceInputs() throws {

        let videoDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.front)

        guard let cameraDevice = videoDevice.devices.first else { throw CameraPreviewError.cameraNotFound }

        if cameraDevice.isFocusModeSupported(.autoFocus) {
            cameraDevice.focusMode = .autoFocus
        }

        do {
            inputVideo = try AVCaptureDeviceInput(device: cameraDevice)
        } catch {
            throw CameraPreviewError.videoInputNotValid
        }

        let audioDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone],
            mediaType: AVMediaType.audio,
            position: AVCaptureDevice.Position.unspecified)

        guard let audioDevice = audioDevices.devices.first else { throw CameraPreviewError.microphoneNotFound }

        do {
            inputAudio = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            throw CameraPreviewError.audioInputNotValid
        }
    }
   private func configureSessionInputs() throws {

        if self.captureSession.canAddInput(inputVideo!) {
            self.captureSession.addInput(self.inputVideo!)
        } else {
            throw CameraPreviewError.noVideoInputAvailable
        }
        if self.captureSession.canAddInput(self.inputAudio!) {
            self.captureSession.addInput(self.inputAudio!)
        } else {
            throw CameraPreviewError.noAudioInputAvalilable
        }
    }
    private func configurePhotoOutput() throws {

        self.outputMovieFile = AVCaptureMovieFileOutput()

        if captureSession.canAddOutput(self.outputMovieFile!) {
            captureSession.addOutput(self.outputMovieFile!)
        }
    }
}
