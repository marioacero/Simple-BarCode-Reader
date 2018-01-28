//
//  BarCodeReader.swift
//  Simple Barcode Reader
//
//  Created by Mario Acero on 1/27/18.
//  Copyright © 2018 Mario Acero. All rights reserved.
//
import UIKit
import Foundation
import AVFoundation

protocol BarCodeReaderDelegate: class {
    func barCodeReader(_ reader: BarCodeReader, didReadCode code: String)
}

class BarCodeReader: NSObject {
    
    weak var delegate: BarCodeReaderDelegate?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var session: AVCaptureSession?
    private let outputQueue = DispatchQueue(label: "AvMetadataOutPut",
                                         qos: .userInteractive,
                                         attributes: [])
    private var outLineLayer: CAShapeLayer?
    
    func start() -> Bool {
        guard let newSession = setCaptureSession() else {
            return false
        }
        
        session = newSession
        let newPreview = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer = newPreview
        
        let newOutLine = setOutLineLayer()
        outLineLayer = newOutLine
        newOutLine.frame = newPreview.bounds
        newPreview.addSublayer(newOutLine)
        addMetadataOutput(toSession: newSession)
        session?.startRunning()
        return true
    }
    
    func stop() {
        session?.startRunning()
        session = nil
        previewLayer = nil
        outLineLayer = nil
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
    
    private func setOutLineLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.lineDashPattern = [5,3]
        shapeLayer.fillColor = nil
        return shapeLayer
    }
    
}

extension BarCodeReader: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let session = session, session.isRunning else { return }
        guard let qrCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        
        DispatchQueue.main.sync {
            let layer = self.previewLayer!
            var rect = layer.layerRectConverted(fromMetadataOutputRect: qrCode.bounds)
            rect = rect.insetBy(dx: -10, dy: 10)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
            self.outLineLayer!.path = path.cgPath
        }
        
        DispatchQueue.main.sync {
            if let string = qrCode.stringValue {
                self.delegate?.barCodeReader(self, didReadCode: string)
            }
        }
    }
}






