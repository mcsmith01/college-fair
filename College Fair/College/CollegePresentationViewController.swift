//
//  CollegePresentationViewController.swift
//  College Fair
//
//  Created by Chase Smith on 1/29/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CollegePresentationViewController: UIViewController {
	
	@IBOutlet weak var qrImageView: UIImageView!
	@IBOutlet weak var qrLabel: UILabel!
	
	var college: College!
	var images: [UIImage]!
	var infoViewController: CollegesInfoViewController?
	var isPreview = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let data: Data?
		if isPreview {
			data = college.name.data(using: .utf8)
			qrImageView.alpha = 0.25
		} else {
			data = college.owner.data(using: .utf8)
			qrImageView.alpha = 1.0
		}
		let filter = CIFilter(name: "CIQRCodeGenerator")!
		filter.setValue(data, forKey: "inputMessage")
		filter.setValue("Q", forKey: "inputCorrectionLevel")
		
		var image = filter.outputImage!
		image = image.transformed(by: CGAffineTransform(scaleX: 5.0, y: 5.0))
		qrImageView.image = UIImage(ciImage: image)
		qrLabel.text = "Scan to connect with \(college.name)!"
		view.applyColors(text: college.textColor(), background: college.backgroundColor())
		college.ref?.observe(.value) {
			snapshot in
			self.college = College(snapshot: snapshot)
			self.infoViewController?.updateCollege(self.college)
			DispatchQueue.main.async {
				self.view.applyColors(text: self.college.textColor(), background: self.college.backgroundColor())
			}
		}
		
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CollegesInfoViewController {
			infoViewController = destination
			destination.college = college
			destination.images = images
		}
	}

	@IBAction func closeView(_ sender: AnyObject?) {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
}
