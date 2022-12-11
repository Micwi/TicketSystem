//
//  AdminDashboard.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/30/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class AdminDashboard: UIViewController{
   
    private let database = Firestore.firestore()
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var adminNameLabel: UILabel!
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do{
            try FirebaseAuth.Auth.auth().signOut()
            print("User signed out!")
            UserDefaults().removeObject(forKey: "userData")
            goToScene(identifier: "signinPage")
        } catch {
            self.signOutError()
            print("Error when signing out! Here is error:")
            print(error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.grabAdminData()
        self.currentDateLabel.text! = getCurrentDate()
    }
    
    
    func grabAdminData(){
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = self.database.collection("Accounts").document("\(userID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            let firstName = data["First Name"] as! String
            let lastName = data["Last Name"] as! String
            let adminName = "\(firstName) \(lastName)"
            self.adminNameLabel.text! = "\(adminName)"

        }
    }
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    func signOutError(){
        let alertController = UIAlertController(title: NSLocalizedString("Error Signing out",comment:""), message: NSLocalizedString("There was an error signing out of your account. Please try again!", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
}
