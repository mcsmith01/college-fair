//
//  CollegeInfoViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/10/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase
import FirebaseStorage

class CollegeEditInfoViewController: UIViewController {
	
	enum Fields: Int {
		case name = 0
		case website = 1
		case email = 2
		case phone = 3
		case details = 4
		case textColor = 5
		case backgroundColor = 6
	}
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var websiteField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var phoneField: UITextField!
	@IBOutlet weak var descriptionField: UITextView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var college: College!
	var longGestureRecognizer: UILongPressGestureRecognizer!
	var images = [(image: UIImage, url: String)]()
	let storage = Storage.storage()

	override func viewDidLoad() {
		super.viewDidLoad()
		let layer = descriptionField.layer
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 2.0
		layer.cornerRadius = 10.0
		collectionView.dragDelegate = self
//		collectionView.dropDelegate = self
		longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
		collectionView.addGestureRecognizer(longGestureRecognizer)
		title = "Edit School Information"
		nameField.text = college.name
		nameField.tag = Fields.name.rawValue
		websiteField.text = college.website != "" ? college.website : nil
		websiteField.tag = Fields.website.rawValue
		emailField.text = college.email != "" ? college.email : nil
		emailField.tag = Fields.email.rawValue
		phoneField.text = college.phone != "" ? college.phone : nil
		phoneField.tag = Fields.phone.rawValue
		descriptionField.text = college.details
		descriptionField.tag = Fields.details.rawValue
		loadImages()
		refreshView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		college.ref?.observe(.value) {
			snapshot in
			self.college = College(snapshot: snapshot)
			self.refreshView()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		college.ref?.removeAllObservers()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? ColorSelectionViewController, let id = segue.identifier {
			if id == "textColor" {
				destination.hex = college.tColor
				destination.applyColor = updateTextColor
			} else if id == "backgroundColor" {
				destination.hex = college.bColor
				destination.applyColor = updateBackgroundColor
			}
		} else if let destination = segue.destination as? CollegePresentationViewController {
			destination.college = college
			destination.images = images.map() {
				(image, _) in return image
			}
			destination.isPreview = true
		}
	}
	
	func refreshView() {
		DispatchQueue.main.async {
			self.nameLabel.text = self.college.name
			self.view.applyColors(text: self.college.textColor(), background: self.college.backgroundColor())
		}
	}
	
	func loadImages() {
		let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		if let urls = UserDefaults.standard.stringArray(forKey: Keys.imageURLs.rawValue) {
			for imageName in urls {
				do {
					let url = URL(fileURLWithPath: "\(documentsPath)/\(imageName)")
					let data = try Data(contentsOf: url)
					let image = UIImage(data: data)
					images.append((image!, imageName))
				} catch {
					print("Unable to load image\n\(error)")
				}
			}
		}
	}
	
	func saveImages() {
		let urls = images.map() {
			(_, url) in return url
		}
		UserDefaults.standard.set(urls, forKey: Keys.imageURLs.rawValue)
	}
	
	func updateTextColor(_ hex: Int) {
		updateInformation(info: hex as AnyObject, field: .textColor)
	}
	
	func updateBackgroundColor(_ hex: Int) {
		updateInformation(info: hex as AnyObject, field: .backgroundColor)
	}
	
	func updateInformation(info: AnyObject, field: Fields) {
		let key: String
		switch(field) {
		case .name:
			key = "name"
		case .website:
			key = "website"
		case .email:
			key = "email"
		case .phone:
			key = "phone"
		case .details:
			key = "details"
		case .textColor:
			key = "textColor"
		case .backgroundColor:
			key = "backgroundColor"
		}
		college.ref?.updateChildValues([key: info])
	}
	
	func setCoverImage(_ image: UIImage) {
		var data = UIImageJPEGRepresentation(image, 1.0)!
		let size = CGFloat(data.count)
		let max: CGFloat = pow(512, 2)
		if size > max {
			let percentage = max / size
			data = UIImageJPEGRepresentation(image, percentage)!
		}

		let coverRef = storage.reference().child("images/\(college.owner)/cover.jpg")
		coverRef.putData(data, metadata: nil) {
			(metadata, error) in
			if let error = error {
				print("Error uploading file\n\(error)")
			} else {
				coverRef.downloadURL() {
					(url, error) in
					guard let downloadURL = url else {
						print("No download url")
						return
					}
					print(downloadURL.relativeString)
					self.college.ref?.updateChildValues(["cover": downloadURL.absoluteString])
				}

			}
		}
	}
	
	@IBAction func preview(_ sender: AnyObject?) {
		nameField.becomeFirstResponder()
		nameField.resignFirstResponder()
		college.ref?.observeSingleEvent(of: .value) {
			snapshot in
			self.college = College(snapshot: snapshot)
			self.performSegue(withIdentifier: "preview", sender: sender)
		}
	}
	
	@IBAction func doneEditing(_ sender: AnyObject?) {
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
		switch(gesture.state) {
		case .began:
			guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
			collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
		case .changed:
			collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
		case .ended:
			collectionView.endInteractiveMovement()
		default:
			collectionView.cancelInteractiveMovement()
		}
	}
	
}

extension CollegeEditInfoViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.modalPresentationStyle = .popover
			imagePicker.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)?.contentView
			present(imagePicker, animated: true, completion: nil)
		}
	}
	
}

extension CollegeEditInfoViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count + 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let identifier = indexPath.row == 1 ? "coverImageCell" : "imageCell"
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ImageCollectionViewCell
		if indexPath.row == 0 {
			cell.imageView.image = UIImage(named: "plus")
			cell.backgroundColor = UIColor.gray
		} else {
			cell.imageView.image = images[indexPath.row - 1].image
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let imagePair = images.remove(at: sourceIndexPath.row - 1)
		images.insert(imagePair, at: destinationIndexPath.row - 1)
		saveImages()
		if sourceIndexPath.row == 1 || destinationIndexPath.row == 1 {
			setCoverImage(images[0].image)
		}
		// TODO: Remove "Cover" from image at index 2 if destination is index 1
	}
	
	func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		if proposedIndexPath.row == 0 {
			return IndexPath(row: 1, section: 0)
		} else {
			return proposedIndexPath
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return indexPath.row != 0
	}
	
}

extension CollegeEditInfoViewController: UICollectionViewDragDelegate {

	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		// What to do here?
		debugPrint("Drag session: \(session)\n\(indexPath)")
//		let image = images[indexPath.row - 1].image
//		let itemProvider = NSItemProvider(object: image)
//		let dragItem = UIDragItem(itemProvider: itemProvider)
//		return [dragItem]
		return []
	}

	func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
		debugPrint("Drag beginning")
	}

	func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
		debugPrint("Dragging ended")
		debugPrint(session.items)
	}

	func collectionView(_ collectionView: UICollectionView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
		debugPrint("Allows Move")
		return true
	}

}

//extension CollegeEditInfoViewController: UICollectionViewDropDelegate {
//	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//		debugPrint(coordinator.destinationIndexPath)
//		collectionView.moveItem(at: <#T##IndexPath#>, to: <#T##IndexPath#>)
//	}
//}

extension CollegeEditInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let url = info[UIImagePickerControllerImageURL] as? URL, let data = UIImagePNGRepresentation(image) {
			do {
				let name = url.lastPathComponent
				let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
				let filePath = "\(documentsPath)/\(name)"
				try data.write(to: URL(fileURLWithPath: filePath))
				images.append((image, name))
				saveImages()
				if images.count == 1 {
					setCoverImage(image)
				}
				collectionView.reloadData()
			} catch {
				print("Could not save image\n\(error)")
			}
		} else {
			debugPrint("Could not save image")
		}
		dismiss(animated: true, completion: nil)
	}
	
}

extension CollegeEditInfoViewController: UITextViewDelegate {
	
	func textViewDidEndEditing(_ textView: UITextView) {
		updateInformation(info: textView.text as AnyObject, field: Fields(rawValue: textView.tag)!)
	}

}

extension CollegeEditInfoViewController: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		updateInformation(info: textField.text! as AnyObject, field: Fields(rawValue: textField.tag)!)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
}
