//
//  CollegeInfoViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/10/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class CollegeInfoViewController: UIViewController {
	
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var websiteButton: UIButton!
	@IBOutlet weak var emailButton: UIButton!
	@IBOutlet weak var phoneButton: UIButton!
	@IBOutlet weak var notesView: UITextView!
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var coverImage: UIImageView!

	var college: College!
	var student: Student!
	var askToShare = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.applyColors(text: college.textColor(), background: college.backgroundColor())
		refreshFields()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if askToShare {
			let alert = UIAlertController(title: "Share your information with \(college.name)?", message: "This will send them your name, email, and any other information you have provided", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Share", style: .default) {
				(_) in
				self.student.ref?.root.child("colleges/\(self.college.owner)/interested/\(self.student.owner)").setValue(self.student.toAnyObject())
			})
			alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func saveNotes(_ sender: AnyObject?) {
		student.ref?.child("colleges/\(college.owner)").child("notes").setValue(notesView.text)
		notesView.resignFirstResponder()
	}
	
	@IBAction func cancelNotes(_ sender: AnyObject?) {
		if let text = college.notes {
			notesView.text = text
		} else {
			notesView.text = ""
		}
		notesView.resignFirstResponder()
	}
	
	@IBAction func visitWebsite(_ sender: AnyObject?) {
		UIApplication.shared.open(URL(string: "https://\(college.website)")!, options: [:], completionHandler: nil)
	}
	
	@IBAction func callPhone(_ sender: AnyObject?) {
		UIApplication.shared.open(URL(string: "tel://\(college.phone)")!, options: [:], completionHandler: nil)
	}
	
	@IBAction func writeEmail(_ sender: AnyObject?) {
		
	}

	func refreshFields() {
		title = college.name
		detailsLabel.text = college.details
		websiteButton.setTitle(college.website, for: .normal)
		emailButton.setTitle(college.email, for: .normal)
		phoneButton.setTitle(college.phone, for: .normal)
		
		if let text = college.notes {
			notesView.text = text
		} else {
			notesView.text = ""
		}
		let layer = notesView.layer
		if let url = college.coverImage {
			var image: UIImage?
			var modified: Date?
			let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			let filePath = "\(documentsPath)/\(self.college.owner).jpg"
			do {
				let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
				modified = attributes[FileAttributeKey.modificationDate] as? Date
				image = UIImage(contentsOfFile: filePath)
			} catch {
				modified = nil
				image = nil
			}
			let httpsRef = Storage.storage().reference(forURL: url)
			httpsRef.getMetadata() {
				(metadata, error) in
				if let error = error {
					print("Error getting cover image metadata\n\(error)")
					self.coverImage.image = image
				} else if let metadata = metadata {
					let coverUpdated = metadata.updated!

					debugPrint("Created: \(modified?.description ?? "No modification date")")
					debugPrint("Updated: \(coverUpdated)")
					if let modified = modified, modified > coverUpdated {
						debugPrint("Using saved image")
						self.coverImage.image = image
					} else {
						debugPrint("Downloading cover image")
						httpsRef.getData(maxSize: 1024 * 1024) {
							(data, error) in
							if let error = error {
								print("Error fetching cover image\n\(error)")
							} else if let data = data {
								do {
									self.coverImage.image = UIImage(data: data)
									try data.write(to: URL(fileURLWithPath: filePath))
								} catch {
									print("Error saving cover imgage\n\(error)")
								}
							} else {
								print("No data")
							}
						}
					}
				} else {
					print("Could not convert metadata")
				}
			}

		} else {
			debugPrint("No Image URL")
			// TODO: Collapse UIImageView
		}
		layer.backgroundColor = UIColor.white.cgColor
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 2.0
		layer.cornerRadius = 10
	}
	
}

extension CollegeInfoViewController: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		cancelButton.isHidden = false
		saveButton.isHidden = false
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		cancelButton.isHidden = true
		saveButton.isHidden = true
	}
}

