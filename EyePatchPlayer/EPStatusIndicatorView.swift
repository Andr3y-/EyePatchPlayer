//
//  EPStatusIndicatorView.swift
//  EyePatchPlayer
//
//  Created by Andr3y on 23/10/2015.
//  Copyright © 2015 Apppli. All rights reserved.
//

import UIKit

class EPStatusIndicatorView: UIView {

    let circlePathLayer = CAShapeLayer()
    let tickPathLayer = CAShapeLayer()
    let plusPathLayer = CAShapeLayer()

    let circleLineWidth: CGFloat = 1
    let tickLineWidth: CGFloat = 1
    let plusLineWidth: CGFloat = 1

    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }

    var statusComplete: Bool = false

    var circleRadius: CGFloat {
        get {
            return frame.height / 2 - circleLineWidth / 2
        }
    }

    var plusRadius: CGFloat {
        get {
            return round(frame.height / 2 * 0.6)
        }
    }

    func clear() {
        self.plusPathLayer.removeAllAnimations()
        self.tickPathLayer.removeAllAnimations()
        self.circlePathLayer.removeAllAnimations()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        plusPathLayer.strokeEnd = 0
        tickPathLayer.strokeEnd = 0
        circlePathLayer.strokeEnd = 1
        CATransaction.commit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame

        backgroundColor = UIColor.whiteColor()

        setupCircle()
        setupTick()
        setupPlus()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = UIColor.whiteColor()

        setupCircle()
        setupTick()
        setupPlus()
    }

    func setupCircle() {
        circlePathLayer.contentsScale = UIScreen.mainScreen().scale
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = circleLineWidth
        circlePathLayer.anchorPoint = CGPointMake(0.5, 0.5)
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
//        circlePathLayer.strokeColor = UIColor.defaultSystemTintColor().CGColor
        circlePathLayer.strokeColor = self.tintColor.CGColor
        layer.addSublayer(circlePathLayer)
    }

    func setupTick() {
        tickPathLayer.contentsScale = UIScreen.mainScreen().scale
//        tickPathLayer.strokeColor = UIColor.defaultSystemTintColor().CGColor
        tickPathLayer.strokeColor = self.tintColor.CGColor
        tickPathLayer.lineWidth = tickLineWidth
        tickPathLayer.fillColor = UIColor.clearColor().CGColor

        layer.addSublayer(tickPathLayer)
    }

    func setupPlus() {
        plusPathLayer.contentsScale = UIScreen.mainScreen().scale
//        plusPathLayer.strokeColor = UIColor.defaultSystemTintColor().CGColor
        plusPathLayer.strokeColor = self.tintColor.CGColor
        plusPathLayer.lineWidth = plusLineWidth
        plusPathLayer.fillColor = UIColor.clearColor().CGColor

        layer.addSublayer(plusPathLayer)
    }

    func tickFrame() -> CGRect {
        var tickFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        tickFrame.origin.x = CGRectGetMidX(tickPathLayer.bounds) - CGRectGetMidX(tickFrame)
        tickFrame.origin.y = CGRectGetMidY(tickPathLayer.bounds) - CGRectGetMidY(tickFrame)
        return tickFrame
    }

    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }

    func plusPath() -> UIBezierPath {

        let plusBezier = UIBezierPath()
        //first point
        plusBezier.moveToPoint(CGPoint(
        x: CGRectGetMidX(tickFrame()) - plusRadius,
                y: CGRectGetMidY(tickFrame())
        ))
        plusBezier.addLineToPoint(CGPoint(
        x: CGRectGetMidX(tickFrame()) + plusRadius,
                y: CGRectGetMidY(tickFrame())
        ))
        plusBezier.moveToPoint(CGPoint(
        x: CGRectGetMidX(tickFrame()),
                y: CGRectGetMidY(tickFrame()) - plusRadius
        ))
        plusBezier.addLineToPoint(CGPoint(
        x: CGRectGetMidX(tickFrame()),
                y: CGRectGetMidY(tickFrame()) + plusRadius
        ))

        return plusBezier
    }

    func tickPath() -> UIBezierPath {

        let tickBezier = UIBezierPath()
        //first point
        tickBezier.moveToPoint(CGPoint(
        x: CGRectGetWidth(tickFrame()) * 0.22,
                y: CGRectGetHeight(tickFrame()) * 3 / 5
        ))
        tickBezier.addLineToPoint(CGPoint(
        x: CGRectGetWidth(tickFrame()) * 1 / 3 * 1.3,
                y: CGRectGetHeight(tickFrame()) * 4 / 5
        ))
        tickBezier.addLineToPoint(CGPoint(
        x: CGRectGetWidth(tickFrame()) * 4 / 5,
                y: CGRectGetHeight(tickFrame()) * 1.5 / 5
        ))

        return tickBezier
    }

    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalInRect: circleFrame())
    }

    func setStatusComplete(value: Bool, animated: Bool) {

        if !animated {

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            plusPathLayer.strokeEnd = !value ? 1 : 0
            tickPathLayer.strokeEnd = value ? 1 : 0
            CATransaction.commit()

        } else {

            if value {

                print("animating setStatusComplete true")
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = !value ? 1 : 0
                animation.toValue = value ? 1 : 0
                animation.duration = 1.00
                animation.repeatCount = 1
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fillMode = kCAFillModeForwards
                animation.removedOnCompletion = false

                self.tickPathLayer.addAnimation(animation, forKey: "stroke")

                let animationScale = CABasicAnimation(keyPath: "transform.scale")
                animationScale.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
                animationScale.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.15, 1.15, 1.0))
                animationScale.duration = 0.4
                animationScale.beginTime = CACurrentMediaTime() + 0.3
                animationScale.autoreverses = true
                animationScale.fillMode = kCAFillModeForwards
                animationScale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animationScale.removedOnCompletion = true

                self.circlePathLayer.addAnimation(animationScale, forKey: "scale")


            } else {

                print("animating setStatusComplete false")
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = !value ? 1 : 0
                animation.toValue = value ? 1 : 0
                animation.duration = 0.25
                animation.repeatCount = 1
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fillMode = kCAFillModeForwards
                animation.removedOnCompletion = false

                self.plusPathLayer.addAnimation(animation, forKey: "stroke")

            }
        }
//        circlePathLayer.strokeColor = UIColor.blueColor().CGColor

    }

    func animateProgress(value: CGFloat) {
        print("rotation animation started")
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = value
        animation.duration = 0.25
        animation.repeatCount = 1
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false

        self.circlePathLayer.addAnimation(animation, forKey: "stroke")
    }

    func animateCompletion() {

        let animationAlpha = CABasicAnimation(keyPath: "opacity")
        animationAlpha.toValue = 0
        animationAlpha.duration = 0.25
        animationAlpha.repeatCount = 1
        animationAlpha.fillMode = kCAFillModeForwards
        animationAlpha.removedOnCompletion = false
        self.plusPathLayer.addAnimation(animationAlpha, forKey: "opacity")

        self.animateProgress(1.0)

        setStatusComplete(true, animated: true)
        //        self.circlePathLayer.removeAllAnimations()

    }

    func animateRotation(value: Bool) {
        //outer circle
        if (!value) {
            self.plusPathLayer.removeAllAnimations()
            self.circlePathLayer.removeAllAnimations()
            return
        }

        print("rotation animation started")
        let animationCircle = CABasicAnimation(keyPath: "transform.rotation")
        animationCircle.toValue = -2.0 * CGFloat(M_PI)
        animationCircle.duration = 5.0
        animationCircle.repeatCount = Float.infinity
        animationCircle.fillMode = kCAFillModeForwards
        animationCircle.removedOnCompletion = false

        self.circlePathLayer.addAnimation(animationCircle, forKey: "rotation")

        //inner plus
        print("rotation animation started")
        let animationPlus = CABasicAnimation(keyPath: "transform.rotation")
        animationPlus.toValue = 2.0 * CGFloat(M_PI)
        animationPlus.duration = 2.0
        animationPlus.repeatCount = Float.infinity
        animationPlus.fillMode = kCAFillModeForwards
        animationPlus.removedOnCompletion = false
        animationPlus.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.plusPathLayer.addAnimation(animationPlus, forKey: "rotation")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().CGPath
        tickPathLayer.frame = bounds
        tickPathLayer.path = tickPath().CGPath
        plusPathLayer.frame = bounds
        plusPathLayer.path = plusPath().CGPath
    }
}
