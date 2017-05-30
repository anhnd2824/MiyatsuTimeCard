//
//  ChangePasswordViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/26/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import Toast_Swift

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
        validatePassword()
//        if errorInfoLabel.isHidden{
//            // Check password ok
//            
//            
//        } else {
//            // Check password failed
//            // Show message and do nothing
//            
//        }
    }
    
    func validatePassword(){
        var errorMessage = "\n"
        
        // Send request and get response
        let parameters: Parameters = [
            "old_password": "\(oldPassTextField.text ?? "")",
            "new_password": "\(newPassTextField.text ?? "")",
            "confirm_password": "\(confirmPassTextField.text ?? "")"
        ]
        
        Alamofire.request("http://timecard.miyatsu.vn/timecard/profile/update", method: .post, parameters: parameters).responseString{ response in
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if let html = response.result.value{
                        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                            // Check error message
//                            for error in doc.css("p[class^='error_msg']"){
//                                print("error: \(error.text ?? "")")
//                                //                                self.view.makeToast(error.text!)
//                                errorMessage.append(error.text!)
//                                errorMessage.append("\n")
//                            }
                            for _ in doc.css("div[id^='login']") {
                                // Other use your account login at another device. Did redirect to login
                                let loginView = self.presentingViewController as! LoginViewController
                                // Redirect to login view
                                self.dismiss(animated: true, completion: {
                                    loginView.displayToast("This account did login at another device.")
                                })
                                return
                            }
                            
                            for profileMsg in doc.css("div[id^='profile-msg']"){
                                print("profile message: \(profileMsg.text ?? "")")
                                errorMessage.append(profileMsg.text!)
                            }
                            
                            // Set text to error information label
                            self.errorInfoLabel.text = errorMessage
                            
                            if errorMessage != ""{
                                self.errorInfoLabel.isHidden = false
                                
                            } else {
                                self.errorInfoLabel.isHidden = true
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                 let loginView = self.presentingViewController as! LoginViewController
                self.dismiss(animated: true, completion: nil)
                loginView.displayToast("\(error.localizedDescription)")
            }
        }
        
    }
}
