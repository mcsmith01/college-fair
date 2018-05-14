//
//  ColorSelectionViewController.swift
//  College Fair
//
//  Created by Chase Smith on 1/31/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class ColorSelectionViewController: UIViewController {
	
	@IBOutlet weak var redSlider: UISlider!
	@IBOutlet weak var redField: UITextField!
	@IBOutlet weak var greenSlider: UISlider!
	@IBOutlet weak var greenField: UITextField!
	@IBOutlet weak var blueSlider: UISlider!
	@IBOutlet weak var blueField: UITextField!
	@IBOutlet weak var previewView: UIView!
	@IBOutlet weak var containerView: UIView!

	var hex: Int!
	var fields = [UISlider: UITextField]()
	var sliders = [UITextField: UISlider]()
	var applyColor: ((Int) -> Void)!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		fields[redSlider] = redField
		fields[greenSlider] = greenField
		fields[blueSlider] = blueField
		sliders[redField] = redSlider
		sliders[greenField] = greenSlider
		sliders[blueField] = blueSlider
		var value = hex!
		blueSlider.setValue(Float(value % 256), animated: false)
		value /= 256
		greenSlider.setValue(Float(value % 256), animated: false)
		value /= 256
		redSlider.setValue(Float(value), animated: false)
		sliderMoved(redSlider)
		sliderMoved(greenSlider)
		sliderMoved(blueSlider)
		let layer = previewView.layer
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 1.0
		layer.cornerRadius = 7.0
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		preferredContentSize = containerView.bounds.size
	}
	
	func updateColor() {
		DispatchQueue.main.async {
			self.previewView.backgroundColor = UIColor.from(red: Int(self.redSlider.value), green: Int(self.greenSlider.value), blue: Int(self.blueSlider.value))
		}
	}
	
	@IBAction func sliderMoved(_ slider: UISlider) {
		let value = NSNumber(value: slider.value + 0.5).intValue
		slider.setValue(Float(value), animated: false)
		fields[slider]!.text = String(describing: value)
		updateColor()
	}
	
	@IBAction func apply(_ sender: AnyObject?) {
		var hex = Int(redSlider.value)
		hex = hex * 256 + Int(greenSlider.value)
		hex = hex * 256 + Int(blueSlider.value)
		debugPrint("Set color: \(hex)")
		applyColor(hex)
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancel(_ sender: AnyObject?) {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	
}

extension ColorSelectionViewController: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		var setValue = 0
		if let value = Int(textField.text!) {
			if value > 255 {
				setValue = 255
			} else if value < 0 {
				setValue = 0
			} else {
				setValue = value
			}
			textField.text = String(describing: setValue)
			sliders[textField]?.value = Float(setValue)
			updateColor()
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension UIColor {

	static func from(hex: Int) -> UIColor {
		var value = hex
		let blue = value % 256
		value /= 256
		let green = value % 256
		value /= 256
		let red = value
		return from(red: red, green: green, blue: blue)
	}
	
	static func from(red: Int, green: Int, blue: Int) -> UIColor {
		return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
}

