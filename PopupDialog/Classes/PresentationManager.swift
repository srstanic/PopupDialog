//
//  PopupDialogPresentationManager.swift
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

final internal class PresentationManager: NSObject, UIViewControllerTransitioningDelegate {

    var transitionStyle: PopupDialogTransitionStyle
    var interactor: InteractiveTransition

    init(transitionStyle: PopupDialogTransitionStyle, interactor: InteractiveTransition) {
        self.transitionStyle = transitionStyle
        self.interactor = interactor
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: source)
        return presentationController
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .in)
        case .bounceDown:
            transition = BounceDownTransition(direction: .in)
        case .zoomIn:
            transition = ZoomTransition(direction: .in)
        case .fadeIn:
            transition = FadeTransition(direction: .in)
        case .fadeInWithinSequence:
            transition = FadeInWithinSequenceTransitionAnimator(direction: .in)
        case .flipWithinSequence:
            transition = Flip3DWithinSequenceTransitionAnimator(direction: .in)
        case .scaleInWithinSequence:
            transition = ScaleInWithinSequenceTransitionAnimator(direction: .in)        }
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if interactor.hasStarted || interactor.shouldFinish {
            return DismissInteractiveTransition()
        }

        var transition: TransitionAnimator
        switch transitionStyle {
        case .bounceUp:
            transition = BounceUpTransition(direction: .out)
        case .bounceDown:
            transition = BounceDownTransition(direction: .out)
        case .zoomIn:
            transition = ZoomTransition(direction: .out)
        case .fadeIn:
            transition = FadeTransition(direction: .out)
        case .fadeInWithinSequence:
            transition = FadeInWithinSequenceTransitionAnimator(direction: .out)
        case .flipWithinSequence:
            transition = Flip3DWithinSequenceTransitionAnimator(direction: .out)
        case .scaleInWithinSequence:
            transition = ScaleInWithinSequenceTransitionAnimator(direction: .out)
        }

        return transition
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}


class FadeInWithinSequenceTransitionAnimator: TransitionAnimator {
    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            self.to.view.layoutIfNeeded()
            let toFrame = self.to.view.subviews[0].frame
            let fromFrame = self.from.view.subviews[0].frame
            let toWidth = toFrame.width
            let toHeight = toFrame.height
            let fromWidth = fromFrame.width
            let fromHeight = fromFrame.height
//            let xScale = endRect.width/startRect.width
//            let yScale = endRect.height/startRect.height
//            transform = transform.scaledBy(x: xScale, y: yScale)

            self.to.view.alpha = 0
            self.to.view.transform = self.to.view.transform.scaledBy(x: fromWidth/toWidth, y: fromHeight/toHeight)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0
            })
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                self.to.view.alpha = 1
            })
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                self.from.view.transform = self.from.view.transform.scaledBy(x: toWidth/fromWidth, y: toHeight/fromHeight)
                self.to.view.transform = CGAffineTransform.identity
            }) { completed in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

class Flip3DWithinSequenceTransitionAnimator: TransitionAnimator {
    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            let perspective = 1.0 / 500.0

            let fromLayer = from.view.layer
            fromLayer.zPosition = 500 //TODO: will this work when more popups are on the stack?
            var fromTransform = CATransform3DIdentity
            fromTransform.m34 = CGFloat(perspective)
            //fromLayer.transform = fromTransform

            let toLayer = to.view.layer
            var toTransform = CATransform3DIdentity
            toTransform.m34 = CGFloat(perspective)
            toLayer.transform = CATransform3DRotate(
                toTransform, -.pi/2, 1, 0, 0)

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseIn], animations: {
                fromLayer.transform = CATransform3DRotate(fromTransform, .pi/2, 1, 0, 0)
            })
            UIView.animate(withDuration: 0.25, delay: 0.25, options: [.curveEaseOut], animations: {
                toLayer.transform = CATransform3DIdentity
            }) { completed in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

class FlipWithinSequenceTransitionAnimator: TransitionAnimator {
    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            //to.view.transform = CGAffineTransform(scaleX: 0, y: 1)
            to.view.layer.transform = CATransform3DRotate(
                to.view.layer.transform, .pi/4.0, 0, 1, 0)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.transform = CGAffineTransform(scaleX: 0.0001, y: 1)
            }) { completed in
                self.from.view.alpha = 0
            }
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut], animations: {
                self.to.view.transform = CGAffineTransform.identity
            }) { completed in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

/* 
   1. rotate 'from' view for .pi/2
   2. remove its contents so that it looks like it's just a rectangle with a background
   3. rotate 'from' view further .pi/2 so that it's completely flipped now
   4. scale it to the size of the 'to' view
   5. fade in 'to' view into properly positioned and sized "frame" created by transformed 'from' view
 
   BROKEN, NEEDS FIXING
 */
class Flip3DAndScaleWithinSequenceTransitionAnimator: TransitionAnimator {
    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            let perspective = 1.0 / 500.0

            let fromLayer = from.view.layer
            fromLayer.zPosition = 500 //TODO: will this work when more popups are on the stack?
            var fromTransform = CATransform3DIdentity
            fromTransform.m34 = CGFloat(perspective)

            self.to.view.layoutIfNeeded()
            let toFrame = self.to.view.subviews[0].frame
            let fromFrame = self.from.view.subviews[0].frame
            let toWidth = toFrame.width
            let toHeight = toFrame.height
            let fromWidth = fromFrame.width
            let fromHeight = fromFrame.height
            self.to.view.alpha = 0

            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
                fromLayer.transform = CATransform3DRotate(fromTransform, .pi, 1, 0, 0)
            })
            UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseIn], animations: {
//                fromLayer.transform = CATransform3DRotate(fromTransform, .pi, 1, 0, 0)
                self.from.view.transform = self.from.view.transform.scaledBy(x: toWidth/fromWidth, y: toHeight/fromHeight)
            })
            UIView.animate(withDuration: 0.2, delay: 0.4, options: [.curveEaseOut], animations: {
                self.from.view.alpha = 0
                self.to.view.alpha = 1
            }){ completed in
                transitionContext.completeTransition(completed)
            }
//            let toLayer = to.view.layer
//            var toTransform = CATransform3DIdentity
//            toTransform.m34 = CGFloat(perspective)
//            toLayer.transform = CATransform3DRotate(
//                toTransform, -.pi/2, 1, 0, 0)
//            UIView.animate(withDuration: 0.25, delay: 0.25, options: [.curveEaseOut], animations: {
//                toLayer.transform = CATransform3DIdentity
//            }) { completed in
//
//                transitionContext.completeTransition(completed)
//            }

        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

class ScaleInWithinSequenceTransitionAnimator: TransitionAnimator {
    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            to.view.alpha = 0
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: {
                self.from.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.from.view.alpha = 0.0
            })
            UIView.animate(withDuration: 0.15, delay: 0.15, options: [.curveEaseOut], animations: {
                self.to.view.alpha = 1
            }) { completed in
                transitionContext.completeTransition(completed)
            }
        case .out:
            UIView.animate(withDuration: outDuration, delay: 0.0, options: [.curveEaseIn], animations: {
                self.from.view.alpha = 0.0
            }) { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
