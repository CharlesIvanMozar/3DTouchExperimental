//
//  ViewController.swift
//  3D Touch Test on incompatible hardware
// - my 3D Touch "hack" works by calculating the changes in the finger / touch size
// - Apple's 3D touch implementation works by  calculating microscopic distances betwixt the cover glass and the led backlight
//
//  Created by Charles Ivan J Mozar on 1/4/16.
//  Copyright © 2016 Charles Ivan Mozar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressure: UIVisualEffectView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    var isApplyingPressure = false
    var pressureChecks = 32
    var shouldDisplayFavourite = false
    var changedFavourite = false
    
    //this will prevent the oversized detection on the thumb
    var initialFingerSize: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pressure.alpha = 0
        let heartScale = CGAffineTransformMakeScale(0.5, 0.5)
        favouriteIcon.transform = heartScale
        favouriteIcon.layer.opacity = 0
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowRadius = 10.0
        imageView.layer.shadowOffset = CGSizeMake( 10, 10 )
        imageView.layer.shadowOpacity = 0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInView( view )
        let touchX = touchLocation.x
        let touchY = touchLocation.y
        if ( touchX >= imageView.frame.minX ) && ( touchX <= imageView.frame.maxX ) {
            if ( touchY >= imageView.frame.minY ) && ( touchY <= imageView.frame.maxY ) {
                let fingerPressure = touch.valueForKey( "pathMajorRadius" ) as? Float
                let expressedPressure = fingerPressure!/100
                //check if pressure is great enough to trigger "3d" touch
                initialFingerSize = CGFloat( expressedPressure ) - 0.025
                print( expressedPressure )
                if expressedPressure - Float( initialFingerSize ) >= 0.27 {
                    isApplyingPressure = true
                    let startPressure = CGAffineTransformMakeScale( 1.12, 1.12 )
                    UIView.animateWithDuration( 0.6, delay: 0, usingSpringWithDamping: 2.0, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.imageView.transform = startPressure
                        self.pressure.alpha = 0.25
                        self.imageView.layer.shadowOpacity = 0.2
                        }, completion: nil)
                } else {
                    isApplyingPressure = false
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInView( view )
        let touchX = touchLocation.x
        let touchY = touchLocation.y
        
        if ( touchX >= imageView.frame.minX ) && ( touchX <= imageView.frame.maxX ) {
            if ( touchY >= imageView.frame.minY ) && ( touchY <= imageView.frame.maxY ) {
                if pressureChecks > 0 {
                    let pressure = touch.valueForKey( "pathMajorRadius" ) as? Float
                    let expressedPressure = pressure!/100
                    if expressedPressure - Float( initialFingerSize ) >= 0.27 {
                        isApplyingPressure = true
                        let startPressure = CGAffineTransformMakeScale( 1.12, 1.12 )
                        UIView.animateWithDuration( 0.6, delay: 0, usingSpringWithDamping: 2.0, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.imageView.transform = startPressure
                            self.pressure.alpha = 0.25
                            self.imageView.layer.shadowOpacity = 0.2
                            }, completion: nil)
                    } else {
                        isApplyingPressure = false
                    }
                    pressureChecks--
                }
                if isApplyingPressure {
                    let fingerPressure = touch.valueForKey( "pathMajorRadius" ) as? Float
                    print( fingerPressure! )
                    let pressureForce = CGAffineTransformMakeScale( 1+CGFloat(fingerPressure!/120) - initialFingerSize, 1+CGFloat(fingerPressure!/120) - initialFingerSize )
                    let expressedPressure = fingerPressure!/100
                    print( expressedPressure )
                    
                    UIView.animateWithDuration(0.3, animations: {
                        if self.shouldDisplayFavourite {
                            self.favouriteIcon.layer.opacity = 1.0 - ( expressedPressure - Float( self.initialFingerSize ) )
                        } else {
                            self.favouriteIcon.layer.opacity = ( expressedPressure - Float( self.initialFingerSize ) )
                        }
                    })
                    
                    if expressedPressure >= Float( initialFingerSize ) + 0.25 {
                        if !changedFavourite {
                            shouldDisplayFavourite = !shouldDisplayFavourite
                            changedFavourite = true
                        }
                    }
                    
                    UIView.animateWithDuration( 0.2 , animations: {
                        self.pressure.alpha = ( CGFloat(fingerPressure!/100) ) //- self.initialFingerSize )
                        self.imageView.layer.shadowOpacity = 0.2 + fingerPressure!/100 - Float( self.initialFingerSize )
                    })
                    
                    UIView.animateWithDuration( 0.6, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.imageView.transform = pressureForce
                        }, completion: nil)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let regular = CGAffineTransformMakeScale( 1, 1 )
        UIView.animateWithDuration( 0.6, delay: 0, usingSpringWithDamping: 2.0, initialSpringVelocity: 1.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.imageView.transform = regular
            self.imageView.layer.shadowOpacity = 0
            self.pressure.alpha = 0
            }, completion: nil)
        if shouldDisplayFavourite {
            UIView.animateWithDuration( 0.4, animations: {
                self.favouriteIcon.layer.opacity = 1
            })
        } else {
            UIView.animateWithDuration( 0.4, animations: {
                self.favouriteIcon.layer.opacity = 0
            })
        }
        changedFavourite = false
        pressureChecks = 32
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

