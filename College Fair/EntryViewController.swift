//
//  ViewController.swift
//  College Fair
//
//  Created by Chase Smith on 5/9/17.
//  Copyright © 2017 ls -applications. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class EntryViewController: UIViewController {

	var rootRef: DatabaseReference!
	var handle: AuthStateDidChangeListenerHandle!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		Database.database().isPersistenceEnabled = true
		rootRef = Database.database().reference()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let authUI = FUIAuth.defaultAuthUI()
		authUI?.delegate = self
		authUI?.providers = []
		handle = Auth.auth().addStateDidChangeListener() {
			(auth, user) in
			if let user = user {
				#if COLLEGE
					self.performSegue(withIdentifier: "collegeView", sender: user)
				#else
					self.performSegue(withIdentifier: "studentView", sender: user)
				#endif
			} else {
				let authViewController = authUI!.authViewController()
				self.present(authViewController, animated: true, completion: nil)
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		Auth.auth().removeStateDidChangeListener(handle)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		#if COLLEGE
			if let destination = segue.destination as? CollegeMainViewController {
				destination.collegeRef = rootRef.child("colleges/\((sender as! User).uid)")
			}
		#else
			if let navigation = segue.destination as? UINavigationController, let destination = navigation.topViewController as? StudentMainViewController {
				destination.studentRef = rootRef.child("students/\((sender as! User).uid)")
			}
		#endif
	}

}

extension EntryViewController: FUIAuthDelegate {
	
	func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
		if let error = error {
			print("Error logging in\n\(error)")
			return
		}
	}

}

extension UIView {
	
	func applyColors(text: UIColor, background: UIColor) {
		if !(self is UITextView || self is UITextField || self is UICollectionViewCell) {
			if let label = self as? UILabel {
				label.textColor = text
				label.backgroundColor = UIColor.clear
			} else if let button = self as? UIButton {
				button.setTitleColor(text, for: .normal)
				button.setTitleColor(background, for: .highlighted)
				button.setTitleColor(background, for: .selected)
				button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
			} else {
				backgroundColor = background
			}
				for subview in subviews {
					subview.applyColors(text: text, background: background)
				}
		}
	}
}
