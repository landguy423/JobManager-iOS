//
//  MessagesViewController.swift
//  jobApp
//
//  Created by Andrii Ternovyi on 6/29/16.
//  Copyright © 2016 Andrii Ternovyi. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseAuth
import Firebase

class MessagesViewController:JSQMessagesViewController {
    
    var messages = [JSQMessage]()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    
    var jobID:NSString!
    var jobOwnerID:NSString!
    var receiverID:NSString!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = FIRAuth.auth()!.currentUser!.uid
        self.senderDisplayName = FIRAuth.auth()!.currentUser!.email
        
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        
        // This is how you remove Avatars from the messagesView
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        
        // This is a beta feature that mostly works but to make things more stable I have diabled it.
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        requestData()
    }
    
    
    //MARK: Requests
    func requestData() {
        
        let ref = FIRDatabase.database().reference().child("Messages").child(jobID as String).child(jobOwnerID as String)
        ref.observeEventType(.Value, withBlock: { (snapshot) in
            
            print(snapshot.value)
            if snapshot.value == nil {
                return
            }
            
            if let data = snapshot.value as? NSMutableDictionary {
                
                self.messages.removeAll()
                let allKeys = data.allKeys
                for (_, element) in allKeys.enumerate() {
                    
                    let obj = data[element as! String] as! NSDictionary
                    let fromUser = obj["fromUser"] as! String
                    let text = obj["message"] as! String
                    let date = NSDate(timeIntervalSince1970: (obj["date"]!) as! NSTimeInterval)
                    
                    var newMessage:JSQMessage!
                    newMessage = JSQMessage(senderId: fromUser, senderDisplayName:"", date: date, text: text)
                    self.messages.append(newMessage)
                }
                
                self.messages.sortInPlace { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
                self.finishReceivingMessageAnimated(true)
            }
        })
    }
    
    
    func sendMessage(message:NSString!) {
        
        let ref = FIRDatabase.database().reference()
        let data = ["fromUser"  : self.senderId,
                    "toUser"    : self.receiverID,
                    "message"   : message,
                    "date"      : NSNumber(double: NSDate().timeIntervalSince1970),]
        
        ref.child("Messages").child(jobID as String).child(jobOwnerID as String).childByAutoId().setValue(data)
    }
    
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        
        sendMessage(text)
    }



    override func didPressAccessoryButton(sender: UIButton) {
        //hide it
    }

    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {		
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        return messages[indexPath.item].senderId ==  self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        
        let message = messages[indexPath.item]
        if message.senderId ==  self.senderId {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return messages[indexPath.item].senderId ==  self.senderId ? 0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
}