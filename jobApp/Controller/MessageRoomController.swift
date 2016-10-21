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

class MessageRoomController:JSQMessagesViewController {
    
    var messages = [JSQMessage]()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    
    var to_email:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = FIRAuth.auth()!.currentUser!.uid
        self.senderDisplayName = FIRAuth.auth()!.currentUser!.email
        
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        //outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
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
        
        let ref = FIRDatabase.database().reference().child("SocialMessage")
        ref.observeEventType(.Value, withBlock: { (snapshot) in
            
            if snapshot.value == nil {
                return
            }
            
            if let data = snapshot.value as? NSMutableDictionary {
                
                self.messages.removeAll()
                for item in data {
                    if item.value["toUser"].description == self.senderDisplayName || item.value["fromUser"].description == self.senderDisplayName {
                         if item.value["toUser"].description == self.to_email || item.value["fromUser"].description == self.to_email {
                            let text = item.value["message"].description
                    
                            //let interval = item.value["date"].numberValue as? Double
                            //let date = NSDate(timeIntervalSince1970: interval!)
                            let msg_date = item.value["date"].description
                            let interval = NSNumberFormatter().numberFromString(msg_date)?.doubleValue
                             let date = NSDate(timeIntervalSince1970: interval!)
                            //let date = NSDate()
                            
                            var newMessage:JSQMessage!
                            newMessage = JSQMessage(senderId: item.value["toUser"].description, senderDisplayName:"", date: date, text: text)
                            self.messages.append(newMessage)
                        }
                    }
                }
                
                self.messages.sortInPlace { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
                self.finishReceivingMessageAnimated(true)
            }
        })
    }
    
    
    func sendMessage(message:NSString!) {
        
        let ref = FIRDatabase.database().reference()
        let data = ["fromUser"  : self.senderDisplayName,
                    "toUser"    : self.to_email,
                    "message"   : message,
                    "date"      : NSNumber(double: NSDate().timeIntervalSince1970),]
        ref.child("SocialMessage").childByAutoId().setValue(data)
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
        return messages[indexPath.item].senderId !=  self.senderDisplayName ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        
        let message = messages[indexPath.item]
        if message.senderId ==  self.senderDisplayName {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return messages[indexPath.item].senderId !=  self.senderDisplayName ? 0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
}