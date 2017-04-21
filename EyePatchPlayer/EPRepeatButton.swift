//
//  EPRepeatButton.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 28/01/2016.
//  Copyright © 2016 Apppli. All rights reserved.
//

import UIKit

class EPRepeatButton: UIControl {
    
    let shuffleLayer1 = CAShapeLayer()
    let shuffleLayer2 = CAShapeLayer()
    
    let lineWidth: CGFloat = 1.0
    
    fileprivate(set) internal var isOn = false
    
    //constants (offsets, durations etc) primary instrument for making adjustments
    let mostHorizontalOffsetFromSide: CGFloat = 2.0 / 10
    let midHorizontalOffsetFromSide: CGFloat = 7 / 10
    let mostVerticalOffsetFromSide: CGFloat = 3 / 10
    let midVerticalOffsetFromSide: CGFloat = 5 / 10
    let mostAlmostOffsetMultiplied: CGFloat = 1/10
    let arrowHorizontalOffsetWidthScaled: CGFloat = 0.10
    let arrowVerticalOffsetHeightScaled: CGFloat = 0.10
    let verticalOffsetStart: CGFloat = 0.2
    let animationDuration = 0.1
    let shadowRadius: CGFloat = 2.5
    let minOpacity: Float = 0.4
    
    //points declarations
    var pointTopMostLeft = CGPoint()
    var pointTopMidLeft = CGPoint()
    var pointTopMidRight = CGPoint()
    var pointTopMostRight = CGPoint()
    var pointTopAlmostRight = CGPoint()
    var pointBotMostLeft = CGPoint()
    var pointBotAlmostLeft = CGPoint()
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
        
        backgroundColor = UIColor.clear
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clear
        setupLayer()
    }
    
    func setupLayer() {
        shuffleLayer1.contentsScale = UIScreen.main.scale
        shuffleLayer1.frame = bounds
        shuffleLayer1.lineWidth = lineWidth
        shuffleLayer1.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shuffleLayer1.fillColor = UIColor.clear.cgColor
        shuffleLayer1.shadowColor = UIColor.white.cgColor
        shuffleLayer1.shadowRadius = shadowRadius
        shuffleLayer1.shadowOpacity = 0
        shuffleLayer1.shadowOffset = CGSize.zero
        shuffleLayer1.opacity = minOpacity
        shuffleLayer1.strokeColor = UIColor.white.cgColor //self.tintColor.CGColor
        layer.addSublayer(shuffleLayer1)
        
        shuffleLayer2.contentsScale = UIScreen.main.scale
        shuffleLayer2.frame = bounds
        shuffleLayer2.lineWidth = lineWidth
        shuffleLayer2.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shuffleLayer2.fillColor = UIColor.clear.cgColor
        shuffleLayer2.shadowColor = UIColor.white.cgColor
        shuffleLayer2.shadowRadius = shadowRadius
        shuffleLayer2.shadowOpacity = 0
        shuffleLayer2.opacity = minOpacity
        shuffleLayer2.shadowOffset = CGSize.zero
        shuffleLayer2.strokeColor = UIColor.white.cgColor //self.tintColor.CGColor
        layer.addSublayer(shuffleLayer2)
    }
    
    func shuffleOnPath1() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: pointTopMostLeft)
        bezierPath.addLine(to: pointTopMidLeft)
        
        //        bezierPath.addCurveToPoint(pointBotMidRight,
        //            controlPoint1: pointControlTop,
        //            controlPoint2: pointControlBot
        //        )
        
        bezierPath.addQuadCurve(to: pointTopMidRight, controlPoint:pointControlTop)
        
        bezierPath.addLine(to: pointTopAlmostRight)
        
        bezierPath.move(to: pointArrowTopAbove)
        bezierPath.addLine(to: pointTopAlmostRight)
        bezierPath.move(to: pointArrowTopBelow)
        bezierPath.addLine(to: pointTopAlmostRight)
        
        return bezierPath
    }
    
    func shuffleOnPath2() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: pointBotMostRight)
        bezierPath.addLine(to: pointBotMidRight)
        bezierPath.addQuadCurve(to: pointBotMidLeft, controlPoint:pointControlBot)
        //        bezierPath.addCurveToPoint(pointTopMidRight,
        //            controlPoint1: pointControlBot,
        //            controlPoint2: pointControlTop
        //        )
        
        bezierPath.addLine(to: pointBotAlmostLeft)
        
        bezierPath.move(to: pointArrowBotAbove)
        bezierPath.addLine(to: pointBotAlmostLeft)
        bezierPath.move(to: pointArrowBotBelow)
        bezierPath.addLine(to: pointBotAlmostLeft)
        
        return bezierPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.calculatePoints()
        shuffleLayer1.frame = bounds
        shuffleLayer1.path = shuffleOnPath1().cgPath
        shuffleLayer2.frame = bounds
        shuffleLayer2.path = shuffleOnPath2().cgPath
    }
    
    override func tintColorDidChange() {
        self.setNeedsLayout()
    }
    
    func animateChange() {
        
        let shadow1 = CABasicAnimation(keyPath: "shadowOpacity")
        shadow1.fromValue = isOn ? 0.0 : 1.0
        shadow1.toValue = !isOn ? 0.0 : 1.0
        shadow1.duration = animationDuration
        shadow1.isRemovedOnCompletion = false
        shadow1.fillMode = kCAFillModeForwards
        shadow1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer1.add(shadow1, forKey: "shadowOpacity")
        
        let shadow2 = CABasicAnimation(keyPath: "shadowOpacity")
        shadow2.fromValue = isOn ? 0.0 : 1.0
        shadow2.toValue = !isOn ? 0.0 : 1.0
        shadow2.duration = animationDuration
        shadow2.isRemovedOnCompletion = false
        shadow2.fillMode = kCAFillModeForwards
        shadow2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer2.add(shadow2, forKey: "shadowOpacity")
        
        let opacity1 = CABasicAnimation(keyPath: "opacity")
        opacity1.fromValue = isOn ? minOpacity : 1.0
        opacity1.toValue = !isOn ? minOpacity : 1.0
        opacity1.duration = animationDuration
        opacity1.isRemovedOnCompletion = false
        opacity1.fillMode = kCAFillModeForwards
        opacity1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer1.add(opacity1, forKey: "opacity")
        
        let opacity2 = CABasicAnimation(keyPath: "opacity")
        opacity2.fromValue = isOn ? minOpacity : 1.0
        opacity2.toValue = !isOn ? minOpacity : 1.0
        opacity2.duration = animationDuration
        opacity2.isRemovedOnCompletion = false
        opacity2.fillMode = kCAFillModeForwards
        opacity2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shuffleLayer2.add(opacity2, forKey: "opacity")
    }
    
    func setOn(_ value: Bool, animated: Bool) {
        if isOn == value {
            return
        }
        self.isOn = value;
        if (animated) {
            self.animateChange()
        } else {
            shuffleLayer1.removeAllAnimations()
            shuffleLayer2.removeAllAnimations()
        }
    }
    
    func calculatePoints() {
        //start for top
        pointTopMostLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide),
            y: round(frame.height * (1 - (mostVerticalOffsetFromSide + verticalOffsetStart)))
        )
        
        pointTopMidLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide),
            y: round(frame.height * midVerticalOffsetFromSide)
        )
        
        pointTopMidRight = CGPoint(
            x: round(frame.width * (1 - midHorizontalOffsetFromSide)),
            y: round(frame.height * mostVerticalOffsetFromSide)
        )
        //finish for top
        pointTopMostRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)),
            y: round(frame.height * mostVerticalOffsetFromSide)
        )
        pointTopAlmostRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)) - mostAlmostOffsetMultiplied * frame.width,
            y: round(frame.height * mostVerticalOffsetFromSide)
        )
        pointBotMostLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide),
            y: round(frame.height * (1 - mostVerticalOffsetFromSide))
        )
        //finish for bot
        pointBotAlmostLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide) + mostAlmostOffsetMultiplied * frame.width,
            y: round(frame.height * (1 - mostVerticalOffsetFromSide))
        )
        
        pointBotMidLeft = CGPoint(
            x: round(frame.width * midHorizontalOffsetFromSide),
            y: round(frame.height * (1 - mostVerticalOffsetFromSide))
        )
        
        pointBotMidRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)),
            y: round(frame.height * (1 - midVerticalOffsetFromSide))
        )
        //start for bot
        pointBotMostRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)),
            y: round(frame.height * (mostVerticalOffsetFromSide + verticalOffsetStart))
        )
        
        pointControlTop = CGPoint(
            x: round(pointTopMostLeft.x),
            y: round(pointTopMostRight.y)
        )
        
        pointControlBot = CGPoint(
            x: round(pointBotMostRight.x),
            y: round(pointBotMostLeft.y)
        )
        
        pointArrowTopAbove = CGPoint(
            x: round(pointTopAlmostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopAlmostRight.y - frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowTopBelow = CGPoint(
            x: round(pointTopAlmostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopAlmostRight.y + frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotAbove = CGPoint(
            x: round(pointBotAlmostLeft.x + frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotAlmostLeft.y - frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotBelow = CGPoint(
            x: round(pointBotAlmostLeft.x + frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotAlmostLeft.y + frame.height * arrowVerticalOffsetHeightScaled)
        )
    }
}
