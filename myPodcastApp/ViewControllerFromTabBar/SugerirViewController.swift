//
//  SugerirViewController.swift
//  myPodcastApp
//
//  Created by William on 21/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class SugerirViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var tituloEdt: LoginTextField!
    @IBOutlet weak var autorEdt: LoginTextField!
    @IBOutlet weak var sugerirBtn: UIButton!
    @IBOutlet weak var blackBox: UIView!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var success:Bool = false
    var error_msg:String = ""
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var radius = CGFloat(20)

    override func viewDidLoad() {
        super.viewDidLoad()
        blackBox.layer.cornerRadius = radius
        
        sugerirBtn.layer.cornerRadius = 20
        sugerirBtn.clipsToBounds = true
        sugerirBtn.layer.borderWidth = 1
        sugerirBtn.layer.borderColor = ColorWeel().orangeColor.cgColor
        
        tituloEdt.delegate = self
        autorEdt.delegate = self
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SugerirViewController.returnTextView(gesture:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(SugerirViewController.keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SugerirViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if keyboardHeight == nil {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
    
    
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSugerir(_ sender: Any) {
        //makeResquest()
        //OnResult receved : success or NOT :
        dismiss(animated: true, completion: nil)

    }
    
}
