//
//  UpdatingView.swift
//  College Fair
//
//  Created by Chase Smith on 2/11/18.
//  Copyright © 2018 ls -applications. All rights reserved.
//

import Foundation
import UIKit

class UpdatingView: UIView {
	
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var indicator: UIActivityIndicatorView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		Bundle.main.loadNibNamed("UpdatingView", owner: self, options: nil)
		contentView.frame = self.bounds
		addSubview(contentView)
	}
	
}
