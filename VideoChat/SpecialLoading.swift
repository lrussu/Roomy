//
//  SpecialLoading.swift
//  VideoChat
//
//  Created by Farshx on 24/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

class SpecialLoading: UIView {

//    private static var __once = {
//        
//        }

    let loadingImageView = UIImageView()
    var smallSize: CGSize! = nil
    let loading_shadow = UIImageView()
    
    class var SI: SpecialLoading {
        struct Static {
            static var onceToken: Int = 0
            static var instance: SpecialLoading? = nil
        }
        if Static.instance == nil{
            Static.instance = SpecialLoading()
            var imgs = [UIImage]()
            for index in 0..<61 {
                let filename: String!
                if index < 10{
                    filename = "Comp 1_0000\(index)"
                }else{
                    filename = "Comp 1_000\(index)"
                }
                if let im = UIImage(named: filename){
                    imgs.append(im)
                    if Static.instance!.smallSize == nil{
                        Static.instance!.smallSize = im.size
                    }
                }
            }
            Static.instance!.loadingImageView.frame = kScreen
            Static.instance!.loadingImageView.contentMode = .center
            Static.instance!.loadingImageView.animationImages = imgs
            Static.instance!.loadingImageView.animationRepeatCount = 0
            Static.instance!.loadingImageView.animationDuration = 2.0
            Static.instance!.loadingImageView.isUserInteractionEnabled = true
            Static.instance!.loading_shadow.image = UIImage(named: "loading_shadow")
            Static.instance!.loading_shadow.frame.size = Static.instance!.loading_shadow.image!.size
            Static.instance!.loadingImageView.addSubview(Static.instance!.loading_shadow)
            Static.instance!.loadingImageView.sendSubview(toBack: Static.instance!.loading_shadow)
            NC.addObserver(forName: NSNotification.Name(rawValue: "SpecialLoadingStart"), object: nil, queue: OperationQueue.main, using: { (sender) -> Void in
                Static.instance!.startLoad()
            })
            NC.addObserver(forName: NSNotification.Name(rawValue: "SpecialLoadingStop"), object: nil, queue: OperationQueue.main, using: { (sender) -> Void in
                Static.instance!.stopLoadin()
            })
        }
        return Static.instance!
    }
    
    func startLoad(){
        if let kWindow = AP.keyWindow{
            self.stopLoadin()
            self.loadingImageView.center = kWindow.center
            self.loadingImageView.frame = kScreen
            let shSizeCenter = self.loadingImageView.frame.size
            self.loading_shadow.center = CGPoint(x: shSizeCenter.width / 2, y: shSizeCenter.height / 2)
            kWindow.addSubview(self.loadingImageView)
            self.loadingImageView.startAnimating()
        }
    }
    func stopLoadin(){
        self.loadingImageView.removeFromSuperview()
        self.loadingImageView.stopAnimating()
    }
    
    func setSmallLoadingTo(_ view: UIView, atCenter: CGPoint? = nil){
        var atCenter2 = atCenter
        if atCenter2 == nil{
            atCenter2 = CGPoint(x: self.smallSize.width / 2, y: self.smallSize.width / 2)
        }
        self.stopLoadin()
        self.loadingImageView.backgroundColor = .clear
        self.loadingImageView.frame.size = self.smallSize
        self.loadingImageView.center = atCenter2!
        let shSizeCenter = self.loadingImageView.frame.size
        self.loading_shadow.center = CGPoint(x: shSizeCenter.width / 2, y: shSizeCenter.height / 2)
        view.addSubview(self.loadingImageView)
        self.loadingImageView.startAnimating()
    }
    
}
