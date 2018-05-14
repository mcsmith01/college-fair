//
//  BorderedButton.swift
//  College Fair
//
//  Created by Chase Smith on 2/15/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BorderedButton: UIButton {
	
	@IBInspectable var radius: CGFloat = 10.0
	@IBInspectable var borderWidth: CGFloat = 2.0
	
	override func draw(_ rect: CGRect) {
		let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: borderWidth, y: borderWidth), size: CGSize(width: rect.width - borderWidth * 2, height: rect.height - borderWidth * 2)), cornerRadius: radius)
		path.lineWidth = borderWidth
		UIColor.clear.set()
		path.fill()
		titleLabel?.textColor.set()
		path.stroke()
	}

}

@IBDesignable
class UnderlinedButton: UIButton {
	
	override func draw(_ rect: CGRect) {
		if let text = titleLabel?.text {
			let underlinedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
			setAttributedTitle(underlinedString, for: .normal)
		} else {
			super.draw(rect)
		}
	}
	
}
