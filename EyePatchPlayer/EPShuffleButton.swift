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
    
    fileprivate(set) internal var isOn = false
    
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
        
        bezierPath.addCurve(to: pointBotMidRight,
            controlPoint1: pointControlTop,
            controlPoint2: pointControlBot
        )
        
        bezierPath.addLine(to: pointBotMostRight)

        bezierPath.move(to: pointArrowBotAbove)
        bezierPath.addLine(to: pointBotMostRight)
        bezierPath.move(to: pointArrowBotBelow)
        bezierPath.addLine(to: pointBotMostRight)
        
        return bezierPath
    }
    
    func shuffleOnPath2() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: pointBotMostLeft)
        bezierPath.addLine(to: pointBotMidLeft)
        
        bezierPath.addCurve(to: pointTopMidRight,
            controlPoint1: pointControlBot,
            controlPoint2: pointControlTop
        )
        
        bezierPath.addLine(to: pointTopMostRight)

        bezierPath.move(to: pointArrowTopAbove)
        bezierPath.addLine(to: pointTopMostRight)
        bezierPath.move(to: pointArrowTopBelow)
        bezierPath.addLine(to: pointTopMostRight)
        
        return bezierPath
    }
    
    func shuffleOffPath1() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: pointTopMostLeft)
        bezierPath.addLine(to: pointTopMidLeft)
        bezierPath.addLine(to: pointTopMidRight)
        bezierPath.addLine(to: pointTopMostRight)

        bezierPath.move(to: pointArrowTopAbove)
        bezierPath.addLine(to: pointTopMostRight)
        bezierPath.move(to: pointArrowTopBelow)
        bezierPath.addLine(to: pointTopMostRight)
        
        return bezierPath
    }
    
    func shuffleOffPath2() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: pointBotMostLeft)
        bezierPath.addLine(to: pointBotMidLeft)
        bezierPath.addLine(to: pointBotMidRight)
        bezierPath.addLine(to: pointBotMostRight)
        
        bezierPath.move(to: pointArrowBotAbove)
        bezierPath.addLine(to: pointBotMostRight)
        bezierPath.move(to: pointArrowBotBelow)
        bezierPath.addLine(to: pointBotMostRight)
        
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
            
            shuffleLayer1.path = isOn ? self.shuffleOnPath1().cgPath : self.shuffleOffPath1().cgPath
            shuffleLayer2.path = isOn ? self.shuffleOnPath2().cgPath : self.shuffleOffPath2().cgPath
        }
    }
    
    func calculatePoints() {
        pointTopMostLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide),
            y: round(frame.height * verticalOffsetFromSide)
        )
        
        pointTopMidLeft = CGPoint(
            x: round(frame.width * midHorizontalOffsetFromSide),
            y: round(frame.height * verticalOffsetFromSide)
        )
        
        pointTopMidRight = CGPoint(
            x: round(frame.width * (1 - midHorizontalOffsetFromSide)),
            y: round(frame.height * verticalOffsetFromSide)
        )
        
        pointTopMostRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)),
            y: round(frame.height * verticalOffsetFromSide)
        )
        
        pointBotMostLeft = CGPoint(
            x: round(frame.width * mostHorizontalOffsetFromSide),
            y: round(frame.height * (1 - verticalOffsetFromSide))
        )
        
        pointBotMidLeft = CGPoint(
            x: round(frame.width * midHorizontalOffsetFromSide),
            y: round(frame.height * (1 - verticalOffsetFromSide))
        )
        
        pointBotMidRight = CGPoint(
            x: round(frame.width * (1 - midHorizontalOffsetFromSide)),
            y: round(frame.height * (1 - verticalOffsetFromSide))
        )
        
        pointBotMostRight = CGPoint(
            x: round(frame.width * (1 - mostHorizontalOffsetFromSide)),
            y: round(frame.height * (1 - verticalOffsetFromSide))
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
            x: round(pointTopMostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopMostRight.y - frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowTopBelow = CGPoint(
            x: round(pointTopMostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointTopMostRight.y + frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotAbove = CGPoint(
            x: round(pointBotMostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotMostRight.y - frame.height * arrowVerticalOffsetHeightScaled)
        )
        
        pointArrowBotBelow = CGPoint(
            x: round(pointBotMostRight.x - frame.width * arrowHorizontalOffsetWidthScaled),
            y: round(pointBotMostRight.y + frame.height * arrowVerticalOffsetHeightScaled)
        )
    }
}
