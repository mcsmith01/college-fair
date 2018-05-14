//
//  CollegeMainViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/9/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CollegeMainViewController: UIViewController {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var presentButton: UIButton!
	@IBOutlet weak var viewButton: UIButton!
	@IBOutlet weak var editButton: UIButton!

	var college: College!
	var collegeRef: DatabaseReference!
	var profileHandle: UInt!
	var loadingView: UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadingView = UpdatingView(frame: view.frame)
		view.addSubview(loadingView!)
		UserDefaults.standard.removeObject(forKey: Keys.imageURLs.rawValue)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setObservers()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CollegePresentationViewController {
			destination.images = getImages()
			destination.college = college
			destination.isPreview = false
		} else if let navigation = segue.destination as? UINavigationController {
			if let destination = navigation.topViewController as? CollegeEditInfoViewController {
				destination.college = college
			}
		} else if let destination = segue.destination as? StudentListViewController {
			destination.college = college
		}
	}
	
	func setObservers() {
		profileHandle = collegeRef.child("profile").observe(.value) {
			snapshot in
			debugPrint("Profile fetched")
			if snapshot.exists() {
				self.loadingView?.removeFromSuperview()
				self.loadingView = nil
				self.college = College(snapshot: snapshot)
				DispatchQueue.main.async {
					self.presentButton.isEnabled = true
					self.viewButton.isEnabled = true
					self.editButton.isEnabled = true
					self.view.applyColors(text: self.college.textColor(), background: self.college.backgroundColor())
					self.nameLabel.text = self.college.name
				}
			} else {
				self.college = College(owner: self.collegeRef.key)
				let ref = self.collegeRef.child("profile")
				ref.setValue(self.college.toAnyObject())
			}
		}
	}
	
	func getImages() -> [UIImage] {
		var images = [UIImage]()
		let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		if let urls = UserDefaults.standard.stringArray(forKey: Keys.imageURLs.rawValue) {
			for imageName in urls {
				let image = UIImage(contentsOfFile: "\(documentsPath)/\(imageName)")!
				images.append(image)
			}
		}
		return images
	}
	
	@IBAction func presentCollege() {
		performSegue(withIdentifier: "presentCollege", sender: nil)
	}
	
}
