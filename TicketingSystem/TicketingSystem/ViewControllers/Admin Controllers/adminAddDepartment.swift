//
//  adminAddDepartment.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 11/30/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class adminAddDepartment: UIViewController, UITextFieldDelegate {
    
    private let database = Firestore.firestore()
    var departmentNameIsValid = false
    var departmentCodeIsValid = false
    var departmentValid = false
    var existingDepartmentIDs = [String]()
    var existingDepartmentNames = [String]()
    @IBAction func submitButtonTapped(_ sender: Any) {
        if(self.departmentCodeTextField.text?.count == 4){
            self.validateNewDepartment(newDepartmentID: self.departmentCodeTextField.text!, newDepartmentName: self.departmentNameTextField.text!)
            let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false)
            { (timer) in
                print("-------------------------")
                print("Is the department Valid? \(self.departmentValid)")
                
                if(self.departmentValid == true){
                    self.addDepartment(newDepartmentID: self.departmentCodeTextField.text!, newDepartmentName: self.departmentNameTextField.text!)
                    self.newDepartmentAddAlert()
                    self.dismiss(animated: true)
                }
                else{
                print("ERROR: New department addition wasn't valid!")
                }
            }
        }else{
            self.invalidDepartmentCodeAlert()
        }
    }
    @IBOutlet weak var departmentNameTextField: UITextField!
    @IBOutlet weak var departmentCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        departmentCodeTextField.delegate = self
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    func addDepartment(newDepartmentID: String, newDepartmentName: String) {
        let docRef = self.database.collection("Departments").document("Department_\(newDepartmentID)").setData([
            "Department Name": newDepartmentName,
            "Department ID": newDepartmentID
        ]) { err in
            if let err = err { print("Error writing document: \(err)")
            } else { print("Document successfully written!")}
        }
    }
    func validateNewDepartment(newDepartmentID: String, newDepartmentName: String){
        self.departmentNameIsValid = false ; self.departmentCodeIsValid = false
        self.existingDepartmentNames = [String]() ; self.existingDepartmentIDs = [String]()
        self.database.collection("Departments").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    var currentDepartmentName = data["Department Name"] as! String
                    var currentDepartmentCode = data["Department ID"] as! String
                    self.existingDepartmentNames.append(currentDepartmentName)
                    self.existingDepartmentIDs.append(currentDepartmentCode)
                }
            }
            for name in self.existingDepartmentNames {
                if(name == newDepartmentName){
                    print("-------------------------")
                    print("Department name is the same")
                    print("Inputted Name: \(name)")
                    print("Existing Dept Name: \(newDepartmentName)")
                    self.departmentNameIsValid = false
                    break
                }else{
                    self.departmentNameIsValid = true
                }
            }
            for id in self.existingDepartmentIDs {
                if(id == newDepartmentID){
                    print("-------------------------")
                    print("Department ID is the same")
                    print("Inputted ID: \(id)")
                    print("Existing Dept ID: \(newDepartmentID)")
                    self.departmentCodeIsValid = false
                    break
                }else{
                    self.departmentCodeIsValid = true
                }
            }
            if((self.departmentCodeIsValid == true) && (self.departmentNameIsValid == true)){
                print("Department Valid value:  \(self.departmentValid)")
                print("Department values are valid!")
                self.departmentValid = true
            }else{
                self.departmentValid = false
                print("Department Valid value:  \(self.departmentValid)")
                print("Department values aren't valid!")
            }
        }
    }
    func newDepartmentAddAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Department Adding Successfully!",comment:""), message: NSLocalizedString("The new department was added to the database successfully!", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func invalidDepartmentCodeAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Department ID is invalid!",comment:""), message: NSLocalizedString("Please input a 4 digit code for the new department and try again.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func departmentCodeAlreadyInUseAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Department ID already exists!",comment:""), message: NSLocalizedString("The inputted department code already exists in the database. Please input a 4 digit code for the new department and try again.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func departmentNameAlreadyInUseAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Department name already exists!",comment:""), message: NSLocalizedString("The inputted department name already exists in the database. Please input another name for the new department and try again.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
