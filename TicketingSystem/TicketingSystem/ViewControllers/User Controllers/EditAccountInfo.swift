//
//  EditAccountInfo.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 1/5/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class EditAccountInfo: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var FNName_TF: UITextField!
    @IBOutlet weak var DOB_TF: UITextField!
    @IBOutlet weak var LNName_TF: UITextField!
    @IBOutlet weak var email_TF: UITextField!
    @IBOutlet weak var password_TF: UITextField!
    @IBOutlet weak var accountTypeTF: UITextField!
    
    private let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DOB_TF.delegate = self
        grabbingUserInfoFromDB()
    }
    private var tempAccountDetails = tempAccountInfo()
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Update DB
        updateDataInDB()
    }
    func grabbingUserInfoFromDB(){
        tempAccountDetails = tempAccountInfo()
        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
        //print("user id: \(userID)")
        let docRef = database.collection("Accounts").document("\(userID)")
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            self.tempAccountDetails.firstName = data["First Name"] as! String
            self.tempAccountDetails.lastName = data["Last Name"] as! String
            self.tempAccountDetails.emailAddress = data["Email Address"] as! String
            self.tempAccountDetails.password = data["Password"] as! String
            self.tempAccountDetails.dateOfBirth = data["Date of Birth"] as! String
            self.tempAccountDetails.accountType = data["Account Type"] as! String
            
            //Setting the text labels providing the right information
            self.FNName_TF.placeholder = self.tempAccountDetails.firstName
            self.DOB_TF.placeholder = self.tempAccountDetails.dateOfBirth
            self.LNName_TF.placeholder = self.tempAccountDetails.lastName
            self.email_TF.placeholder = self.tempAccountDetails.emailAddress
            self.password_TF.placeholder = self.tempAccountDetails.password
            self.accountTypeTF.text = self.tempAccountDetails.accountType
            //print(self.accountDetails)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func updateDataInDB(){
        var validCount = 0
        if(FNName_TF.text == "" || DOB_TF.text == "" ||
           LNName_TF.text == "" || email_TF.text == "" || password_TF.text == ""){
            self.textFieldsIncompleteAlert()}
        //Validates Date of Birth to make sure its appropriate
        if(!(DOB_TF.text!.count == 0)){
            if(DOB_TF.text!.count == 10){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "MM/DD/YYYY"
                let date = dateFormatter.date(from: (DOB_TF.text!))
                if(validateDateOfBirth(dateOfBirth: DOB_TF.text!)){
                    if((validate_DateOfBirth(dateOfBirth: date!) >= 18) && (validate_DateOfBirth(dateOfBirth: date!) <= 100)){
                        print("DOB Valid!")
                        validCount+=1}
                    else{self.ageInvalidAlert()}}
                else{self.dateOfBirthTFInvalidAlert()}}
            else{self.dateOfBirthTFInvalidAlert()}}
        //Validates email address to make sure it follows correct format
        if(!(email_TF.text!.count == 0)) {
            if(validateEmailAddress(emailAddress: email_TF.text!)){
                validCount+=1}
            else{self.emailAddressInvalidAlert()}}
        if(!(password_TF.text!.count == 0)){
            if(validatePassword(password: password_TF.text!)){
                validCount+=1 ; print("New Password Valid!")}
            else{self.passwordsInvalidAlert()}}
        if(validCount == 3){
            let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? "nil"
            self.database.collection("Accounts").document("\(userID)").setData([
                "First Name": FNName_TF.text!,
                "Date of Birth": DOB_TF.text!,
                "Last Name": LNName_TF.text!,
                "Email Address": email_TF.text!,
                "Password": password_TF.text!,
            ], merge: true) { err in
                if let err = err { print("Error writing document: \(err)")
                } else { print("Document successfully written!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // Minimum of eight characters including at least 1 letter and 1 number
    func validatePassword(password: String) -> Bool { return validate(userEntry: password, regEx: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$") }
    func passwordsInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Password  doesn't meet requirements",comment:""), message: NSLocalizedString("Please create a password with a minimum length of 8 characters and it must include   at least one letter and one number", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""),    style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func validateEmailAddress(emailAddress: String) -> Bool { return validate(userEntry: emailAddress, regEx: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") }
    func emailAddressInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Email Address doesn't meet requirements.",comment:""), message: NSLocalizedString("Please provide a correctly formatted email address.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //Checks if inputted month and date are valid
    func validateDateOfBirth(dateOfBirth: String) -> Bool {
        return validate(userEntry: dateOfBirth, regEx: "^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$")
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.rangeOfCharacter(from: NSCharacterSet.letters)) != nil {
            return false
        } else if textField.placeholder == self.DOB_TF.placeholder{
            if (textField.text!.count >= 10 && string != ""){
                return false
            } else if ((textField.text?.count == 2 || textField.text?.count == 5) && string != ""){
                textField.text! += "/"
            }
        }
            return true
    }
    func validate(userEntry: String, regEx: String) -> Bool {
        let regEx = regEx
        let trimmedString = userEntry.trimmingCharacters(in: .whitespaces)
        let validateEntry = NSPredicate(format:"SELF MATCHES %@", regEx)
        let isValid = validateEntry.evaluate(with: trimmedString)
        return isValid
    }
    func validate_DateOfBirth(dateOfBirth: Date) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: currentDate)
        let currentAge = ageComponents.year!
        print("Current Age: ", currentAge)
        return currentAge
    }
    func goToScene(identifier: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        self.present(newViewController, animated: true, completion: nil)
    }
    func textFieldsIncompleteAlert() {
        let alertController = UIAlertController(title: "Try Again", message: "Could not be updated. One or more fields were left empty or incomplete. Please try again.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Okay", style: .default) { _ in}
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    func ageInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Date of birth is invalid",comment:""), message: NSLocalizedString("The inputted year is not valid for this app.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func dateOfBirthTFInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Date of birth is invalid",comment:""), message: NSLocalizedString("Please fill the field with a correctly formatted date of birth (MM/DD/YYYY).", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
struct tempAccountInfo{
    var emailAddress = String()
    var password = String()
    var firstName = String()
    var lastName = String()
    var dateOfBirth = String()
    var accountType = String()
}
