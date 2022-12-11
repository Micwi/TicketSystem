//
//  EmployeeDashboard.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 8/31/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore


class EmployeeDashboard: UIViewController{
    
    private let database = Firestore.firestore()
    
    @IBOutlet weak var employeeNameTF: UILabel!
    @IBOutlet weak var departmentIDTF: UILabel!
    @IBOutlet weak var currentDateTF: UILabel!
    @IBOutlet weak var departmentNameTF: UILabel!
    static var departmentID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabEmployeeData()
        self.currentDateTF.text! = getCurrentDate()
        
    }
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
    
    func grabEmployeeData(){
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        let docRef = self.database.collection("Accounts").document("\(userID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            let firstName = data["First Name"] as! String
            let lastName = data["Last Name"] as! String
            let employeeName = "\(firstName) \(lastName)"
            EmployeeDashboard.departmentID = data["Department ID"] as! String
            self.employeeNameTF.text! = "\(employeeName)"
            self.grabDepartmentName(ID: EmployeeDashboard.departmentID)
            self.departmentIDTF.text! = "\(EmployeeDashboard.departmentID)"
        }
    }
    func grabDepartmentName(ID: String){
        var departmentName = ""
        let docRef = self.database.collection("Departments").document("Department_\(ID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
               // self.rejectedAccountWarning()
                return
            }
            departmentName = data["Department Name"] as! String
            self.departmentNameTF.text! = "\(departmentName)"
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
    
