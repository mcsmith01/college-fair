//
//  DataModel.swift
//  College Fair
//
//  Created by Chase Smith on 2/9/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct Student {
	
	let ref: DatabaseReference?
	var owner: String
	var lastName: String
	var firstName: String
	var email: String
	var gradYear = nextGradYear()
	var gender: String
	var majors: [String: Bool]?
	var sports: [String: Bool]?
	var activities: [String: Bool]?
	var added: Date?
	
	init(owner: String) {
		self.owner = owner
		lastName = ""
		firstName = ""
		email = ""
		gender = ""
		ref = nil
	}
	
	init(snapshot: DataSnapshot) {
		owner = snapshot.key
		let valueDict = snapshot.value as! [String: AnyObject]
		let profileDict = valueDict["profile"] as! [String: AnyObject]
		lastName = profileDict["lastName"] as! String
		firstName = profileDict["firstName"] as! String
		email = profileDict["email"] as! String
		gradYear = profileDict["gradYear"] as! Int
		gender = profileDict["gender"] as! String
		if let dict = profileDict["majors"] as? [String: Bool] {
			majors = dict
		}
		if let dict = profileDict["sports"] as? [String: Bool] {
			sports = dict
		}
		if let dict = profileDict["activities"] as? [String: Bool] {
			activities = dict
		}
		ref = snapshot.ref
	}
	
	init(owner: String, dictionary: [String: AnyObject]) {
		self.owner = owner
		lastName = dictionary["lastName"] as! String
		firstName = dictionary["firstName"] as! String
		email = dictionary["email"] as! String
		gradYear = dictionary["gradYear"] as! Int
		gender = dictionary["gender"] as! String
		added = dictionary["added"] as? Date
		if let dict = dictionary["majors"] as? [String: Bool] {
			majors = dict
		}
		if let dict = dictionary["sports"] as? [String: Bool] {
			sports = dict
		}
		if let dict = dictionary["activities"] as? [String: Bool] {
			activities = dict
		}
		ref = nil
	}
	
	static func createArray(from: [String: Bool]?) -> [String] {
		var array = [String]()
		if let dict = from {
			for (key, _) in dict {
				array.append(key)
			}
		}
		return array
	}
	
	private static func nextGradYear() -> Int {
		let cal = Calendar.current
		let today = Date()
		let year = cal.component(.year, from: today)
		let month = cal.component(.month, from: today)
		if month > 3 {
			return year + 1
		} else {
			return year
		}
	}
	func isComplete() -> Bool {
		return firstName != "" && lastName != "" && email != ""
	}
	func toAnyObject() -> Any {
		return toAnyObject(includeMajors: true, includeSports: true, includeActivities: true)
	}
	func toAnyObject(includeMajors: Bool, includeSports: Bool, includeActivities: Bool) -> Any {
		var payload: [String: Any] = [
			"lastName": lastName,
			"firstName": firstName,
			"email": email,
			"gradYear": gradYear,
			"gender": gender,
			"added": Date()
		]
		if let majors = majors, includeMajors {
			payload["majors"] = majors
		}
		if let sports = sports, includeSports {
			payload["sports"] = sports
		}
		if let activities = activities, includeActivities {
			payload["activities"] = activities
		}
		return payload
	}
}

struct College {
	
	let ref: DatabaseReference?
	var owner: String
	var name: String
	var website: String
	var phone: String
	var email: String
	var details: String
	var tColor = 0x000000
	var bColor = 0xFFFFFF
	var coverImage: String?
	var notes: String?
	
	init(owner: String) {
		name = ""
		self.owner = owner
		website = ""
		phone = ""
		email = ""
		details = ""
		ref = nil
	}
	
	init(snapshot: DataSnapshot) {
		let valueDict = snapshot.value as! [String: AnyObject]
		name = valueDict["name"] as! String
		website = valueDict["website"] as? String ?? ""
		phone = valueDict["phone"] as? String ?? ""
		email = valueDict["email"] as? String ?? ""
		details = valueDict["details"] as? String ?? ""
		tColor = valueDict["textColor"] as? Int ?? 0x000000
		bColor = valueDict["backgroundColor"] as? Int ?? 0xFFFFFF
		ref = snapshot.ref
		owner = (ref?.parent?.key)!
	}
	
	init(owner: String, dictionary: [String: AnyObject]) {
		self.owner = owner
		print(dictionary)
		name = dictionary["name"] as! String
		website = dictionary["website"] as? String ?? ""
		phone = dictionary["phone"] as? String ?? ""
		email = dictionary["email"] as? String ?? ""
		details = dictionary["details"] as? String ?? ""
		tColor = dictionary["textColor"] as? Int ?? 0x000000
		bColor = dictionary["backgroundColor"] as? Int ?? 0xFFFFFF
		coverImage = dictionary["cover"] as? String
		notes = dictionary["notes"] as? String
		ref = nil
	}

	func textColor() -> UIColor {
		return UIColor.from(hex: tColor)
	}
	
	func backgroundColor() -> UIColor {
		return UIColor.from(hex: bColor)
	}
	
	func toAnyObject() -> Any {
		var payload: [String: Any] = [
			"name": name,
			"website": website,
			"phone": phone,
			"email": email,
			"details": details,
			"textColor": tColor,
			"backgroundColor": bColor
		]
		if let cover = coverImage {
			payload["cover"] = cover
		}
		return payload
	}
}

struct Fair {
	
	var name: String
	var startDate: Date
	var endDate: Date
	var latitude: Double
	var longitude: Double
	
}
