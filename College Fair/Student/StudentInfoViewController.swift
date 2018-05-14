//
//  StudentInfoViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/9/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StudentInfoViewController: UITableViewController {
	
	enum Sections: Int {
		case name = 0
		case email
		case grad
		case majors
		case sports
		case activities
		static func count() -> Int {
			return 6
		}
	}
	
	struct FieldIndex {
		private static let multiplier = 3
		static let FirstName = Sections.name.rawValue * multiplier
		static let LastName = Sections.name.rawValue * multiplier + 1
		static let Email = Sections.email.rawValue * multiplier
		static let Grad = Sections.grad.rawValue * multiplier
	}
	
	var student: Student!
	var majors = [String]()
	var sports = [String]()
	var activities = [String]()
	var cancelling = false
	var allEditableCells = [Int: EditableTableCell]()
	
	enum Test: Int {
		case test1 = 0
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.rightBarButtonItem = editButtonItem
		tableView.sectionHeaderHeight += 5
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		addObservers()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if !student.isComplete() {
			setEditing(true, animated: false)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		student.ref?.child("profile/majors").removeAllObservers()
		student.ref?.child("profile/sports").removeAllObservers()
		student.ref?.child("profile/activities").removeAllObservers()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		if editing {
			let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
			cancelButton.tintColor = UIColor.red
			navigationItem.leftBarButtonItem = cancelButton
		} else {
			navigationItem.leftBarButtonItem = nil
			view.endEditing(true)
			if !cancelling {
				saveChanges()
			}
		}

		let animations: () -> Void = {
			for cell in self.allEditableCells.values {
				cell.setEditInterface(editing, animated: animated)
			}
		}
		animations()
//		UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: animations, completion: nil)
		cancelling = false
	}
	
	func addObservers() {
		student.ref?.child("profile/majors").observe(.childAdded) {
			snapshot in
			self.majors.append(snapshot.key)
			self.majors.sort()
			let index = self.majors.index(of: snapshot.key)!
			self.tableView.insertRows(at: [IndexPath(row: index, section: Sections.majors.rawValue)], with: .automatic)
		}
		student.ref?.child("profile/majors").observe(.childRemoved) {
			snapshot in
			let index = self.majors.index(of: snapshot.key)!
			self.majors.remove(at: index)
			self.tableView.deleteRows(at: [IndexPath(row: index, section: Sections.majors.rawValue)], with: .automatic)
		}
		student.ref?.child("profile/sports").observe(.childAdded) {
			snapshot in
			self.sports.append(snapshot.key)
			self.sports.sort()
			let index = self.sports.index(of: snapshot.key)!
			self.tableView.insertRows(at: [IndexPath(row: index, section: Sections.sports.rawValue)], with: .automatic)
		}
		student.ref?.child("profile/sports").observe(.childRemoved) {
			snapshot in
			let index = self.sports.index(of: snapshot.key)!
			self.sports.remove(at: index)
			self.tableView.deleteRows(at: [IndexPath(row: index, section: Sections.sports.rawValue)], with: .automatic)
		}
		student.ref?.child("profile/activities").observe(.childAdded) {
			snapshot in
			self.activities.append(snapshot.key)
			self.activities.sort()
			let index = self.activities.index(of: snapshot.key)!
			self.tableView.insertRows(at: [IndexPath(row: index, section: Sections.activities.rawValue)], with: .automatic)
		}
		student.ref?.child("profile/activities").observe(.childRemoved) {
			snapshot in
			let index = self.activities.index(of: snapshot.key)!
			self.activities.remove(at: index)
			self.tableView.deleteRows(at: [IndexPath(row: index, section: Sections.activities.rawValue)], with: .automatic)
		}
	}
	
	@objc func saveChanges() {
		if let grad = Int((allEditableCells[FieldIndex.Grad]?.cellField.text)!), let last = allEditableCells[FieldIndex.LastName]?.cellField.text, let first = allEditableCells[FieldIndex.FirstName]?.cellField.text, let email = allEditableCells[FieldIndex.Email]?.cellField.text, last != "", first != "", email != ""  {
			student.ref?.child("profile").updateChildValues(["firstName": first, "lastName": last, "email": email, "gradYear": grad])
			for cell in allEditableCells.values {
				cell.saveChanges()
			}
			tableView.layoutSubviews()
		} else {
			let alert = UIAlertController(title: "Required Fields Not Filled", message: "The 'First Name', 'Last Name', and 'Email' fields are required", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Okay", style: .default) {
				(_) in
				self.setEditing(true, animated: true)
			})
			present(alert, animated: true, completion: nil)
		}
	}
	
	@objc func cancel() {
		cancelling = true
		setEditing(false, animated: true)
	}
	
	func updateStudent(to newStudent: Student?) {
		student = newStudent
		tableView.reloadData()
	}
	
	@objc func enterNewMajor() {
		enterNewOther(to: "majors", titled: "Major")
	}
	
	@objc func enterNewSport() {
		enterNewOther(to: "sports", titled: "Sport")
	}
	@objc func enterNewActivity() {
		enterNewOther(to: "activities", titled: "Activity")
	}
	
	func enterNewOther(to section: String, titled: String) {
		var otherTextField: UITextField!
		let alert = UIAlertController(title: "New \(titled)", message: nil, preferredStyle: .alert)
		alert.addTextField() {
			(field) in
			field.placeholder = "Name"
			field.autocapitalizationType = .words
			otherTextField = field
		}
		alert.addAction(UIAlertAction(title: "Add", style: .default) {
			(_) in
			if let other = otherTextField.text, other != "" {
				let otherRef = self.student.ref?.child("profile/\(section)")
				otherRef?.updateChildValues([other: true])
			}
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Sections.count()
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		var selector: Selector?
		let titleText: String
		switch Sections(rawValue: section)! {
		case .name: return nil
		case .email: titleText = "Email"
		case .grad: titleText = "Graduation Year"
		case .majors:
			titleText = "Majors"
			selector = #selector(enterNewMajor)
		case .sports:
			titleText = "Sports"
			selector = #selector(enterNewSport)
		case .activities:
			titleText = "Activities"
			selector = #selector(enterNewActivity)
		}
		debugPrint(titleText)
		let frame = tableView.frame
		let height = tableView.sectionHeaderHeight
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: height))
		if let selector = selector {
			let button = UIButton(type: .contactAdd)
			button.frame = CGRect(x: frame.width - (height), y: 0, width: height - 5, height: height - 5)
			headerView.addSubview(button)
			button.addTarget(self, action: selector, for: UIControlEvents.touchUpInside)
		}
		let title = UILabel(frame: CGRect(x: 5, y: 0, width: frame.width - 10, height: height))
		title.text = titleText
		headerView.addSubview(title)
		return headerView
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Sections(rawValue: section)! {
		case .name:
			return 2
		case .majors:
			return majors.count
		case .sports:
			return sports.count
		case .activities:
			return activities.count
		default:
			return 1
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section >= Sections.majors.rawValue
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Sections(rawValue: indexPath.section)! {
		case .name:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editableCell", for: indexPath) as! EditableTableCell
			let index: Int
			if indexPath.row == 0 {
				cell.cellField.placeholder = "First Name"
				cell.textValue = student.firstName
				index = FieldIndex.FirstName
			} else {
				cell.cellField.placeholder = "Last Name"
				cell.textValue = student.lastName
				index = FieldIndex.LastName
			}
			cell.cellField.text = cell.textValue
			allEditableCells[index] = cell
			return cell
		case .email:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editableCell", for: indexPath) as! EditableTableCell
			cell.cellField.placeholder = "Email"
			cell.cellField.keyboardType = .emailAddress
			cell.cellField.autocapitalizationType = .none
			cell.cellField.text = student.email
			allEditableCells[FieldIndex.Email] = cell
			return cell
		case .grad:
			let cell = tableView.dequeueReusableCell(withIdentifier: "editableCell", for: indexPath) as! EditableTableCell
			cell.cellField.placeholder = "Graduation Year"
			cell.cellField.keyboardType = .numberPad
			cell.cellField.text = student.gradYear.description
			allEditableCells[FieldIndex.Grad] = cell
			return cell
		case .majors:
			let cell = tableView.dequeueReusableCell(withIdentifier: "adjunctCell", for: indexPath)
			cell.textLabel?.text = majors[indexPath.row]
			return cell
		case .sports:
			let cell = tableView.dequeueReusableCell(withIdentifier: "adjunctCell", for: indexPath)
			cell.textLabel?.text = sports[indexPath.row]
			return cell
		case .activities:
			let cell = tableView.dequeueReusableCell(withIdentifier: "adjunctCell", for: indexPath)
			cell.textLabel?.text = activities[indexPath.row]
			return cell
		}
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if indexPath.section >= Sections.majors.rawValue {
			return .delete
		} else {
			return .none
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		//TODO: Add/delete sports and activities, not just majors
		let section = Sections(rawValue: indexPath.section)!
		if editingStyle == .delete {
			let name = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
			switch section {
			case .majors:
				student.ref?.child("profile/majors/\(name)").removeValue()
			case .sports:
				student.ref?.child("profile/sports/\(name)").removeValue()
			case .activities:
				student.ref?.child("profile/activities/\(name)").removeValue()
			default: return
			}
		}
	}
	
}
