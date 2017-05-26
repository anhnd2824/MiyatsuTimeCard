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

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{

    var shows : [String] = []
    var calendarDay: [String] = []
    var shiftData: [String] = []
    var shiftId: Int = 1
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var autoLoginButton: UIButton!
    @IBOutlet weak var chooseShiftButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var shiftPickerView: UIPickerView!
    @IBOutlet weak var shiftPickerToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        shiftData = ["08:00 ~ 17:00",
                     "06:30 ~ 15:00",
                     "14:30 ~ 23:00",
                     "14:30 ~ 23:00",
                     "06:30 ~ 23:00",
                     "14:30 ~ 07:00",
                     "22:30 ~ 15:00",
                     "07:00 ~ 16:00",
                     "14:30 ~ 23:30",
                     "22:30 ~ 07:30",
                     "09:50 ~ 18:50",
                     "11:50 ~ 20:50",
                     "08:50 ~ 17:50",
                     "07:30 ~ 16:30",
                     "08:30 ~ 17:30",
                     "03:50 ~ 11:50",
                     "11:50 ~ 19:50",
                     "19:50 ~ 03:50"]
        shiftPickerView.delegate = self
        shiftPickerView.dataSource = self
        
        checkSaveId()
        checkAutoLogin()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePickerView), name: NSNotification.Name(rawValue: "Hide"), object: nil)
        
        // toggle "tap to dismiss" functionality
        ToastManager.shared.tapToDismissEnabled = true
        
        // toggle queueing behavior
        ToastManager.shared.queueEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PickerView
    @objc func hidePickerView() {
        shiftPickerView.isHidden = true
        shiftPickerToolbar.isHidden = true
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return shiftData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shiftData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        shiftId = row+1
        chooseShiftButton.setTitle(shiftData[row], for: .normal)
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
        if sender == autoLoginButton{
            sender.isSelected = !sender.isSelected
            if sender.isSelected{
                checkBoxButton.isSelected = true
            }
        } else {
            if autoLoginButton.isSelected{
                checkBoxButton.isSelected = true
            } else {
                sender.isSelected = !sender.isSelected
            }
        }
    }
    
    @IBAction func chooseShiftButtonClicked(_ sender: UIButton) {
        shiftPickerView.isHidden = false
        shiftPickerToolbar.isHidden = false
    }
    
    @IBAction func doneButtonClicked(_ sender: UIBarButtonItem) {
        shiftPickerView.isHidden = true
        shiftPickerToolbar.isHidden = true
    }
    
    @IBAction func LoginButtonClicked(_ sender: UIButton) {
        let parameters: Parameters = [
            "username": "\(idTextField.text ?? "")",
            "password": "\(passwordTextField.text ?? "")",
            "shift_id": "\(shiftId)"
        ]
        
//        let sha1Password = passwordTextField.text?.sha1()
//        print(sha1Password)
        
        // Validate and login
        Alamofire.request("http://timecard.miyatsu.vn/timecard/auth/login", method: .post, parameters: parameters).responseString{ response in
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
                            
                            // Clear text field
                            self.idTextField.text = ""
                            self.passwordTextField.text = ""
                        }
                        
                        if self.autoLoginButton.isSelected{
                            // Set bool state for auto login
                            UserDefaults.standard.set(true, forKey: "autoState")
                            UserDefaults.standard.synchronize()
                        } else {
                            UserDefaults.standard.set(false, forKey: "autoState")
                            UserDefaults.standard.synchronize()
                        }
                        
                        self.parseHTML(html: html)
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
        
        // Hide picker view
        shiftPickerView.isHidden = true
        shiftPickerToolbar.isHidden = true
        
        // Hide keyboard
        idTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    
    func displayToast(_ message: String){
        self.view.makeToast(message)
    }
    
    func parseHTML(html: String) -> Void {
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            // Check error message
            for error in doc.css("p[class^='error_msg']"){
                print("error: \(error.text ?? "")")
                self.view.makeToast(error.text!)
                return
            }
            
            // Search for nodes by CSS selector
            for show in doc.css("div[id^='timecard']") {
                
                // Strip the string of surrounding whitespace.
                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Filter whitespace
                let subString = String(showString.characters.filter({ !(" ".characters.contains($0))}))
                
                // Make a set
                let set = subString.components(separatedBy: "\n").map({$0})
                
                UserDefaults.standard.set(set, forKey: "sethtml")
                UserDefaults.standard.synchronize()
                
            }
            
            for show in doc.css("td[class^='calendar-day']") {
                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
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
            
            // Redirect to my timecard
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBar")
            
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
}
