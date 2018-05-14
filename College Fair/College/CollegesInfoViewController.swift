//
//  CollegesInfoViewController.swift
//  College Fair
//
//  Created by Chase Smith on 1/29/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class CollegesInfoViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var websiteLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var phoneLabel: UILabel!
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var slideShow: UIImageView!
	
	var college: College!
	var images: [UIImage]!
	var photoIndex = 0
	var timer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateCollege(college)
		if images.count > 0 {
			slideShow.image = images[photoIndex]
			timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {
				(_) in
				self.changeImages()
			}
		}
	}
	
	func updateCollege(_ newCollege: College) {
		DispatchQueue.main.async {
			self.college = newCollege
			self.title = "\(self.college.name)"
			self.nameLabel.text = self.college.name
			self.websiteLabel.text = self.college.website
			self.emailLabel.text = self.college.email
			self.phoneLabel.text = self.college.phone
			self.detailsLabel.text = self.college.details
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer?.invalidate()
	}

	func changeImages() {
		photoIndex = (photoIndex + 1) % images.count
		UIView.transition(with: slideShow, duration: 1.0, options: .transitionCrossDissolve, animations: {
			self.slideShow.image = self.images[self.photoIndex]
		}, completion: nil)
	}
	
}
