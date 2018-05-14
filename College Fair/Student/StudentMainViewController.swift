//
//  StudentMainViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/9/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

private struct Sections {
	static let User = 0
	static let Colleges = 1
	static let Fairs = 2
	static let count = 3
}

class StudentMainViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var student: Student!
	var studentRef: DatabaseReference!
	var profileHandle: UInt!
	var colleges = [College]()
	var fairs = [Fair]()
	var collegeJustAdded: College?
	var loadingView: UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		debugPrint(view.frame)
		navigationItem.rightBarButtonItem = editButtonItem
		loadingView = UpdatingView(frame: view.frame)
		view.addSubview(loadingView!)
		studentRef.child("colleges").observeSingleEvent(of: .value) {
			snapshot in
			self.colleges = [College]()
			if snapshot.exists(), let collegeDict = snapshot.value as? [String: [String: AnyObject]] {
				for (owner, dict) in collegeDict {
					let college = College(owner: owner, dictionary: dict)
					self.colleges.append(college)
				}
				self.colleges.sort() {
					$0.name < $1.name
				}
				self.tableView.reloadSections(IndexSet(integer: Sections.Colleges), with: .automatic)
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setObservers()
	}

	override func viewDidAppear(_ animated: Bool) {
		if let college = collegeJustAdded {
			performSegue(withIdentifier: "showCollegeInfo", sender: college)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		studentRef.child("colleges").removeAllObservers()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		tableView.setEditing(editing, animated: animated)
	}
	
	func setObservers() {
		profileHandle = studentRef.observe(.value) {
			snapshot in
			if snapshot.exists() {
				self.loadingView?.removeFromSuperview()
				self.loadingView = nil
				self.student = Student(snapshot: snapshot)
				self.studentRef.removeObserver(withHandle: self.profileHandle)
				DispatchQueue.main.async {
					self.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.User)], with: .automatic)
				}
			} else {
				// No value in database, so add it, and keep observing
				self.student = Student(owner: self.studentRef.key)
				self.studentRef.setValue(self.student.toAnyObject())
			}
		}
		studentRef.child("colleges").observe(.childRemoved) {
			snapshot in
			let key = snapshot.key
			let index = self.colleges.index() {
				$0.owner == key
			}!
			self.colleges.remove(at: index)
			self.tableView.deleteRows(at: [IndexPath(row: index, section: Sections.Colleges)], with: .automatic)
		}
	}
	
	@IBAction func scanSchool() {
		performSegue(withIdentifier: "scanQRCode", sender: nil)
	}
	
	func addCollege(collegeID: String, completion: @escaping (Bool) -> Void) {
		let collegeRef = studentRef.root.child("colleges/\(collegeID)/profile")
		collegeRef.observeSingleEvent(of: .value) {
			snapshot in
			if snapshot.exists() {
				let college = College(owner: collegeID, dictionary: snapshot.value as! [String: AnyObject])
				self.collegeJustAdded = college
				self.studentRef.child("colleges/\(collegeID)").setValue(college.toAnyObject())
				self.colleges.append(college)
				self.colleges.sort() {
					$0.name < $1.name
				}
				self.tableView.reloadData()
				completion(true)
			} else {
				completion(false)
			}
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		navigationItem.title = "Main"
		if let destination = segue.destination as? StudentInfoViewController {
			destination.student = student
		} else if let destination = segue.destination as? CollegeInfoViewController {
			destination.college = sender as! College
			destination.student = student
			if collegeJustAdded != nil {
				collegeJustAdded = nil
				destination.askToShare = true
			}
		} else if let destination = segue.destination as? QRScanViewController {
			destination.dataCaptureFunction = addCollege
		}
	}
	
}

extension StudentMainViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 {
			return student.ref != nil
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let section = indexPath.section
		if section == Sections.User {
			performSegue(withIdentifier: "showStudentInfo", sender: student)
		} else if section == Sections.Colleges {
			performSegue(withIdentifier: "showCollegeInfo", sender: colleges[indexPath.row])
		}
	}

}

extension StudentMainViewController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Sections.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == Sections.Colleges {
			return colleges.count > 0 ? "Colleges" : nil
		} else if section == Sections.Fairs {
			return fairs.count > 0 ? "Fairs" : nil
		} else {
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == Sections.User {
			return 1
		} else if section == Sections.Colleges {
			return colleges.count
		} else if section == Sections.Fairs {
			return fairs.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		let section = indexPath.section
		if section == Sections.User {
			cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
			if let realStudent = student {
				if realStudent.isComplete() {
					cell.textLabel?.text = "\(realStudent.firstName) \(realStudent.lastName)"
					cell.accessoryType = .detailButton
				} else {
					cell.textLabel?.text = "Finish Your Profile"
					cell.accessoryType = .disclosureIndicator
				}
			} else {
				cell.textLabel?.text = "Create Your Profile"
				cell.accessoryType = .disclosureIndicator
			}
		} else if section == Sections.Colleges {
			cell = tableView.dequeueReusableCell(withIdentifier: "collegeCell", for: indexPath)
			cell.textLabel?.text = colleges[indexPath.row].name
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "fairCell", for: indexPath)
			cell.textLabel?.text = fairs[indexPath.row].name
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == Sections.Colleges
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let college = colleges[indexPath.row]
		studentRef.child("colleges/\(college.owner)").removeValue()
	}
	
}
