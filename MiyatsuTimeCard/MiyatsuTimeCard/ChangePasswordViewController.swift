//
//  ChangePasswordViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/26/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    @IBOutlet weak var errorInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func updateButtonClicked(_ sender: UIButton) {
        if validatePassword(){
            // Check password ok
            
        } else {
            // Check password failed
            
        }
    }
    
    func validatePassword() -> Bool{
        var errorMessage = ""
        // Check available text input
        if oldPassTextField.text == ""{
            errorMessage.append("Old password field is required.\n")
        }
        if newPassTextField.text == ""{
            errorMessage.append("New password field is required.\n")
        }
        if confirmPassTextField.text == ""{
            errorMessage.append("Confirm password field is required.")
        }
        if confirmPassTextField.text != newPassTextField.text && newPassTextField.text != ""{
            errorMessage.append("Confirm password is not the same.")
        }
        
        
        // Set text to error information label
        errorInfoLabel.text = errorMessage
        
        if errorMessage != ""{
            errorInfoLabel.isHidden = false
            return false
        } else {
            errorInfoLabel.isHidden = true
            return true
        }
    }
}
