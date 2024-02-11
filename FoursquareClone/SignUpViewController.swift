//
//  SignUpViewController.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 28.01.2024.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != ""{
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { [self] authData, error in
                if error != nil{
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                }else{
                    if let currentUser = Auth.auth().currentUser {
                        let userId = currentUser.uid
                        
                        let user = Users(userId: userId, username: usernameText.text!, email: emailText.text!, password: passwordText.text!)
                        
                        self.saveUser(user: user)
                      
                    }
                    self.performSegue(withIdentifier: "fromSignUpToListVC", sender: nil)
                }
            }
        }else{
            makeAlert(titleInput: "Error!", messageInput: "Username/Password?")
        }
    }
    
    func saveUser(user:Users){
        
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document()
        
        let userData: [String: Any] = [
            "username": user.username,
            "email": user.email,
            "userId":user.userId
        ]
        
        userDocument.setData(userData) { error in
            if error != nil{
                self.makeAlert(titleInput: "error", messageInput:error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

}
