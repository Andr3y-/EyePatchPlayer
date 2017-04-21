//
//  EPBandSliderThumbLayer.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 03/11/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPBandSliderThumbLayer: CAShapeLayer {
    var highlighted = false
    weak var bandSlider: EPVerticalBandSlider?
    var textLayer = EPVATextLayer()
    
    var gainValue: Int  = 0 {
        didSet {
            self.textLayer.string = "\(bandSlider!.currentValue > 0 ? "+" : "-")\(bandSlider!.currentValue)dB"
        }
    }
    
    override init() {
        super.init()
        self.textLayer.contentsScale = UIScreen.main.scale
        self.textLayer.string = "\(gainValue > 0 ? "+" : "-")\(gainValue)dB"
        self.textLayer.fontSize = 11
//        self.textLayer.font = UIFont(name: "Courier New", size: 12)
        self.textLayer.alignmentMode = kCAAlignmentCenter

        self.textLayer.backgroundColor = UIColor.clear.cgColor
        self.textLayer.foregroundColor = UIColor.darkGray.cgColor
        self.addSublayer(self.textLayer)
        
        self.contentsScale = UIScreen.main.scale
        self.frame = bounds
        self.lineWidth = 3.0
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.fillColor = UIColor.white.cgColor
        self.backgroundColor = UIColor.clear.cgColor
        self.strokeColor = UIView.defaultTintColor().cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        self.path = roundPath().cgPath
        self.textLayer.frame = self.bounds
        if let bandSlider = self.bandSlider {
            let currentValueString = "\(Int(bandSlider.currentValue) > 0 ? "+" : "-")\(abs(Int(bandSlider.currentValue)) > 9 ? "" : "0")\(Int(abs(bandSlider.currentValue)))dB"
            self.textLayer.string = currentValueString
        }
    }
    func roundPath() -> UIBezierPath {
        return UIBezierPath(ovalIn: self.bounds.insetBy(dx: self.lineWidth/2, dy: self.lineWidth/2)
)
    }

}
