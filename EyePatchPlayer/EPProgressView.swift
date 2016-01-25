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
    private(set) internal var progress: Float = 0.0
    private(set) internal var editingProgress: Float = 0.0
    private(set) internal var isEditing: Bool = false
    private var tipWidth: CGFloat = 1.0
    
    var progressTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            setupLayers()
        }
    }
    var trackTintColor: UIColor? {
        didSet {
            setupLayers()
        }
    }
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var tipLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    func setupLayers() {
        self.backgroundColor = .clearColor()
        self.progressLayer.backgroundColor = progressTintColor.CGColor
        
        self.trackLayer.frame = CGRectMake(0, (CGRectGetHeight(frame)-lineThickness)/2, CGRectGetWidth(frame), lineThickness)
        
        if let trackColor = trackTintColor {
            trackLayer.backgroundColor = trackColor.CGColor
            trackLayer.cornerRadius = lineThickness/2
            trackLayer.masksToBounds = false
        }
        
        layer.addSublayer(trackLayer)
        
        progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame) * CGFloat(progress), lineThickness)
        progressLayer.cornerRadius = lineThickness/2
        progressLayer.masksToBounds = false
        
        trackLayer.addSublayer(progressLayer)
        
        tipLayer.frame = CGRectMake(min(CGRectGetWidth(progressLayer.frame),max(CGRectGetWidth(progressLayer.frame) - tipWidth, 0)), 0, tipWidth, lineThickness)

        let shadowRadius: CGFloat = 5.0
        tipLayer.backgroundColor = progressTintColor.CGColor
        tipLayer.shadowColor = progressTintColor.CGColor
        tipLayer.shadowOffset = CGSizeZero
        tipLayer.shadowRadius = shadowRadius
        tipLayer.shadowOpacity = 1.0
        print("self.boudns: \(self.bounds)")
        tipLayer.shadowPath = UIBezierPath(rect: CGRectMake(-shadowRadius/2, -shadowRadius/2, shadowRadius, shadowRadius)).CGPath
        
        trackLayer.addSublayer(tipLayer)
    }
    
    func setProgress(var value: Float, animated: Bool) {
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
    
    func updateFrames(animated: Bool) {
        if animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        if !isEditing {
            progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame) * CGFloat(progress), lineThickness)
            tipLayer.frame = CGRectMake(min(CGRectGetWidth(progressLayer.frame),max(CGRectGetWidth(progressLayer.frame) - tipWidth, 0)), 0, tipWidth, lineThickness)
        } else {
            progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame) * CGFloat(editingProgress), lineThickness)
            tipLayer.frame = CGRectMake(min(CGRectGetWidth(progressLayer.frame),max(CGRectGetWidth(progressLayer.frame) - tipWidth, 0)), 0, tipWidth, lineThickness)
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
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("begin")
        isEditing = true
        let location = touch.locationInView(self)
        if self.bounds.contains(location) {
            editingProgress = Float(location.x / CGRectGetWidth(frame))
        }
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        print("continue")
        
        var newEditingProgress = Float(location.x / CGRectGetWidth(frame))
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
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("end")
        sendActionsForControlEvents(.ValueChanged)
        isEditing = false
        progress = editingProgress
        self.updateFrames(false)
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        print("cancel")
        isEditing = false
    }
}


