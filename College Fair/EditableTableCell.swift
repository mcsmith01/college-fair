//
//  EditableTableCell.swift
//  College Fair
//
//  Created by Chase Smith on 5/14/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class EditableTableCell: UITableViewCell {
	
	@IBOutlet weak var cellField: UITextField!
	var textValue: String? {
		didSet {
			if let nv = textValue, nv == "" {
				textValue = nil
			}
		}
	}
	
	func saveChanges() {
		textValue = cellField.text
	}
	
	func cancelChanges() {
		cellField.text = textValue
	}
	
	func setEditInterface(_ editing: Bool, animated: Bool) {
		cellField.borderStyle = editing ? .roundedRect : .none
		cellField.isEnabled = editing
	}
}
