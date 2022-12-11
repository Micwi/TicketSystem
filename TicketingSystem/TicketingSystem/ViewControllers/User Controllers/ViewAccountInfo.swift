//
//  ViewAccountInfo.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 1/5/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class ViewAccountInfo: UIViewController {
    
    @IBOutlet weak var FName_TF: UITextField!
    @IBOutlet weak var DOB_TF: UITextField!
    @IBOutlet weak var LName_TF: UITextField!
    @IBOutlet weak var email_TF: UITextField!
    @IBOutlet weak var password_TF: UITextField!
    @IBOutlet weak var accountTypeTF: UITextField!
    
    private let database = Firestore.firestore()
    private var accountDetails = accountInfo()
    override func viewDidLoad() {
        super.viewDidLoad()
        grabbingUserInfoFromDB()
        
    }
    func grabbingUserInfoFromDB(){
        accountDetails = accountInfo()
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        //print("user id: \(userID)")
        let docRef = database.collection("Accounts").document("\(userID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            self.accountDetails.firstName = data["First Name"] as! String
            self.accountDetails.lastName = data["Last Name"] as! String
            self.accountDetails.emailAddress = data["Email Address"] as! String
            self.accountDetails.password = data["Password"] as! String
            self.accountDetails.dateOfBirth = data["Date of Birth"] as! String
            self.accountDetails.accountType = data["Account Type"] as! String
            
            //Setting the text labels providing the right information
            self.FName_TF.text = self.accountDetails.firstName
            self.DOB_TF.text = self.accountDetails.dateOfBirth
            self.LName_TF.text = self.accountDetails.lastName
            self.email_TF.text = self.accountDetails.emailAddress
            self.password_TF.text = self.accountDetails.password
            self.accountTypeTF.text = self.accountDetails.accountType
            //print(self.accountDetails)
        }
    }
    
    @IBAction func passwordPeekLetGo(_ sender: Any) {
        password_TF.isSecureTextEntry = false
    }
    @IBAction func passwordPeekButton(_ sender: Any) {
        password_TF.isSecureTextEntry = true
    }
}
struct accountInfo{
    var emailAddress = String()
    var password = String()
    var firstName = String()
    var lastName = String()
    var dateOfBirth = String()
    var accountType = String()
}
