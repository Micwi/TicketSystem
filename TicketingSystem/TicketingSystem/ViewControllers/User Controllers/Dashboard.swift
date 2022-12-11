//
//  Dashboard.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 12/26/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class Dashboard: UIViewController {
    
    private let database = Firestore.firestore()
   // @IBOutlet weak var welcomeLabel: UILabel!
    
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
        self.grabbingCurrentUserData()
    }
    func grabbingCurrentUserData(){
        let accountID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = database.collection("Accounts").document("\(accountID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            UserDefaults().setValue(data, forKey: "userData")
            //self.getCustomerName()
    }
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
    }}

