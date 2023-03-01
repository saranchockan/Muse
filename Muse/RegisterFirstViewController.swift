//
//  RegisterFirstViewController.swift
//  Muse
//
//  Created by Richa Gadre on 3/1/23.
//

import UIKit
import FirebaseAuth

class RegisterFirstViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    

    @IBAction func registerUser(_ sender: Any) {
        Auth.auth().createUser(withEmail: username.text!, password: password.text!) { authResult, error in
            // [START_EXCLUDE]
            print(authResult)
            print(error)
            // [END_EXCLUDE]
          }
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
