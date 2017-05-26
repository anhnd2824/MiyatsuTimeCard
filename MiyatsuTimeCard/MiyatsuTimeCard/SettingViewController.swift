//
//  SettingViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/25/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Alamofire

class SettingViewController: UIViewController {

    @IBOutlet weak var changePassButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        changePassButton.isExclusiveTouch = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "changePasswordSg"{
            _ = segue.destination as! ChangePasswordViewController
        }
        // Pass the selected object to the new view controller.
    }
    

    @IBAction func LogoutButtonClicked(_ sender: UIButton) {
        
        Alamofire.request("http://timecard.miyatsu.vn/timecard/auth/logout").responseString{ response in
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if response.result.value != nil{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
    }
}
