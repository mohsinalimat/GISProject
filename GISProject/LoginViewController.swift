//
//  LoginViewController.swift
//  Loba
//
//  Created by Jun Hui Foong on 26/5/16.
//  Copyright © 2016 NANYANG POLYTECHNIC. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import MaterialCard
import SCLAlertView

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var blackLine: UIImageView!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var loginBtnBG: UIImageView!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var myid : String = ""
    var nameJournal : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable Auto Correct
        Email.autocorrectionType = .No
        Password.autocorrectionType = .No
		
        //Keyboard navigation
		Email.delegate = self
		Email.returnKeyType = .Next
		Password.delegate = self
		Password.returnKeyType = .Go
        
        //hide keyboard
        let tapFunc2 = UITapGestureRecognizer.init(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapFunc2)
        
        self.login.layer.cornerRadius = 5
        self.loginBtnBG.layer.cornerRadius = 5
        
        self.view.bringSubviewToFront(blackLine)
    }
	
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField.returnKeyType == .Next {
			Password.becomeFirstResponder()
		}
		
		if textField.returnKeyType == .Go {
			self.Login(textField)
		}
		
		return true
	}

    //
    //Login Code
    //
    @IBAction func Login(sender: AnyObject) {
        hideKeyboard()
        self.login.enabled = false
        FIRAuth.auth()?.signInWithEmail(Email.text!, password: Password.text!, completion: {
            user, error in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //set alert appearance
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont.systemFontOfSize(30, weight: UIFontWeightLight),
                        kTitleHeight: 40,
                        kButtonFont: UIFont.systemFontOfSize(18, weight: UIFontWeightLight),
                        showCloseButton: false
                    )
                    self.login.enabled = true
                    //pop up alert
                    let alertView = SCLAlertView(appearance : appearance)
                    alertView.addButton("Retry") {
                        alertView.hideView()
                    }
                    alertView.showError("Login Failed", subTitle: "\n Please ensure information given is correct! \n")
                })
				
                self.Email.text! = ""
                self.Password.text! = ""
            } else {
                let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.appDelegate.managedObjectContext)
                let object = NSManagedObject.init(entity: entity!, insertIntoManagedObjectContext: self.appDelegate.managedObjectContext)
                
                object.setValue(self.Email.text!, forKey: "username")
                object.setValue(self.Password.text!, forKey: "password")
                
                do {
                    try self.appDelegate.managedObjectContext.save()
                } catch {
                    print("Unable to save!")
                }
                
                let tabBarController = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("tabBarControllerMain") as? UITabBarController
                self.presentViewController(tabBarController!, animated: true, completion: nil)
                self.Email.text! = ""
                self.Password.text! = ""
                self.updateJournal()
            }
        })
    }
    
    //
    // Update journal (Irfan's Code)
    //
    func updateJournal(){
        let userID = (FIRAuth.auth()?.currentUser?.uid)!
        let ref4 = FIRDatabase.database().reference().child("/Account")
        ref4.child("/\(userID)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            self.nameJournal = snapshot.value!["Name"] as! String
            
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
            let hour = components.hour
            let minutes = components.minute
            //Used for retrieving of date from firebase
            //var date = NSDate(timeIntervalSince1970: interval)
            let ref3 = FIRDatabase.database().reference().child("Journal/\(userID)")
            ref3.child("MonsterType").setValue("has logged in")
            ref3.child("Hour").setValue(hour)
            ref3.child("Minutes").setValue(minutes)
            ref3.child("Name").setValue(self.nameJournal)
            print("Update journal")
        })
        
    }


}

