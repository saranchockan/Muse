//
//  WelcomeViewController.swift
//  Muse
//
//  Created by Elizabeth Snider on 3/2/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstName.layer.cornerRadius = 30
        let firstPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        firstName.leftView = firstPaddingView
        firstName.leftViewMode = .always
        
        lastName.layer.cornerRadius = 30
        let lastPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        lastName.leftView = lastPaddingView
        lastName.leftViewMode = .always
        
        phoneNumber.layer.cornerRadius = 30
        let phonePaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        phoneNumber.leftView = phonePaddingView
        phoneNumber.leftViewMode = .always
        
        location.layer.cornerRadius = 30
        let locationPaddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 31))
        location.leftView = locationPaddingView
        location.leftViewMode = .always
        
        continueButton.layer.cornerRadius = 30
    }
    
    
    @IBAction func continueToConnectSpotify(_ sender: Any){
        userFirstName = firstName.text!
        userLastName = lastName.text!
        userPhoneNumber = phoneNumber.text!
        userLocation = location.text!
    }
}
