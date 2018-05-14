//
//  QRScanViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/9/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class QRScanViewController: UIViewController {

	@IBOutlet weak var captureView: UIView!
	@IBOutlet weak var cancelButton: UIButton!

	var captureSession: AVCaptureSession?
	var previewLayer: AVCaptureVideoPreviewLayer?
	var dataCaptureFunction: ((String, @escaping (Bool) -> Void) -> ())!
	
	override func viewDidLoad() {
		let layer = cancelButton.layer
		
		layer.backgroundColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25).cgColor
		layer.borderColor = UIColor.red.cgColor
		layer.borderWidth = 2.0
		layer.cornerRadius = 10
		
		guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }

		do {
			let input = try AVCaptureDeviceInput(device: captureDevice)
			captureSession = AVCaptureSession()
			captureSession?.addInput(input)
			
			let output = AVCaptureMetadataOutput()
			captureSession?.addOutput(output)
			
			output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			output.metadataObjectTypes = [.qr]
			
			previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
			previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
			previewLayer?.frame = captureView.layer.bounds
			captureView.layer.addSublayer(previewLayer!)
			
			captureSession?.startRunning()
		} catch {
			print("Error creating capture session\n\(error)")
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewLayer?.frame = captureView.layer.bounds
	}
	
	@IBAction func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
	
	func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		if metadataObjects.count == 0 {
			print("No QR code detected")
			return
		} else {
			let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
			if metadata.type == AVMetadataObject.ObjectType.qr {
				if let contents = metadata.stringValue {
					print(contents)
					captureSession?.stopRunning()
					dataCaptureFunction(contents) {
						result in
						if result {
							self.dismiss(animated: true, completion: nil)
						} else {
							let alert = UIAlertController(title: "Invalid QR Code", message: "The QR code does not belong to an active college in the College Fair system", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
							self.present(alert, animated: true, completion: nil)
						}
					}
				}
			}
		}
	}
}
