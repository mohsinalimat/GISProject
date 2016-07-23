//
//  FriendsChatViewController.swift
//  GISProject
//
//  Created by XINGYU on 12/6/16.
//  Copyright © 2016 NYP. All rights reserved.
//  reference to David Kababyan

import UIKit
import FirebaseDatabase
import JSQMessagesViewController
import FirebaseStorage
import Firebase
import Photos


class FriendsChatViewController: JSQMessagesViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var friend : Friends!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    public let kAVATARSTATE = "avatarState"
    public let kFIRSTRUN = "firstRun"
    
    
    //chaged
    //let ref = Firebase(url: "https://quickchataplication.firebaseio.com/Message")
    let ref = FIRDatabase.database().reference().child("FriendsModule/messages/")
    let refMembers = FIRDatabase.database().reference().child("FriendsModule/members/")
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var showAvatars: Bool = false
    var firstLoad: Bool?
    
    
    // var withUser: BackendlessUser?
    var recent: NSDictionary?
    
    var chatRoomId: String!
    
    var initialLoadComlete: Bool = false
    
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    

    
    
    
    var senderKey : String!
    var friendsKey : String!
    
    override func viewWillAppear(animated: Bool) {
        loadUserDefaults()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // ClearRecentCounter(chatRoomId)
        ref.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = senderKey
        self.senderDisplayName = friendsKey
        
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        
        self.getAvatars()
        
      
        
        
        
        
        lookForKey()
        //load firebase messages
        
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
             navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_person_2x"), style: UIBarButtonItemStyle.Plain, target: self, action: "addTapped:")
        
  
 
        
           collectionView!.collectionViewLayout.springinessEnabled = true
 
        
        
                
    }
    func addTapped (sender:UIButton) {
        print("add pressed")
        
        var myObject = NSDate()
        var outgoingMessage = OutgoingMessage?()
        
        //if text message
       
            // outgoingMessage = OutgoingMessage(message: text, senderId: self.senderKey, senderName: self.senderKey, date: date, status: "Delivered", type: "text")
            
            outgoingMessage = OutgoingMessage(message: "test text", senderId: self.friendsKey!, senderName: self.friendsKey!, date: myObject, status: "Delivered", type: "text")
      
    
        
        
        outgoingMessage!.sendMessage("\(self.chatRoomId)", item: outgoingMessage!.messageDictionary)
        
        
        
        
    }
    
    
    
    
    func lookForKey(){
        
        refMembers.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            print("sender : \(self.senderKey)")
            print("sender : \(self.friendsKey)")
            
            
            for record in snapshot.children {
                
                
                
                
                
                //print(record.value!!["\(self.friendsKey)"] as? Bool)
                
                var user1Temp : Bool = false
                var user2Temp : Bool = false
                
                var user1 = record.value!!["\(self.senderKey)"] as? Bool
                
                if(user1 != nil){
                    user1Temp = true
                }else{
                    print("user 1 not found")
                }
                
                var user2 = record.value!!["\(self.friendsKey)"] as? Bool
                
                if(user2 != nil){
                    user2Temp = true
                }else{
                    print("user 2 not found")
                }
                
                print("sender\(self.senderKey)")
                print("sender\(self.friendsKey)")
                
                
                print("aaaaaaaaaa")
                if(user1 == true && user2 == true){
                    print("-------- got it-------")
                    print(record.key!)
                    self.chatRoomId = record.key!
                    self.chatRoomId = record.key!
                    print("-------- got it-------")
                     self.loadmessages()
                }else{
                    print("no chat yet")
                }
                
            }
            
        })
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: JSQMessages dataSource functions
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == self.senderKey {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == self.senderKey {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
       let status = message["status"] as! String
        
   
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if outgoing(objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
       
   
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    
    //MARK: JSQMessages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if text != "" {
            sendMessage(text, date: date, picture: nil, location: nil)
        }
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let shareLoction = UIAlertAction(title: "Share Location", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert : UIAlertAction!) -> Void in
            
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLoction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: Send Message
    
    func sendMessage(text: String?, date: NSDate, picture: UIImage?, location: String?) {
        
        var outgoingMessage = OutgoingMessage?()
        
        //if text message
        if let text = text {
           // outgoingMessage = OutgoingMessage(message: text, senderId: self.senderKey, senderName: self.senderKey, date: date, status: "Delivered", type: "text")
            
             outgoingMessage = OutgoingMessage(message: text, senderId: self.senderKey!, senderName: self.friendsKey!, date: date, status: "Delivered", type: "text")
        }
        
        //send picture message
        if let pic = picture {
            
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: self.senderKey!, senderName: self.friendsKey!, date: date, status: "Delivered", type: "picture")
        }
        
        
        
        //play message sent sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        
        outgoingMessage!.sendMessage("\(self.chatRoomId)", item: outgoingMessage!.messageDictionary)
    }
    
    
    //MARK: Load Messages
    
    func loadmessages() {
        print("load msges")
        
        let messagesQuery = FIRDatabase.database().reference().child("FriendsModule/messages/\(self.chatRoomId)").queryLimitedToLast(25)
        print(ref)
      
         ref.child("\(self.chatRoomId)").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
             print("chatroom id \(self.chatRoomId)")
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
               
                
                if self.initialLoadComlete {
                    let incoming = self.insertMessage(item)
                    
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessageAnimated(true)
                    
                } else {
                    print("no msg : \(item)")
                    self.loaded.append(item)
                }
            }else{
                print("no snapshot")
            }
         
        })
 

       ref.child("\(self.chatRoomId)").observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            //updated message
        })
        
        
       ref.child("\(self.chatRoomId)").observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            //Deleted message
        })
        
      ref.child("\(self.chatRoomId)").observeSingleEventOfType(.Value, withBlock:{
            snapshot in
            print("00--> insert msg")
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComlete = true
        })
        
    }
    
    func insertMessages() {
        
        for item in loaded {
            //create message
            print("item 9 \(item)")
            insertMessage(item)
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        
        if(message != nil){
            messages.append(message!)
        }
        
        
        return incoming(item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if self.senderKey == item["senderId"] as! String {
            print("have location")
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if self.senderKey == item["senderId"] as! String {
            return true
        } else {
            return false
        }
    }
    
    
    //MARK: Helper functions
  
    
    func getAvatars() {
        
       
            
            print("showAvatar")
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
            //download avatars
          avatarImageFromBackendlessUser(self.senderId!)
         avatarImageFromBackendlessUser(self.friendsKey!)
            
            //create avatars
            createAvatars(avatarImagesDictionary)
        
    }
    
    func avatarImageFromBackendlessUser(user: String) {
        
        print("avatoar from backend function")
        
        let nurl = NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Smiley.svg/2000px-Smiley.svg.png")
        var imageBinary : NSData?
        if nurl != nil
        {
            imageBinary = NSData(contentsOfURL: nurl!)
        }
        
        // After retrieving the image data, we convert
        // it to an UIImage object. This is an update
        // to the User Interface.
        //
        var img : UIImage!
        if imageBinary != nil
        {
            img = UIImage(data: imageBinary!)
        }
        
        let imageData = UIImageJPEGRepresentation(img!, 1.0)
        
        
        if self.avatarImagesDictionary != nil {
            
            self.avatarImagesDictionary!.removeObjectForKey(self.senderId!)
            self.avatarImagesDictionary!.setObject(imageData!, forKey: self.senderId!)
        } else {
            self.avatarImagesDictionary = [self.senderId! : imageData!]
        }
        self.createAvatars(self.avatarImagesDictionary)
        
        
    }
    
    
    func createAvatars(avatars: NSMutableDictionary?) {
        
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        
        if let avat = avatars {
            if let currentUserAvatarImage = avat.objectForKey(self.senderId!) {
                
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        if let avat = avatars {
            if let withUserAvatarImage = avat.objectForKey(self.friendsKey!) {
                
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUserAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [self.senderId! : currentUserAvatar, self.friendsKey! : withUserAvatar]
    }
    

    
    //MARK: JSQDelegate functions
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            // let photos = IDMPhoto.photosWithImages([mediaItem.image])
            // let browser = IDMPhotoBrowser(photos: photos)
            
            //  self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            self.performSegueWithIdentifier("chatToMapSeg", sender: indexPath)
        }
        
    }
    
    
    //MARK: UIIMagePickerController functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, location: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! MapViewController
            //  mapView.location = mediaItem.location
        }
    }
    
    //MARK: UserDefaults functions
    
    func loadUserDefaults() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(showAvatars, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.boolForKey(kAVATARSTATE)
    }
}
