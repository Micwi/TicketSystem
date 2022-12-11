//
//  CreateAccount.swift
//  TicketingSystem
//
//  Created by Louie Patrizi Jr. on 1/3/22.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
class CreateAccount: UIViewController, UITextFieldDelegate {
    private let database = Firestore.firestore()
    static var accountType = " "
    @IBOutlet weak var FN_TF: UITextField!
    @IBOutlet weak var LN_TF: UITextField!
    @IBOutlet weak var DOB_TF: UITextField!
    @IBOutlet weak var email_TF: UITextField!
    @IBOutlet weak var password_TF: UITextField!
    @IBOutlet weak var cPass_TF: UITextField!
    @IBOutlet weak var accountPopUpButton: UIButton!
    @IBOutlet weak var departmentIDTF: UITextField!
    private var departmentID = " "
    override func viewDidLoad() {
        super.viewDidLoad()
        DOB_TF.delegate = self
        departmentIDTF.delegate = self
        popUpButtonSetup()
        accountPopUpButton.layer.cornerRadius = 10
        departmentIDTF.isHidden = true
    }
    func popUpButtonSetup(){
        let optionClosure = {(action: UIAction) in
            print(action.title)
            //If account type is Employee, makes the department textfield appear
            self.departmentIDTF.isHidden = true
            if(self.accountPopUpButton.currentTitle! == "Employee"){
                self.departmentIDTF.text! = ""
                self.departmentIDTF.isHidden = false
            }
            
        }
        //Sets the account type options in menu
        accountPopUpButton.menu = UIMenu(children:[
            UIAction(title: "User", state: .on, handler: optionClosure),
            UIAction(title: "Admin", state: .on, handler: optionClosure),
            UIAction(title: "Employee", state: .on, handler: optionClosure)])
        accountPopUpButton.showsMenuAsPrimaryAction = true
        accountPopUpButton.changesSelectionAsPrimaryAction = true
        
        CreateAccount.accountType =  accountPopUpButton.currentTitle!
        
    }
    func departmentIDCheck(ID: String) -> Bool{
        var validDepartment = false
        switch(ID){
        case "9898":
            print("Department ID is Valid. Chosen department is Finance")
            validDepartment = true
        case "7676":
            print("Department ID is Valid. Chosen department is Human Resources")
            validDepartment = true
        case "5454":
            print("Department ID is Valid. Chosen department is IT")
            validDepartment = true
        case "3232":
            print("Department ID is Valid. Chosen department is Marketing")
            validDepartment = true
        case "2121":
            print("Department ID is Valid. Chosen department is Operations Management")
            validDepartment = true
        default:
            print("ERROR - Inputted ID is invalid! Please try again")
            self.departmentIDTFCodeNoMatch()
        }
        return validDepartment
    }
    @IBAction func CreateButtonClicked(_ sender: Any) {
        var accountValid = true
        var validFieldCount = 0
        if(!(FN_TF.text!.count == 0)) {
            tempAccountInformation.firstName = FN_TF.text!
            validFieldCount+=1
        }
        if(!(LN_TF.text!.count == 0)){
            tempAccountInformation.lastName = LN_TF.text!
            validFieldCount+=1
        }
        if(!(DOB_TF.text!.count == 0)){
            if(DOB_TF.text!.count == 10){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "MM/DD/YYYY"
                let date = dateFormatter.date(from: (DOB_TF.text!))
                if(validateDateOfBirth(dateOfBirth: DOB_TF.text!)){
                    if((validate_DateOfBirth(dateOfBirth: date!) >= 18) && (validate_DateOfBirth(dateOfBirth: date!) <= 100)){
                        print("DOB Valid!")
                        tempAccountInformation.dateOfBirth = DOB_TF.text!
                        validFieldCount+=1
                    }else{self.ageInvalidAlert()
                    }
                }else{
                    self.dateOfBirthTFInvalidAlert()
                }
            }else{
                self.dateOfBirthTFInvalidAlert()
            }
        }
        if(!(email_TF.text!.count == 0)) {
            if(validateEmailAddress(emailAddress: email_TF.text!)){
                tempAccountInformation.emailAddress = email_TF.text!
                validFieldCount+=1
            }else{
                self.emailAddressInvalidAlert()
            }
        }
        if(!(password_TF.text!.count == 0)){
            tempAccountInformation.password = password_TF.text!
            validFieldCount+=1
        }
        if(!(cPass_TF.text!.count == 0)){
            validFieldCount+=1
        }
        if(accountPopUpButton.currentTitle! == "Employee"){
            if(self.departmentIDTF.text!.count == 0){
                print("Cannot create employee account")
                self.departmentIDTFEmpty()
                accountValid = false
            }
        }
        
        if(validFieldCount == 6 && accountValid == true){
            print("All fields filled!")
            if(validatePassword(password: password_TF.text!)){
                if(password_TF.text == cPass_TF.text) {
                    tempAccountInformation.password = password_TF.text!
                    tempAccountInformation.accountType = self.accountPopUpButton.currentTitle!
                    createAccount()
                    print("temp email: \(tempAccountInformation.emailAddress)")
                    print("temp pass: \(tempAccountInformation.password)")
                }
                else{
                    self.passwordsDontMatchAlert()
                }
            }else{
                self.passwordsInvalidAlert()
            }
        }else{
            self.textFieldsAreBlank()
        }
    }
    func createAccount(){
        FirebaseAuth.Auth.auth().createUser(withEmail: tempAccountInformation.emailAddress, password: tempAccountInformation.password, completion: {result, error in guard error == nil else {
            print("An error occured while attempting to create an account...")
            self.createAccountError()
            return
        }
            let newUserID = result!.user.uid //grabs newly created user's ID
            if(tempAccountInformation.accountType == "User"){
                self.addUserDataToDB(userID: newUserID) //adding user data to database
            } else if(tempAccountInformation.accountType == "Employee"){
                //Validates the department exists
                if(self.departmentIDCheck(ID: self.departmentIDTF.text!)){
                    //adding Employee Data to database
                    self.addEmployeeDataToDB(userID: newUserID, departmentID: self.departmentIDTF.text!)
                }
            } else if(tempAccountInformation.accountType == "Admin"){
                //adding Admin data to database
                self.addAdminDataToDB(userID: newUserID)
            }
            print("Account created!")
            self.accountCreatedAlert()
            self.navigationController?.popViewController(animated: true)
            tempAccountInformation = AccountInformation()
    })
    }
    
    func addEmployeeDataToDB(userID: String, departmentID: String){
        self.database.collection("Accounts").document("\(userID)").setData([
            "Account Created": self.getCurrentDate(),
            "Account ID": userID,
            "Account Type": tempAccountInformation.accountType,
            "First Name": tempAccountInformation.firstName,
            "Last Name": tempAccountInformation.lastName,
            "Date of Birth": tempAccountInformation.dateOfBirth,
            "Email Address": tempAccountInformation.emailAddress,
            "Password": tempAccountInformation.password,
            "Department ID": departmentID
        ]) { error in
            if let error = error {print ("Error Transferring User information to database! Error code is: \(error)")
                
            }else{ print("User data transfer to Accounts collection was successful!")
                //self.navigationController?.popViewController(animated: true)
            }
        }
        self.addEmployeeInfoToDepartment(userID: userID, departmentID: departmentID)
    }
    func addEmployeeInfoToDepartment(userID: String, departmentID: String){
        self.database.collection("Departments").document("Department_\(departmentID)").collection("Department Members").document("\(userID)").setData([
            "Account Created": self.getCurrentDate(),
            "Account ID": userID,
            "Account Type": tempAccountInformation.accountType,
            "First Name": tempAccountInformation.firstName,
            "Last Name": tempAccountInformation.lastName,
            "Email Address": tempAccountInformation.emailAddress,
            "Department ID": departmentID
        ]) { error in
            if let error = error {print ("Error Transferring User information to database! Error code is: \(error)")
                
            }else{ print("User data transfer to Department collection was successful!")}
        }
    }
    func addAdminDataToDB(userID: String){
        self.database.collection("Accounts").document("\(userID)").setData([
            "Account Created": self.getCurrentDate(),
            "Account ID": userID,
            "Account Type": tempAccountInformation.accountType,
            "First Name": tempAccountInformation.firstName,
            "Last Name": tempAccountInformation.lastName,
            "Date of Birth": tempAccountInformation.dateOfBirth,
            "Email Address": tempAccountInformation.emailAddress,
            "Password": tempAccountInformation.password
        ]) { error in
            if let error = error {print ("Error Transferring User information to database! Error code is: \(error)")
                
            }else{ print("User data transfer was successful!")
                //self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func addUserDataToDB(userID: String){
        self.database.collection("Accounts").document("\(userID)").setData([
            "Account Created": self.getCurrentDate(),
            "Account ID": userID,
            "Account Type": tempAccountInformation.accountType,
            "First Name": tempAccountInformation.firstName,
            "Last Name": tempAccountInformation.lastName,
            "Date of Birth": tempAccountInformation.dateOfBirth,
            "Email Address": tempAccountInformation.emailAddress,
            "Password": tempAccountInformation.password
        ]) { error in
            if let error = error {print ("Error Transferring User information to database! Error code is: \(error)")
            }else{ print("User data transfer was successful!")
                //self.navigationController?.popViewController(animated: true)
            }
        }
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
    
    func getCurrentDate() -> String {
        let dayFormat = DateFormatter(); dayFormat.dateFormat = "MM/dd/yyyy"
        return dayFormat.string(from: Date())
    }
    func passwordsInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Password doesn't meet requirements",comment:""), message: NSLocalizedString("Please create a password with a minimum length of 8 characters and it must include at least one letter and one number", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func accountCreatedAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Account Created!",comment:""), message: NSLocalizedString("You are now able to login to your newly created account. Thank you!", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    // Minimum of eight characters including at least 1 letter and 1 number
    func validatePassword(password: String) -> Bool { return validate(userEntry: password, regEx: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$") }
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
    //Checks if inputted month and date are valid
    func validateDateOfBirth(dateOfBirth: String) -> Bool {
        return validate(userEntry: dateOfBirth, regEx: "^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$")
    }
    func validateEmailAddress(emailAddress: String) -> Bool { return validate(userEntry: emailAddress, regEx: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") }
    func emailAddressInvalidAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Email Address doesn't meet requirements.",comment:""), message: NSLocalizedString("Please provide a correctly formatted email address.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func passwordsDontMatchAlert(){
        let alertController = UIAlertController(title: NSLocalizedString("Passwords don't match.",comment:""), message: NSLocalizedString("Please make sure the passwords match in both fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func departmentIDTFEmpty(){
        let alertController = UIAlertController(title: NSLocalizedString("Department ID Field is Empty",comment:""), message: NSLocalizedString("Please make sure to fill in the correct department ID.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func departmentIDTFCodeNoMatch(){
        let alertController = UIAlertController(title: NSLocalizedString("Department ID Field is Invalid",comment:""), message: NSLocalizedString("The inputted department ID is invalid. Please make sure to fill in the correct department ID.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
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
    @IBAction func passwordPeekButtonTapped(_ sender: Any) {
        password_TF.isSecureTextEntry = false
    }
    @IBAction func passwordButtonLetGo(_ sender: Any) {
        password_TF.isSecureTextEntry = true
    }
    @IBAction func ConfirmPassPeekButtonTapped(_ sender: Any) {
        cPass_TF.isSecureTextEntry = false
    }
    @IBAction func ConfirmPassButtonLetGo(_ sender: Any) {
        cPass_TF.isSecureTextEntry = true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var value = (string.rangeOfCharacter(from: NSCharacterSet.letters)) {
            return false
        } else if textField.placeholder == "MM/DD/YYYY"{
            //Continue Here. Make "/" appear after each seciton in DOB
            if (textField.text!.count >= 10 && string != ""){
                return false
            } else if ((textField.text?.count == 2 || textField.text?.count == 5) && string != ""){
                textField.text! += "/"
            }
        } else if textField.placeholder == "Department ID"{
            if(textField.text!.count >= 4 && string != ""){
                return false}
        }
            return true
    }
    
    
    func textFieldsAreBlank(){
        let alertController = UIAlertController(title: NSLocalizedString("Fields are blank",comment:""), message: NSLocalizedString("The subject and description fields are blank. Please fill in the fields.", comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: NSLocalizedString("Okay", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func createAccountError(){
        let alertController = UIAlertController(title: NSLocalizedString("Account Creation Error",comment:""), message: NSLocalizedString("There was an error creating your account. Please try again!", comment: ""), preferredStyle: .alert)
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

