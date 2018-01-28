//
//  ViewController.swift
//  Simple Barcode Reader
//
//  Created by Mario Acero on 1/27/18.
//  Copyright © 2018 Mario Acero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let reader = BarCodeReader()
    var preview: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startScaning()
    }

    func startScaning() {
        preview?.removeFromSuperlayer()
        reader.stop()
        
        // Scaning Codes
        guard reader.start() else {
            print("Start Failed")
            return
        }
        
        preview = reader.previewLayer
        preview!.frame = view.layer.bounds
        view.layer.addSublayer(preview!)
    }


}

