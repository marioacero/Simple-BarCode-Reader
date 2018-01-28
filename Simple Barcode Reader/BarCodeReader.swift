//
//  BarCodeReader.swift
//  Simple Barcode Reader
//
//  Created by Mario Acero on 1/27/18.
//  Copyright © 2018 Mario Acero. All rights reserved.
//

import Foundation
import AVFoundation

protocol BarCodeReaderDelegate: class {
    func barCodeReader(_ reader: BarCodeReader, didReadCode code: String)
}

class BarCodeReader: NSObject {
    
    weak var delegate: BarCodeReaderDelegate?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var session: AVCaptureSession?
    
    func start() -> Bool {
        guard let newSession = setCaptureSession() else {
            return false
        }
        
        session = newSession
        let newPreview = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer = newPreview
        
        addMetadataOutput(toSession: newSession)
        session?.startRunning()
        return true
    }
    
    func stop() {
        session?.startRunning()
        session = nil
        previewLayer = nil
    }
    
    private func setCaptureSession() -> AVCaptureSession? {
        let videoDevice = AVCaptureDevice.default(for: .video)
        let videoDeviceInput: AVCaptureDeviceInput?
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        }catch {
            print("failed")
            return nil
        }
        
        // Create Capture session
        let session = AVCaptureSession()
        if !session.canAddInput(videoDeviceInput!) {
            return nil
        }
        session.addInput(videoDeviceInput!)
        return session
    }
    
    private func addMetadataOutput(toSession: AVCaptureSession) {
        let metadataOutput = AVCaptureMetadataOutput()
        assert((session?.canAddOutput(metadataOutput))!)
        
        session?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: outputQueue)
        metadataOutput.metadataObjectTypes = [.qr]
    }
}
