//
//  RBuyGemsViewController.swift
//  VideoChat
//
//  Created by Farshx on 20/02/16.
//  Copyright © 2016 Farshx. All rights reserved.
//

import UIKit

func updateGems(_ gems: Int){
    let query = "UPDATE `r_user` SET `gems` = ? WHERE `id_user` = ?"
    DB.si().request(withQuery: query, andParams: [gems, myData.id])
    myData.gems = gems
}

class RBuyGemsViewController: UIViewController {
    
    @IBOutlet var myGemsLabel: UILabel!
    
    let ss = SlideNavigationController.sharedInstance()
    
    var unhideMenu = true
    
    @IBAction func buyButtonAction(_ sender: UIButton) {
        print(sender.tag)
        SpecialLoading.SI.startLoad()
        
        BannerReviewClass.sharedInstance().getOn("com.fitnesslabs.roomy.\(sender.tag)",
                                                 andDo: {
//                                                    let s = NSString(data: purchasedReceipt, encoding: NSUTF8StringEncoding)
                                                    let baseURL = URL(string: "http://vidlerr.com")!
                                                    let manager = AFHTTPSessionManager(baseURL: baseURL)
                                                    let ar = (arc4random() % 29999) + 10000
                                                    manager.post("applications/roomy/data.php",
                                                        parameters: [
                                                            "type": "buyGems2",
                                                            "summa": "\(sender.tag)",
                                                            "id_user": myData.id,
                                                            "id_facebook": myData.facebook,
                                                            "id_purchase" : "\(ar)"
                                                        ],
                                                        progress: nil,
                                                        success: { (operation, resp) -> Void in
                                                            if resp != nil{
                                                                if let resp = resp as? [String: Any]{
                                                                    if let gems = resp["gems"] as? Int{
                                                                        updateGems(gems)
                                                                        self.myGemsLabel.text = "\(gems)"
                                                                    }else{
                                                                        self.errorBuy()
                                                                    }
                                                                }
                                                            }else{
                                                                self.errorBuy()
                                                            }
                                                            SpecialLoading.SI.stopLoadin()
                                                        },
                                                        failure: { (operation, error) -> Void in
                                                            self.errorBuy()
                                                    })
            }, elseDoS: { 
                SpecialLoading.SI.stopLoadin()
            }, in: nil)
        
//        MKStoreKit.sharedKit().initiatePaymentRequestForProductWithIdentifier("com.fitnesslabs.roomy.\(sender.tag)")
        
//        MKStoreManager.sharedManager().buyFeature("com.fitnesslabs.roomy.\(sender.tag)",
//                                                  onComplete: { (str, purchasedReceipt, resss) in
//                                                    
//
//                                                    
//            }) {
//                SpecialLoading.SI.stopLoadin()
//        }
        
    }
    func errorBuy(){
        let alertController = UIAlertController(title: "Purchase field", message: "Error.\nPlease contact us for restore your purchase.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Contant us", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            BannerReviewClass.sharedInstance().support(self, andEmail: "info.publicartexpert@gmail.com")
        }))
        self.present(alertController, animated: true, completion: nil)
        SpecialLoading.SI.stopLoadin()
    }
    
    @IBAction func closeButtonAction(_ sender: AnyObject) {
        ss?.popViewController(animated: true)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if unhideMenu{
            (ss?.bottomMenu as! RBottomMenuViewController).unHideMenu()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myGemsLabel.text = "\(myData.gems)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



