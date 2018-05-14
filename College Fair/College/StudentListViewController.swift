//
//  StudentListViewController.swift
//  College Fair
//
//  Created by Chase Smith on 2/18/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StudentListViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var college: College!
	var allStudents = [Student]()
	var filteredStudents = [Student]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.applyColors(text: college.textColor(), background: college.backgroundColor())
		college.ref?.parent?.child("interested").observeSingleEvent(of: .value) {
			snapshot in
			self.allStudents = [Student]()
			if snapshot.exists(), let studentDict = snapshot.value as? [String: [String: AnyObject]] {
				for (owner, dict) in studentDict {
					let student = Student(owner: owner, dictionary: dict)
					self.allStudents.append(student)
				}
				self.allStudents.sort() {
					if $0.lastName != $1.lastName {
						return $0.lastName < $1.lastName
					} else {
						return $0.firstName < $1.firstName
					}
				}
				self.filteredStudents = self.allStudents
				self.tableView.reloadData()
			}
		}
	}
	
	@IBAction func done(_ sender: AnyObject?) {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func filter(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "None", style: .default) {
			(_) in
			self.filteredStudents = self.allStudents
			self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
		})
		alert.addAction(UIAlertAction(title: "No Students", style: .default) {
			(_) in
			self.filteredStudents = [Student]()
			self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
		})
		alert.popoverPresentationController?.barButtonItem = sender
		present(alert, animated: true, completion: nil)
	}
}

extension StudentListViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredStudents.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
		let student = filteredStudents[indexPath.row]
		cell.textLabel?.text = "\(student.lastName), \(student.firstName)"
//		cell.backgroundColor = college.backgroundColor()
		cell.textLabel?.textColor = college.textColor()
		return cell
	}

}

extension StudentListViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return false
	}
}
