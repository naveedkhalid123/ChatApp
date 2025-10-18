//
//  CreateAccountViewController.swift
//  ChatApp
//
//  Created by Gwinyai Nyatsoka on 21/7/2023.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit

class CreateAccountViewController: UIViewController {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signinAccountTextView: UITextView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let attributedString = NSMutableAttributedString(string: "Already have an account? Sign in here!", attributes: [.font: Font.linkLabel])
        
        attributedString.addAttribute(.link, value: "chatappcreate://createAccount", range: (attributedString.string as NSString).range(of: "Sign in here!"))
        
        signinAccountTextView.attributedText = attributedString
        signinAccountTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondary, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
        signinAccountTextView.delegate = self
        signinAccountTextView.isScrollEnabled = false
        signinAccountTextView.textAlignment = .center
        signinAccountTextView.isEditable = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else {
            presentErrorAlert(title: "Username Required", message: "Please enter a username")
            return
        }
        
        guard username.count >= 1 && username.count <= 15 else {
            presentErrorAlert(title: "Username Invalid", message: "Please enter a valid username")
            return
        }
        guard let password = passwordTextField.text else {
            presentErrorAlert(title: "Password Required", message: "Please enter a password")
            return
        }
        guard let email = emailTextField.text else {
            presentErrorAlert(title: "Email Required", message: "Please enter an email")
            return
        }
        
        showLoadingView()
        Database.database().reference().child("usernames").child(username).observeSingleEvent(of: .value) { snapshot in
            guard !snapshot.exists() else {
                self.presentErrorAlert(title: "Username in use", message: "Please try a different usernam.")
                self.removeLoadingView()
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                self.removeLoadingView()
                if let error = error {
                    print(error.localizedDescription)
                    self.presentErrorAlert(title: "Create Account Failed", message: "Something went wrong")
                    return
                }
                
                guard let result = result else {
                    self.presentErrorAlert(title: "Create Account Failed", message: "Something went wrong")
                    return
                }
                
                // Store data to realtime database
                let userId = result.user.uid
                let userData: [String: Any] = [
                    "id": userId,
                    "username": username
                ]
                Database.database().reference().child("users").child(userId).setValue(userData)
                Database.database().reference().child("usernames").child(username).setValue(userData)
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(identifier: "HomeViewController")
                let navVC = UINavigationController(rootViewController: homeVC)
                let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
                window?.rootViewController = navVC
            }
        }
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "chatappcreate" {
            performSegue(withIdentifier: "SignInSegue", sender: nil)
        }
        
        return false
    }
}
