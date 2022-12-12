# TicketSystem

#Developed By Louie Patrizi Jr. 
#All right reserved

Hello! This project was completely developed by myself using the Swift Programming language and Google's Firebase Firestore. I used xCode as the IDE for this project and I used the Notes app to write down a plan for developing this application as well as to write down all of my thoughts.

This project was completely self-paced and done for fun. There is still more work that has to be done for this application to be published on the App store. It is currently supporting only for iPhones and only in a portrait screen orientation.

Moving forward to explaining the application:

First there are three account types (User, Employee, Admin) adn there are five departments for tickets to be sent to (Marketing, IT, Human Resources, Operations Management, Finance). 

When initially booting the application, you are greeted with a login screen where you'd have to input the correct email address and password associated with the account. All credentials are stored in firebase firestore. 

If an account needs to be made, you can click the create account button at the bottom of the screen and you will be transferred to another page that asks for a variety of information including: first name, last name, DOB, email, account type (user, employee, admin), password, and confirm password prompt. The application will greet you with alerts if: the fields aren't all filled, if the DOB is invalid (meaning someone isn't in the correct age range to make an account), if the password and confirm password prompts dont match, if the email isn't in the right format. 

Each department as it's own department ID, which is used to map the incoming tickets to the right department as well as to assign employees to specific departments. Each department has its own collection for department employees and department tickets.

Moving forward to the Users:

Once a user signs into the application, they are brought to the user dashboard which has three buttons: to view account information, to create a new ticket, and to view old submitted tickets. When the user clicks the view account information button, they are brought to another screen that shows all their information they entered when first creating an account. They are also presented with a button that allows them to edit their information, to then be updated in the database. When editing their information, they aren't allowed to change they account type. All of the same checks that were done when creating the account are done when editing their information.  

When the user clicks the create ticket button, they are prompt with a form which asks them the department they wish to submit the ticket to, the subject of the ticket, the description of the ticket. It also shows the name of the submitter, the current date and time of the submission. Once you click the submit button, the ticket gets sent to the correct department using their ID and it also gets a randomly generated ID number for the ticket; Used to identify the ticket.

When the user clicks the view submitted tickets button, they are greeted with a tableView that shows all their previously submitted tickets with all their information and it also shows the status of the ticket; Whether it is active or complete.


Moving forward to the Employees:

They are able to see the active tickets in a tableView and they are able to see the completed tickets in a tableView. Both are separated and specific to the department they work in. In the active tickets tableView, the employee can click on a ticket and mark it as complete, which updates the status on the users end and the employees end.


Moving forward to the Admins: 

They are able to add departments to the application. They are presented with two fields to enter the name and ID of the new department. The values are checked with the existing departments to see if anything is the same, if nothing is the same, then the department is created. 

They are able to view the existing departments in a tableView and each department section shows the number of current employees working for that department, the number of active tickets for that department, the number of complete tickets for that department. 

They are also able to view all of the existing accounts for the application, disregarding the account type. It is listed in a tableView and it shows all the necessary information needed without showing any sensitive data. It also gives a count of the total number of accounts made.


Future Implementations:

- Add encryption to the password stored in the database for security reasons
- Add more features (need to come up with some)
- Add the ability to edit account information for admins and employees
- create an app icon and more visuals for the UI within application
- Allowing new departments to be automatically added to the popup menu for users when choosing department to submit new ticket. (Currently, it is hard coded and would have to be manually added in for user to see it)


Thank you for reading about my project. I hope you have a great rest of your day!

Micwi (Louie Patrizi Jr.)


