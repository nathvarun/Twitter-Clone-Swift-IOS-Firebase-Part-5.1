//
//  NewTweetViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 25/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewTweetViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var newTweetTextView: UITextView!
    
    @IBOutlet weak var newTweetToolbar: UIToolbar!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue = CGFloat?()
    
    //create a reference to the database
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser = AnyObject?()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.newTweetToolbar.hidden = true
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        newTweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        newTweetTextView.text = "What's Happening?"
        newTweetTextView.textColor = UIColor.lightGrayColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        enableKeyboardHideOnTap()
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
     }
    
    private func enableKeyboardHideOnTap(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewTweetViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewTweetViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewTweetViewController.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { 
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            
            self.newTweetToolbar.hidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { 
            
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            
            self.newTweetToolbar.hidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true
            , completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if(newTweetTextView.textColor == UIColor.lightGrayColor())
        {
            newTweetTextView.text = ""
            newTweetTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }

    @IBAction func didTapTweet(sender: AnyObject) {
        
        if(newTweetTextView.text.characters.count>0)
        {
            let key = self.databaseRef.child("tweets").childByAutoId().key
            
            let childUpdates = ["/tweets/\(self.loggedInUser!.uid)/\(key)/text":newTweetTextView.text,
                                "/tweets/\(self.loggedInUser!.uid)/\(key)/timestamp":"\(NSDate().timeIntervalSince1970)"]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismissViewControllerAnimated(true, completion: nil)

        }
    }
 
    
    

}
