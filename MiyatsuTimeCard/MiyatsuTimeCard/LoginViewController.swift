//
//  LoginViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/22/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import Toast_Swift

extension String {
    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
         return Data(bytes: digest).base64EncodedString()
    }
}

class LoginViewController: UIViewController {

    var shows : [String] = []
    var calendarDay: [String] = []
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var autoLoginButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkSaveId()
        checkAutoLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkSaveId(){
        let userID = UserDefaults.standard.value(forKey: "userName")
        let password = UserDefaults.standard.value(forKey: "password")
        let saveState = UserDefaults.standard.value(forKey: "saveState")
        
        // Set saved id to text field (if had)
        if userID != nil {
            idTextField.text = userID as? String
        }
        
        if password != nil{
            passwordTextField.text = password as? String
        }
        
        if saveState != nil{
            checkBoxButton.isSelected = saveState as! Bool
        }
    }
    
    func checkAutoLogin(){
        let autoLogin = UserDefaults.standard.value(forKey: "autoState")
        if autoLogin != nil{
            autoLoginButton.isSelected = autoLogin as! Bool
            
            if autoLogin as! Bool{
                loginButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func checkBoxButtonClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func LoginButtonClicked(_ sender: UIButton) {
        let parameters: Parameters = [
            "username": "\(idTextField.text ?? "")",
            "password": "\(passwordTextField.text ?? "")",
            "shift_id": "1"
        ]
        
//        let sha1Password = passwordTextField.text?.sha1()
//        print(sha1Password)
        
        // Validate and login
        Alamofire.request("http://timecard.miyatsu.vn/timecard/auth/login", method: .post, parameters: parameters).responseString{ response in
//            print("Request: \(String(describing: response.request)) ")  // original URL request
//            print("Response: \(String(describing: response.response))") // HTTP URL response
//            print("Data: \(String(describing: response.data))")     // server data
//            print("Result: \(String(describing:response.result))")   // result of response serialization
            
//            debugPrint(response)
            
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if let html = response.result.value{
                        if self.checkBoxButton.isSelected{
                            // Save id and password
                            UserDefaults.standard.set(self.idTextField.text, forKey: "userName")
                            UserDefaults.standard.set(self.passwordTextField.text, forKey: "password")
                            UserDefaults.standard.set(true, forKey: "saveState")
                            UserDefaults.standard.synchronize()
                        } else {
                            // Clear data
                            UserDefaults.standard.set("", forKey: "userName")
                            UserDefaults.standard.set("", forKey: "password")
                            UserDefaults.standard.set(false, forKey: "saveState")
                            UserDefaults.standard.synchronize()
                        }
                        
                        if self.autoLoginButton.isSelected{
                            // Set bool state for auto login
                            UserDefaults.standard.set(true, forKey: "autoState")
                            UserDefaults.standard.synchronize()
                        } else {
                            UserDefaults.standard.set(false, forKey: "autoState")
                            UserDefaults.standard.synchronize()
                        }
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBar")
                        
                        self.parseHTML(html: html)
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
    }
    
    func parseHTML(html: String) -> Void {
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            
            // Search for nodes by CSS selector
            for show in doc.css("div[id^='timecard']") {
                
                // Strip the string of surrounding whitespace.
                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Filter whitespace
                let subString = String(showString.characters.filter({ !(" ".characters.contains($0))}))
                
                // Make a set
                let set = subString.components(separatedBy: "\n").map({$0})
                
                // Show time info (if had)
                print("Working time: \(set[0])")
                print("Work start: \(set[11])")
                
                UserDefaults.standard.set(set, forKey: "sethtml")
                UserDefaults.standard.synchronize()
                
            }
            
            for show in doc.css("td[class^='calendar-day']") {
                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //                if let node = Kanna.HTML(html: show.toHTML!, encoding: String.Encoding.utf8)?.at_css("img"){
                //                    print(node["src"] ?? "Wrong")
                //                }
                
                let setToRemove: CharacterSet =
                    CharacterSet.init(charactersIn: "0123456789▲▼.:").inverted
                
                let newString = showString.components(separatedBy: setToRemove).joined(separator: "")
                let subString = String(newString.characters.filter({ !(" ".characters.contains($0))}))
                
                if subString != ""{
                    print("SubString: \(subString)")
                    calendarDay.append(subString)
                }
            }
            
            UserDefaults.standard.set(calendarDay, forKey: "calendarDay")
            UserDefaults.standard.synchronize()
        }
    }
}
