//
//  QRViewController.swift
//  GISProject
//
//  Created by Jun Hui Foong on 22/6/16.
//  Copyright © 2016 NYP. All rights reserved.
//

import UIKit
import Firebase
import QRCode
import MaterialCard
import Bluuur
import BFPaperButton

class QRViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var monsterLabel: UILabel!
    @IBOutlet weak var blurView: MLWLiveBlurView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBG()
    }

    override func viewWillAppear(animated: Bool) {
        generateQRCode()
        setCustomLabel()
        setBlur()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //
    // Custom labels for user based on stats
    //
    func setCustomLabel() {
        let ref = FIRDatabase.database().reference().child("/Account")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        var name : String = ""
        var card : Int = 0
        var monster : Int = 0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            ref.child("/\(uid)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                name = snapshot.value!["Name"] as! String
                let card = snapshot.value!["Cards"] as! NSNumber
                let monster = snapshot.value!["Monsters killed"] as! NSNumber
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.nameLabel.text = "\(name)"
                    self.cardLabel.text = "\(card)"
                    self.monsterLabel.text = "\(monster)"
                })
            })
        }
    }
    
    //
    // Generate user specific QRCode using UID
    //
    func generateQRCode() {
        let qrCard = MaterialCard(frame: CGRectMake(62.5, 157, 250, 250))
        qrCard.backgroundColor = UIColor.whiteColor()
        qrCard.shadowOpacity = 0.5
        qrCard.shadowOffsetHeight = 0
        qrCard.cornerRadius = 0
        self.view.addSubview(qrCard)
        
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        var qrCode = QRCode(uid)
        qrCode?.image
        qrCode?.size = CGSize(width: 300, height: 300)
        qrCode?.image
        let QRCodeImageView = UIImageView(qrCode: qrCode!)
        self.view.addSubview(QRCodeImageView)
        QRCodeImageView.frame = CGRectMake(62.5, 157, 250, 250)
    
        // material design button
//        let img: UIImage? = UIImage(named: "ic_add_white")
//        let button = BFPaperButton(frame: CGRectMake(160, 530, 55, 55), raised: true)
        let button = BFPaperButton(frame: CGRectMake(112, 550, 150, 40), raised: true)
//        button.setImage(img, forState: .Normal)
//        button.setImage(img, forState: .Highlighted)
        button.setTitle("Add Card", forState: .Normal)
        button.titleFont = UIFont(name: "HelveticaNeue-Thin", size: 23)
        button.backgroundColor = UIColor(red: 38/255, green: 232/255, blue: 167/255, alpha: 1)
//        button.cornerRadius = button.frame.size.width / 2
        button.cornerRadius = 3
        button.rippleFromTapLocation = true
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    //
    // Set HTML based map background
    //
    func setBG() {
        let localfilePath = NSBundle.mainBundle().URLForResource("simple", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(myRequest);
    }
    
    //
    // Blur overlay
    //
    func setBlur() {
        blurView.blurProgress = 0.5
    }
    
    //
    // Custom function to redirect viewcontroller (used due to button being coded and not in storyboard)
    //
    @IBAction func buttonPressed(sender: UIButton!) {
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("QRReaderViewController")
        self.showViewController(vc as! UIViewController, sender: vc)

    }

}
