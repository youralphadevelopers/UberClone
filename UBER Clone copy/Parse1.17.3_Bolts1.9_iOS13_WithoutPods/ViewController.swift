//
//  ViewController.swift
//  Parse1.17.3_Bolts1.9_iOS13_WithoutPods
//
//  Created by Venom on 06/04/20.
//  Copyright © 2020 Back4app. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var userSignupSwitch: UISwitch!
    
    func displayAlert(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginSwitch(_ sender: Any) {
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert(title: "Error", message: "Name and Phone no. cannot be empty.")
        }
        else{
            
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                
                if let error = error{
                    
                    var displayErrorMessage = "Pleasae Try again Later"
                    
                    let error = error as NSError
                    
                    if let parseError = error.userInfo["error"] as? String{
                        
                        displayErrorMessage = parseError
                    }
                    self.displayAlert(title: "Sign In Failed", message: displayErrorMessage)
                    
                }
                else{
                    
                    print("Log In Successfull")
                    
                    if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                        
                        if isDriver {
                            
                            self.performSegue(withIdentifier: "toDriver", sender: self)
                            
                        } else {
                            
                            self.performSegue(withIdentifier: "toRider", sender: self)
                            
                        }
                        
                    }
                }
            })
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

