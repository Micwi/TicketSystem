//
//  Signin.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 12/26/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class Signin: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let database = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        self.welcomeLabel.layer.borderWidth = 2
        self.welcomeLabel.layer.borderColor = UIColor.black.cgColor
    }
    @IBAction func passwordPeekButtonTapped(_ sender: Any) {
        passwordTF.isSecureTextEntry = false
    }
    @IBAction func passwordPeekLetGo(_ sender: Any) {
        passwordTF.isSecureTextEntry = true
    }
    @IBAction func signInButtonClicked(_ sender: Any) {
        if(emailTF.text!.count == 0 || passwordTF.text!.count == 0){
            self.textFieldsAreBlank()
        }else{
            signIn()
        }
    }
    func signIn() {
        FirebaseAuth.Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { result, error in guard error == nil else {
                print("An error occured while attempting to sign in...")
                self.incorrectSignInInfoWarning()
                return
            }
            //var accountStatus = String()
            let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
            let docRef = self.database.collection("Accounts").document("\(userID)")
            docRef.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                let accountType = data["Account Type"] as! String
                if accountType == "User"{
                    self.statusLabel.text = "Status: Sign in successful!"
                    print("SIGNING IN!!!!!!!!!!!!!!")
                    self.performSegue(withIdentifier: "GoToUserDash", sender: self)
                }
                else if accountType == "Employee"{
                    self.statusLabel.text = "Status: Sign in successful!"
                    print("SIGNING IN!!!!!!!!!!!!!!")
                    self.performSegue(withIdentifier: "GoToEmployeeDash", sender: self)
                }
                else if accountType == "Admin"{
                    self.statusLabel.text = "Status: Sign in successful!"
                    print("SIGNING IN!!!!!!!!!!!!!!")
                    self.performSegue(withIdentifier: "GoToAdminDash", sender: self)
                }
            }
        }
    }
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("The email and password fields are blank. Please fill in the fields.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func incorrectSignInInfoWarning() {
        let alertController = UIAlertController(title: NSLocalizedString("Incorrect Credentials",comment:""), message: NSLocalizedString("Email and/or password is incorrect. Please enter a valid email and password that was previously registered and try again.", comment: ""), preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 120, width:self.view.frame.size.width, height:self.view.frame.size.height)
            })
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 120, width:self.view.frame.size.width, height:self.view.frame.size.height)
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }}
