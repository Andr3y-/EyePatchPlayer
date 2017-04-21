//
//  EPProgressView.swift
//  playground
//
//  Created by Andr3y on 18/12/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPProgressView: UIControl {
    
    var lineThickness: CGFloat = 2.0
    fileprivate(set) internal var progress: Float = 0.0
    fileprivate(set) internal var editingProgress: Float = 0.0
    fileprivate(set) internal var isEditing: Bool = false
    fileprivate var tipWidth: CGFloat = 1.0
    
    var progressTintColor: UIColor = UIColor.white {
        didSet {
            setupLayers()
        }
    }
    var trackTintColor: UIColor? {
        didSet {
            setupLayers()
        }
    }
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var tipLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    func setupLayers() {
        self.backgroundColor = .clear
        self.progressLayer.backgroundColor = progressTintColor.cgColor
        
        self.trackLayer.frame = CGRect(x: 0, y: (frame.height-lineThickness)/2, width: frame.width, height: lineThickness)
        
        if let trackColor = trackTintColor {
            trackLayer.backgroundColor = trackColor.cgColor
            trackLayer.cornerRadius = lineThickness/2
            trackLayer.masksToBounds = false
        }
        
        layer.addSublayer(trackLayer)
        
        progressLayer.frame = CGRect(x: 0, y: 0, width: frame.width * CGFloat(progress), height: lineThickness)
        progressLayer.cornerRadius = lineThickness/2
        progressLayer.masksToBounds = false
        
        trackLayer.addSublayer(progressLayer)
        
        tipLayer.frame = CGRect(x: min(progressLayer.frame.width,max(progressLayer.frame.width - tipWidth, 0)), y: 0, width: tipWidth, height: lineThickness)

        let shadowRadius: CGFloat = 5.0
        tipLayer.backgroundColor = progressTintColor.cgColor
        tipLayer.shadowColor = progressTintColor.cgColor
        tipLayer.shadowOffset = CGSize.zero
        tipLayer.shadowRadius = shadowRadius
        tipLayer.shadowOpacity = 1.0
        print("self.boudns: \(self.bounds)")
        tipLayer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowRadius/2, y: -shadowRadius/2, width: shadowRadius, height: shadowRadius)).cgPath
        
        trackLayer.addSublayer(tipLayer)
    }
    
    func setProgress(_ value: Float, animated: Bool) {
        var value = value
        if (value != value) {
            print("progressView: value supplied is Nan")
            value = 0
        }
        if value > 1 {
            value = 1
        } else {
            if value < 0 {
                value = 0
            }
        }
        
        progress = value
        
        if isEditing {
            return
        }
        
        if animated {
            self.updateFrames(true)
        } else {
            self.updateFrames(false)
        }
        
    }
    
    func updateFrames(_ animated: Bool) {
        if animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        if !isEditing {
            progressLayer.frame = CGRect(x: 0, y: 0, width: frame.width * CGFloat(progress), height: lineThickness)
            tipLayer.frame = CGRect(x: min(progressLayer.frame.width,max(progressLayer.frame.width - tipWidth, 0)), y: 0, width: tipWidth, height: lineThickness)
        } else {
            progressLayer.frame = CGRect(x: 0, y: 0, width: frame.width * CGFloat(editingProgress), height: lineThickness)
            tipLayer.frame = CGRect(x: min(progressLayer.frame.width,max(progressLayer.frame.width - tipWidth, 0)), y: 0, width: tipWidth, height: lineThickness)
        }
        
        if animated {
            CATransaction.commit()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("progressView layoutSubviews, frame: \(self.frame)")
        self.setupLayers()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        print("begin")
        isEditing = true
        let location = touch.location(in: self)
        if self.bounds.contains(location) {
            editingProgress = Float(location.x / frame.width)
        }
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        print("continue")
        
        var newEditingProgress = Float(location.x / frame.width)
        if newEditingProgress > 1 {
            newEditingProgress = 1
        } else {
            if newEditingProgress < 0 {
                newEditingProgress = 0
            }
        }
        
        editingProgress = newEditingProgress
        print("\(newEditingProgress)")

        self.updateFrames(false)
        
        if self.bounds.contains(location)  {
            print("inside")
        } else {
            print("outside")
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        print("end")
        sendActions(for: .valueChanged)
        isEditing = false
        progress = editingProgress
        self.updateFrames(false)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        print("cancel")
        isEditing = false
    }
}


