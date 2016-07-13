//
//  ProfileViewController.swift
//  GISProject
//
//  Created by iOS on 16/6/16.
//  Copyright © 2016 NYP. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import Bluuur
import ISTimeline

protocol ProfileProtocol {
    func makeViewVisible()
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var blurView: MLWLiveBlurView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var name : String = ""
    var monstersKilled : Int = 0
    var level : Int = 0
    var card : Int = 0
    var ref: FIRDatabaseReference!
    var delegate: ProfileProtocol?
    
    var activityLogs: [ActivityLog] = []
    var i = 0
    var boolActivity = true
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var monstersLabel: UILabel!
//    @IBOutlet weak var levelLabel: UILabel!
//    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cards: UILabel!
    @IBOutlet weak var monstersLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var bgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLog()
        
        
        let localfilePath = NSBundle.mainBundle().URLForResource("simple", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(myRequest);
        
        //DatabaseManager.retrieveAccount("XHPcy86H9gbGHsYYfs4FWqOtbvE")
        // Do any additional setup after loading the view.
        
        self.delegate?.makeViewVisible()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        setProfileBG()
        
        let ref = FIRDatabase.database().reference().child("/Account")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in

            ref.child("/\(uid)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                
                let level = snapshot.value!["Level"] as! NSNumber
                let monstersKilled = snapshot.value!["Monsters killed"] as! NSNumber
                let name = snapshot.value!["Name"] as! String
                let pict = snapshot.value!["Picture"] as! NSNumber
                let card = snapshot.value!["Cards"] as! NSNumber
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.nameLabel.text = name
                    self.monstersLabel.text = String(monstersKilled.intValue)
                    self.levelLabel.text = String(level.intValue)
                    self.cards.text = String(card.intValue)
                    switch pict.intValue {
                    case 0 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileBlack")
                    case 1 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileBlue")
                    case 2 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileGreen")
                    case 3 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileOrange")
                    case 4 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfilePurple")
                    case 5 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileRed")
                    case 6 :
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileSponge")
                    default:
                        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
                        self.imageProfile.layer.borderWidth = 2.0
                        self.imageProfile.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1).CGColor
                        self.imageProfile.image = UIImage(named: "ProfileBlack")
                    }
                    
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    
                })
                
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismiss(){
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logout() {
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.appDelegate.managedObjectContext)
        let sortDescriptor = NSSortDescriptor.init(key: "username", ascending: true)
        let fetchReq = NSFetchRequest()
        fetchReq.entity = entity
        fetchReq.sortDescriptors = [sortDescriptor]
        
        let fetchResController = NSFetchedResultsController.init(fetchRequest: fetchReq, managedObjectContext: self.appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchResController.performFetch()
            
            for object in fetchResController.fetchedObjects! {
                self.appDelegate.managedObjectContext.deleteObject(object as! NSManagedObject)
                print("delete")
            }
            
            do {
                try self.appDelegate.managedObjectContext.save()
            } catch {
                print("Unable to delete account")
            }
            
            print("DELETE account")
        } catch {
            print("Unable to fetch!\n")
        }

        
        do {
            try! FIRAuth.auth()!.signOut()
            
            print("LOGGED OUT")
            
            self.dismiss()
        } catch {
        }
    }
    
    func setProfileBG(){
//        let i = Int(arc4random_uniform(5) + 1)
//        bgProfile.image = UIImage(named: "bg\(i)")

        blurView.blurProgress = 0.5
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func activityLog() {
        let timeline = ISTimeline(frame: CGRectMake(0, 0, 350, 220))
        timeline.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0)
        timeline.bubbleColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        timeline.titleColor = .blackColor()
        timeline.descriptionColor = .lightTextColor()
        timeline.pointDiameter = 7.0
        timeline.lineWidth = 2.0
        timeline.bubbleRadius = 0.5
        
        self.scrollView.addSubview(timeline)
        
        let ref = FIRDatabase.database().reference().child("/Activity")
        
        ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            for record in snapshot.children {
                let key = record.key!!
                
                let uid = record.value!!["uid"] as! String
                let activity = record.value!!["activity"] as! String
                let name = record.value!!["name"] as! String
                
                let point = ISPoint(title: name)
                point.description = activity
                timeline.points.append(point)
                let Activity = ActivityLog.init(key: key, activity: activity, uid: uid, name: name)
                
                self.activityLogs.append(Activity)
            }
        })
    }


}
