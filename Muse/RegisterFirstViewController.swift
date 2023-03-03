//
//  RegisterFirstViewController.swift
//  Muse
//
//  Created by Richa Gadre on 3/1/23.
//

import UIKit
import FirebaseAuth

class RegisterFirstViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueToWelcomeScreen(_ sender: Any) {
        userEmail = email.text!
        userPassword = password.text!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
