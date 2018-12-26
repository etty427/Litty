

import UIKit
import Parse

final class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
            if isDriver {
                self.performSegue(withIdentifier: "DriverView", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "RiderView", sender: nil)
            }
        }
    }
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        if signUpMode {
            createBtn.setTitle("Log In", for: .normal)
            signInBtn.setTitle("Back", for: .normal)
            orLabel.isHidden = true
            customerLabel.isHidden = true
            driverLabel.isHidden = true
            isDriverSwitch.isHidden = true
            
            signUpMode = false
            
        } else {
            createBtn.setTitle("Create a new account", for: .normal)
            signInBtn.setTitle("Sign In", for: .normal)
            orLabel.isHidden = false
            customerLabel.isHidden = false
            driverLabel.isHidden = false
            isDriverSwitch.isHidden = false
            
            signUpMode = true
        }
        
    }
    @IBAction func createAccoutBtnPressed(_ sender: Any) {
        if usernameTF.text == "" || passwordTF.text == "" {
            displayAlert(title: "Error with fields", message: "Username and password are required")
        }
        else {
            if signUpMode {
                
                let user = PFUser()
                user.username = usernameTF.text
                user.password = passwordTF.text
            
                user["isDriver"] = isDriverSwitch.isOn
                
                user.signUpInBackground { (success, error) in
                    if let error = error {
                        let displayedMessage = "Please try again later"
                    
                        self.displayAlert(title: "Sign Up Failed", message: displayedMessage)
                    }
                    else {
                        print("Account creation was successful")
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                            if isDriver {
                                self.performSegue(withIdentifier: "DriverView", sender: nil)
                            }
                            else {
                               self.performSegue(withIdentifier: "RiderView", sender: nil)
                            }
                        }
                        
                    }
                }
                
            } else {
                PFUser.logInWithUsername(inBackground: usernameTF.text!, password: passwordTF.text!) { (user, error) in
                    if let error = error {
                        let displayedMessage = "Please try again later"
                        
                        
                        self.displayAlert(title: "Log In Failed", message: displayedMessage)
                    }
                    else {
                        print("Log in Successful")
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                            if isDriver {
                                self.performSegue(withIdentifier: "DriverView", sender: nil)
                            }
                            else {
                                self.performSegue(withIdentifier: "RiderView", sender: nil)
                            }
                        }
                    }
                }
            }
        
        }
    }
    
    @IBAction func driveSwitchActionButton(_ sender: Any) {
       
    }

    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
