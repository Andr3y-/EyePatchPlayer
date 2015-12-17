//
//  EPShuffleButton.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 16/12/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPShuffleButton: UIControl {
    
    let shuffleLayer1 = CAShapeLayer()
    let shuffleLayer2 = CAShapeLayer()
    
    let lineWidth: CGFloat = 1.0
    
    private(set) internal var isOn = false
    
    //constants (offsets, durations etc) primary instrument for making adjustments
    let mostHorizontalOffsetFromSide: CGFloat = 2.0 / 10
    let midHorizontalOffsetFromSide: CGFloat = 3.0 / 10
    let verticalOffsetFromSide: CGFloat = 3 / 10
    let arrowHorizontalOffsetWidthScaled: CGFloat = 0.10
    let arrowVerticalOffsetHeightScaled: CGFloat = 0.10
    let animationDuration = 0.1
    let shadowRadius: CGFloat = 2.5
    let minOpacity: Float = 0.4
    
    //points declarations
    var pointTopMostLeft = CGPoint()
    var pointTopMidLeft = CGPoint()
    var pointTopMidRight = CGPoint()
    var pointTopMostRight = CGPoint()
    var pointBotMostLeft = CGPoint()
    var pointBotMidLeft = CGPoint()
    var pointBotMidRight = CGPoint()
    var pointBotMostRight = CGPoint()
    var pointControlTop = CGPoint()
    var pointControlBot = CGPoint()
    var pointArrowTopAbove = CGPoint()
    var pointArrowTopBelow = CGPoint()
    var pointArrowBotAbove = CGPoint()
    var pointArrowBotBelow = CGPoint()
    
    override var frame: CGRect {
        didSet {
            //update points every time frame changes
            self.calculatePoints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clearColor()
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
        setupLayer()
    }
    
    func setupLayer() {
        shuffleLayer1.contentsScale = UIScreen.mainScreen().scale
        shuffleLayer1.frame = bounds
        shuffleLayer1.lineWidth = lineWidth
        shuffleLayer1.anchorPoint = CGPointMake(0.5, 0.5)
        shuffleLayer1.fillColor = UIColor.clearColor().CGColor
        shuffleLayer1.shadowColor = UIColor.whiteColor().CGColor
        shuffleLayer1.shadowRadius = shadowRadius
        shuffleLayer1.shadowOpacity = 0
        shuffleLayer1.shadowOffset = CGSizeZero
        shuffleLayer1.opacity = minOpacity
        shuffleLayer1.strokeColor = UIColor.whiteColor().CGColor //self.tintColor.CGColor
        layer.addSublayer(shuffleLayer1)
        
        shuffleLayer2.contentsScale = UIScreen.mainScreen().scale
        shuffleLayer2.frame = bounds
        shuffleLayer2.lineWidth = lineWidth
        shuffleLayer2.anchorPoint = CGPointMake(0.5, 0.5)
        shuffleLayer2.fillColor = UIColor.clearColor().CGColor
        shuffleLayer2.shadowColor = UIColor.whiteColor().CGColor
        shuffleLayer2.shadowRadius = shadowRadius
        shuffleLayer2.shadowOpacity = 0
        shuffleLayer2.opacity = minOpacity
        shuffleLayer2.shadowOffset = CGSizeZero
        shuffleLayer2.strokeColor = UIColor.whiteColor().CGColor //self.tintColor.CGColor
        layer.addSublayer(shuffleLayer2)
    }
    
    func shuffleOnPath1() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(pointTopMostLeft)
        bezierPath.addLineToPoint(pointTopMidLeft)
        
        bezierPath.addCurveToPoint(pointBotMidRight,
            controlPoint1: pointControlTop,
            controlPoint2: pointControlBot
        )
        
        bezierPath.addLineToPoint(pointBotMostRight)

        bezierPath.moveToPoint(pointArrowBotAbove)
        bezierPath.addLineToPoint(pointBotMostRight)
        bezierPath.moveToPoint(pointArrowBotBelow)
        bezierPath.addLineToPoint(pointBotMostRight)
        
        return bezierPath
    }
    
    func shuffleOnPath2() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(pointBotMostLeft)
        bezierPath.addLineToPoint(pointBotMidLeft)
        
        bezierPath.addCurveToPoint(pointTopMidRight,
            controlPoint1: pointControlBot,
            controlPoint2: pointControlTop
        )
        
        bezierPath.addLineToPoint(pointTopMostRight)

        bezierPath.moveToPoint(pointArrowTopAbove)
        bezierPath.addLineToPoint(pointTopMostRight)
        bezierPath.moveToPoint(pointArrowTopBelow)
        bezierPath.addLineToPoint(pointTopMostRight)
        
        return bezierPath
    }
    
    func shuffleOffPath1() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(pointTopMostLeft)
        bezierPath.addLineToPoint(pointTopMidLeft)
        bezierPath.addLineToPoint(pointTopMidRight)
        bezierPath.addLineToPoint(pointTopMostRight)

        bezierPath.moveToPoint(pointArrowTopAbove)
        bezierPath.addLineToPoint(pointTopMostRight)
        bezierPath.moveToPoint(pointArrowTopBelow)
        bezierPath.addLineToPoint(pointTopMostRight)
        
        return bezierPath
    }
    
    func shuffleOffPath2() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(pointBotMostLeft)
        bezierPath.addLineToPoint(pointBotMidLeft)
        bezierPath.addLineToPoint(pointBotMidRight)
        bezierPath.addLineToPoint(pointBotMostRight)
        
        bezierPath.moveToPoint(pointArrowBotAbove)
        bezierPath.addLineToPoint(pointBotMostRight)
        bezierPath.moveToPoint(pointArrowBotBelow)
        bezierPath.addLineToPoint(pointBotMostRight)
        
        return bezierPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.calculatePoints()
        shuffleLayer1.frame = bounds
        shuffleLayer1.path = shuffleOnPath1().CGPath
        shuffleLayer2.frame = bounds
        shuffleLayer2.path = shuffleOnPath2().CGPath
    }
    
    override func tintColorDidChange() {
        self.setNeedsLayout()
    }
    
    func animateChange() {
        
//        disabled morph animation coz doesn't look cool
//        print("animateChange")

//        let morph1 = CABasicAnimation(keyPath: "path")
//        
//        morph1.duration = animationDuration
//        print("from")
//        morph1.fromValue = !isOn ? self.shuffleOnPath1().CGPath : self.shuffleOffPath1().CGPath
//        print("to")
//        morph1.toValue = isOn ? self.shuffleOnPath1().CGPath : self.shuffleOffPath1().CGPath
//        morph1.removedOnCompletion = false
//        morph1.fillMode = kCAFillModeForwards
//        morph1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//        

//        let morph2 = CABasicAnimation(keyPath: "path")
//        
//        morph2.duration = animationDuration
//        print("from")
//        morph2.fromValue = !isOn ? self.shuffleOnPath2().CGPath : self.shuffleOffPath2().CGPath
//        print("to")
//        morph2.toValue = isOn ? self.shuffleOnPath2().CGPath : self.shuffleOffPath2().CGPath
//        morph2.removedOnCompletion = false
//        morph2.fillMode = kCAFillModeForwards
//        morph1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
//        shuffleLayer1.addAnimation(morph1, forKey: "morphAnimation")
//        shuffleLayer2.addAnimation(morph2, forKey: "morphAnimation")
        
        let shadow1 = CABasicAnimation(keyPath: "shadowOpacity")
        shadow1.fromValue = isOn ? 0.0 : 1.0
        shadow1.toValue = !isOn ? 0.0 : 1.0
        shadow1.duration = animationDuration
        shadow1.removedOnCompletion = false
        shadow1.fillMode = kCAFillModeForwards
        shadow1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer1.addAnimation(shadow1, forKey: "shadowOpacity")
        
        let shadow2 = CABasicAnimation(keyPath: "shadowOpacity")
        shadow2.fromValue = isOn ? 0.0 : 1.0
        shadow2.toValue = !isOn ? 0.0 : 1.0
        shadow2.duration = animationDuration
        shadow2.removedOnCompletion = false
        shadow2.fillMode = kCAFillModeForwards
        shadow2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer2.addAnimation(shadow2, forKey: "shadowOpacity")
        
        let opacity1 = CABasicAnimation(keyPath: "opacity")
        opacity1.fromValue = isOn ? minOpacity : 1.0
        opacity1.toValue = !isOn ? minOpacity : 1.0
        opacity1.duration = animationDuration
        opacity1.removedOnCompletion = false
        opacity1.fillMode = kCAFillModeForwards
        opacity1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer1.addAnimation(opacity1, forKey: "opacity")
        
        let opacity2 = CABasicAnimation(keyPath: "opacity")
        opacity2.fromValue = isOn ? minOpacity : 1.0
        opacity2.toValue = !isOn ? minOpacity : 1.0
        opacity2.duration = animationDuration
        opacity2.removedOnCompletion = false
        opacity2.fillMode = kCAFillModeForwards
        opacity2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer2.addAnimation(opacity2, forKey: "opacity")
    }
    
    func setOn(value: Bool, animated: Bool) {
        if isOn == value {
            return
        }
        self.isOn = value;
        if (animated) {
            self.animateChange()
        } else {
            shuffleLayer1.removeAllAnimations()
            shuffleLayer2.removeAllAnimations()
            
            shuffleLayer1.path = isOn ? self.shuffleOnPath1().CGPath : self.shuffleOffPath1().CGPath
            shuffleLayer2.path = isOn ? self.shuffleOnPath2().CGPath : self.shuffleOffPath2().CGPath
        }
    }
    
    func calculatePoints() {
        pointTopMostLeft = CGPoint(
            x: round(CGRectGetWidth(frame) * mostHorizontalOffsetFromSide),
            y: round(CGRectGetHeight(frame) * verticalOffsetFromSide)
        )
        
        pointTopMidLeft = CGPoint(
            x: round(CGRectGetWidth(frame) * midHorizontalOffsetFromSide),
            y: round(CGRectGetHeight(frame) * verticalOffsetFromSide)
        )
        
        pointTopMidRight = CGPoint(
            x: round(CGRectGetWidth(frame) * (1 - midHorizontalOffsetFromSide)),
            y: round(CGRectGetHeight(frame) * verticalOffsetFromSide)
        )
        
        pointTopMostRight = CGPoint(
            x: round(CGRectGetWidth(frame) * (1 - mostHorizontalOffsetFromSide)),
            y: round(CGRectGetHeight(frame) * verticalOffsetFromSide)
        )
        
        pointBotMostLeft = CGPoint(
            x: round(CGRectGetWidth(frame) * mostHorizontalOffsetFromSide),
            y: round(CGRectGetHeight(frame) * (1 - verticalOffsetFromSide))
        )
        
        pointBotMidLeft = CGPoint(
            x: round(CGRectGetWidth(frame) * midHorizontalOffsetFromSide),
            y: round(CGRectGetHeight(frame) * (1 - verticalOffsetFromSide))
        )
        
        pointBotMidRight = CGPoint(
            x: round(CGRectGetWidth(frame) * (1 - midHorizontalOffsetFromSide)),
            y: round(CGRectGetHeight(frame) * (1 - verticalOffsetFromSide))
        )
        
        pointBotMostRight = CGPoint(
            x: round(CGRectGetWidth(frame) * (1 - mostHorizontalOffsetFromSide)),
            y: round(CGRectGetHeight(frame) * (1 - verticalOffsetFromSide))
        )
        
        pointControlTop = CGPoint(
            x: round((pointTopMidLeft.x+pointTopMidRight.x)/2),
            y: round(pointTopMidLeft.y)
        )
        
        pointControlBot = CGPoint(
            x: round((pointBotMidLeft.x+pointBotMidRight.x)/2),
            y: round(pointBotMidRight.y)
        )
        
        pointArrowTopAbove = CGPoint(
            x: round(pointTopMostRight.x - CGRectGetWidth(frame) * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopMostRight.y - CGRectGetHeight(frame) * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowTopBelow = CGPoint(
            x: round(pointTopMostRight.x - CGRectGetWidth(frame) * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopMostRight.y + CGRectGetHeight(frame) * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotAbove = CGPoint(
            x: round(pointBotMostRight.x - CGRectGetWidth(frame) * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotMostRight.y - CGRectGetHeight(frame) * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotBelow = CGPoint(
            x: round(pointBotMostRight.x - CGRectGetWidth(frame) * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotMostRight.y + CGRectGetHeight(frame) * arrowVerticalOffsetHeightScaled)
        )
    }
}
