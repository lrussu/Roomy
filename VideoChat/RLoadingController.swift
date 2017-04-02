//
//  RLoadingController.swift
//  VideoChat
//
//  Created by Farshx on 26/04/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class RLoadingController: UIViewController {
    
    class func showLoadingIn(_ controller: UIViewController) -> RLoadingController{
        let ss = SlideNavigationController.sharedInstance()
        let loadinController = ss?.storyboard!.instantiateViewController(withIdentifier: "loadingController") as! RLoadingController
        controller.addChildViewController(loadinController)
        loadinController.didMove(toParentViewController: controller)
        controller.view.addSubview(loadinController.view)
        return loadinController
    }

    @IBAction func rateUsAction(_ sender: AnyObject) {
        let urlApp = URL(string: getAppURLString())!
        if AP.canOpenURL(urlApp){
            AP.openURL(urlApp)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnimationAndAddIn(self.view, atCenter: CGPoint(x: kScreen.width / 2, y: isIpad ? 310 : 160))
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 1
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stopAllAnimations()
        startAnimation()
    }

    func closeLoading(){
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 0
        }, completion: { (finished) -> Void in
            self.stopAllAnimations()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }

    @IBOutlet var animationView: UIView!
    @IBOutlet var img1: UIImageView!
    @IBOutlet var img2: UIImageView!
    @IBOutlet var img3: UIImageView!
    func runSpinAnimationOnView(_ view: UIView, duration: Float, rotations: Float, repeats: Float = 100, direction: Float){
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Float(M_PI) * 2.0 /* full rotation*/ * rotations * direction as Float)
        rotationAnimation.duration = TimeInterval(duration)
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = repeats
        view.layer.add(rotationAnimation, forKey:"rotationAnimation")
    }
    func stopAllAnimations(){
        img1.layer.removeAllAnimations()
        img2.layer.removeAllAnimations()
        img3.layer.removeAllAnimations()
    }
    func startAnimation(){
        runSpinAnimationOnView(img1, duration: 10, rotations: 2, direction: 1)
        runSpinAnimationOnView(img2, duration: 10, rotations: 1, direction: -1)
        runSpinAnimationOnView(img3, duration: 10, rotations: 1, direction: 1)
    }
    func createAnimationAndAddIn(_ view: UIView, atCenter: CGPoint){
        let img1Image = UIImage(named: "1_img")
        let img2Image = UIImage(named: "2_img")
        let img3Image = UIImage(named: "3_img")
        
        img1 = UIImageView(image: img1Image)
        img2 = UIImageView(image: img2Image)
        img3 = UIImageView(image: img3Image)
        
        let imgsFrame = CGRect(x: 0, y: 0, width: img1Image!.size.width, height: img1Image!.size.height)
        img1.frame = imgsFrame
        img2.frame = imgsFrame
        img3.frame = imgsFrame
        
        animationView = UIView(frame: CGRect(x: 0, y: 0, width: imgsFrame.width, height: imgsFrame.height))
        animationView.backgroundColor = .white
        
        animationView.addSubview(img2)
        animationView.addSubview(img3)
        animationView.addSubview(img1)
        
        animationView.center = atCenter
        view.addSubview(animationView)
    }
}
