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

        backgroundColor = UIColor.white

        setupCircle()
        setupTick()
        setupPlus()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = UIColor.white

        setupCircle()
        setupTick()
        setupPlus()
    }

    func setupCircle() {
        circlePathLayer.contentsScale = UIScreen.main.scale
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = circleLineWidth
        circlePathLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIView.defaultTintColor().cgColor
        layer.addSublayer(circlePathLayer)
    }

    func setupTick() {
        tickPathLayer.contentsScale = UIScreen.main.scale
        tickPathLayer.strokeColor = UIView.defaultTintColor().cgColor
        tickPathLayer.lineWidth = tickLineWidth
        tickPathLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(tickPathLayer)
    }

    func setupPlus() {
        plusPathLayer.contentsScale = UIScreen.main.scale
        plusPathLayer.strokeColor = UIView.defaultTintColor().cgColor
        plusPathLayer.lineWidth = plusLineWidth
        plusPathLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(plusPathLayer)
    }

    func tickFrame() -> CGRect {
        var tickFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        tickFrame.origin.x = tickPathLayer.bounds.midX - tickFrame.midX
        tickFrame.origin.y = tickPathLayer.bounds.midY - tickFrame.midY
        return tickFrame
    }

    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }

    func plusPath() -> UIBezierPath {

        let plusBezier = UIBezierPath()
        //first point
        plusBezier.move(to: CGPoint(
        x: tickFrame().midX - plusRadius,
                y: tickFrame().midY
        ))
        plusBezier.addLine(to: CGPoint(
        x: tickFrame().midX + plusRadius,
                y: tickFrame().midY
        ))
        plusBezier.move(to: CGPoint(
        x: tickFrame().midX,
                y: tickFrame().midY - plusRadius
        ))
        plusBezier.addLine(to: CGPoint(
        x: tickFrame().midX,
                y: tickFrame().midY + plusRadius
        ))

        return plusBezier
    }

    func tickPath() -> UIBezierPath {

        let tickBezier = UIBezierPath()
        //first point
        tickBezier.move(to: CGPoint(
        x: tickFrame().width * 0.22,
                y: tickFrame().height * 3 / 5
        ))
        tickBezier.addLine(to: CGPoint(
        x: tickFrame().width * 1 / 3 * 1.3,
                y: tickFrame().height * 4 / 5
        ))
        tickBezier.addLine(to: CGPoint(
        x: tickFrame().width * 4 / 5,
                y: tickFrame().height * 1.5 / 5
        ))

        return tickBezier
    }

    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }

    func setStatusComplete(_ value: Bool, animated: Bool) {

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
                animation.isRemovedOnCompletion = false

                self.tickPathLayer.add(animation, forKey: "stroke")

                let animationScale = CABasicAnimation(keyPath: "transform.scale")
                animationScale.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
                animationScale.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.15, 1.15, 1.0))
                animationScale.duration = 0.4
                animationScale.beginTime = CACurrentMediaTime() + 0.3
                animationScale.autoreverses = true
                animationScale.fillMode = kCAFillModeForwards
                animationScale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animationScale.isRemovedOnCompletion = true

                self.circlePathLayer.add(animationScale, forKey: "scale")


            } else {

                print("animating setStatusComplete false")
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = !value ? 1 : 0
                animation.toValue = value ? 1 : 0
                animation.duration = 0.25
                animation.repeatCount = 1
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false

                self.plusPathLayer.add(animation, forKey: "stroke")

            }
        }

    }

    func animateProgress(_ value: CGFloat) {
        print("rotation animation started")
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = value
        animation.duration = 0.25
        animation.repeatCount = 1
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        self.circlePathLayer.add(animation, forKey: "stroke")
    }

    func animateCompletion() {

        let animationAlpha = CABasicAnimation(keyPath: "opacity")
        animationAlpha.toValue = 0
        animationAlpha.duration = 0.25
        animationAlpha.repeatCount = 1
        animationAlpha.fillMode = kCAFillModeForwards
        animationAlpha.isRemovedOnCompletion = false
        self.plusPathLayer.add(animationAlpha, forKey: "opacity")

        self.animateProgress(1.0)

        setStatusComplete(true, animated: true)
        //        self.circlePathLayer.removeAllAnimations()
    }
    
    func animateCancellation() {        
        self.progress = 1.0
        self.circlePathLayer.removeAnimation(forKey: "rotation")
        self.plusPathLayer.removeAnimation(forKey: "rotation")
    }

    func animateRotation(_ value: Bool) {
        
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
        animationCircle.isRemovedOnCompletion = false

        self.circlePathLayer.add(animationCircle, forKey: "rotation")

        //inner plus
        print("rotation animation started")
        let animationPlus = CABasicAnimation(keyPath: "transform.rotation")
        animationPlus.toValue = 2.0 * CGFloat(M_PI)
        animationPlus.duration = 2.0
        animationPlus.repeatCount = Float.infinity
        animationPlus.fillMode = kCAFillModeForwards
        animationPlus.isRemovedOnCompletion = false
        animationPlus.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.plusPathLayer.add(animationPlus, forKey: "rotation")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
        tickPathLayer.frame = bounds
        tickPathLayer.path = tickPath().cgPath
        plusPathLayer.frame = bounds
        plusPathLayer.path = plusPath().cgPath
    }
    
}
