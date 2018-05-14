//
//  NotesTableCell.swift
//  College Fair
//
//  Created by Chase Smith on 5/14/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class NotesView: UIView {
	
	@IBOutlet weak var notesView: UITextView!
	@IBOutlet weak var saveButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	var saveFunction: ((String) -> Void)!
	var notes: String! {
		didSet {
			notesView.text = notes
		}
	}
	
	@IBAction func saveChanges() {
		notesView.resignFirstResponder()
		notes = notesView.text
		saveFunction(notes)
	}
	
	@IBAction func cancel() {
		notesView.resignFirstResponder()
		notesView.text = notes
	}
	
}


