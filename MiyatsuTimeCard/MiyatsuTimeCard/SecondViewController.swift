//
//  SecondViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/22/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import Toast_Swift

class WorkDate{
    var day : String
    var date : String
    var workShift : String
    var workStartTime : String
    var leaveOutTime : String
    var leaveBackTime : String
    var workEndTime : String
    
    init(day: String, date: String, workShift: String, workStartTime: String, leaveOutTime: String, leaveBackTime: String, workEndTime: String) {
        self.day = day
        self.date = date
        self.workShift = workShift
        self.workStartTime = workStartTime
        self.leaveOutTime = leaveOutTime
        self.leaveBackTime = leaveBackTime
        self.workEndTime = workEndTime
    }
}

class workDateTableViewCell: UITableViewCell{
    
    @IBOutlet weak var dateWorkLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var lateLabel: UILabel!
    @IBOutlet weak var earlyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class DetailViewController: UIViewController{
    
    @IBOutlet weak var detailWorkStartTime: UILabel!
    @IBOutlet weak var detailLeaveOutTime: UILabel!
    @IBOutlet weak var detailLeaveBackTime: UILabel!
    @IBOutlet weak var detailWorkEndTime: UILabel!
    
    var detailDayWork: WorkDate?
    // Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let aDetailDayWork = detailDayWork{
            detailWorkStartTime.text = aDetailDayWork.workStartTime
            detailLeaveOutTime.text = aDetailDayWork.leaveOutTime
            detailLeaveBackTime.text = aDetailDayWork.leaveBackTime
            detailWorkEndTime.text = aDetailDayWork.workEndTime
            
            // Set text time color
            if !checkTime(workTime: aDetailDayWork.workShift, workRealTime: aDetailDayWork.workStartTime, checkLate: true){
                
                detailWorkStartTime.textColor = UIColor.init(red: 230/255, green: 51/255, blue: 41/255, alpha: 1)
            }
            if !checkTime(workTime: aDetailDayWork.workShift, workRealTime: aDetailDayWork.workEndTime, checkLate: false){
                
                detailWorkEndTime.textColor = UIColor.init(red: 15/255, green: 50/255, blue: 243/255, alpha: 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate {
    
    @IBOutlet weak var workDiaryTableView: UITableView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    var set : [String] = []
    var diary : [WorkDate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        
        loadWorkDiary()
        let customDatePickerView = MonthYearPickerView()
        
        timeTextField.inputView = customDatePickerView
        customDatePickerView.onDateSelected = { (month: Int, year: Int) in
            let string = String(format: "%02d/%d", month, year)
            self.timeTextField.text = string
            NSLog(string) // should show something like 05/2015
            //            self.timeTextField.endEditing(true)
        }
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SecondViewController.donePicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        timeTextField.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        // Check
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewWorkDiaryButonClicked(_ sender: UIButton) {
        let inputTime = timeTextField.text?.components(separatedBy: "/")
        let parameters: Parameters = [
            "name_id": "\(userIdTextField.text ?? "")",
            "work_month": "\(inputTime![0])",
            "work_year": "\(inputTime![1])"
        ]
        
        // Validate and login
        Alamofire.request("http://timecard.miyatsu.vn/timecard/diary/view", method: .post, parameters: parameters).responseString{ response in
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if let html = response.result.value{
                        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                            for _ in doc.css("div[id^='login']") {
                                // Other use your account login at another device. Did redirect to login
                                let loginView = self.presentingViewController as! LoginViewController
                                // Redirect to login view
                                self.dismiss(animated: true, completion: {
                                    loginView.displayToast("This account was logined at another device.")
                                })
                                
                            }
                            
                            // Reset data
                            self.set.removeAll()
                            self.diary.removeAll()
                            
                            for show in doc.css("td") {
                                
                                // Strip the string of surrounding whitespace.
                                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                
                                // Filter whitespace
                                let subString = String(showString.characters.filter({ !(" ".characters.contains($0))}))
                                self.set.append(subString)
                            }
                            
                            for index in stride(from: 0, to: doc.css("td").count, by: 7){
                                let aDayWork = WorkDate.init(day: self.set[index], date: self.set[index+1], workShift: self.set[index+2],
                                                             workStartTime: self.set[index+3], leaveOutTime: self.set[index+4], leaveBackTime: self.set[index+5], workEndTime: self.set[index+6])
                                
                                self.diary.append(aDayWork)
                            }
                        }
                        
                        self.workDiaryTableView.reloadData()
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
    
    func loadWorkDiary(){
        Alamofire.request("http://timecard.miyatsu.vn/timecard/diary").responseString{ response in
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if let html = response.result.value{
                        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                            for _ in doc.css("div[id^='login']") {
                                // Other use your account login at another device. Did redirect to login
                                let loginView = self.presentingViewController as! LoginViewController
                                // Redirect to login view
                                self.dismiss(animated: true, completion: {
                                    loginView.displayToast("This account was logined at another device.")
                                })
                                
                            }
                            for show in doc.css("td") {
                                
                                // Strip the string of surrounding whitespace.
                                let showString = show.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                
                                // Filter whitespace
                                let subString = String(showString.characters.filter({ !(" ".characters.contains($0))}))
                                self.set.append(subString)
                            }
                            
                            for index in stride(from: 0, to: doc.css("td").count, by: 7){
                                let aDayWork = WorkDate.init(day: self.set[index], date: self.set[index+1], workShift: self.set[index+2],
                                                             workStartTime: self.set[index+3], leaveOutTime: self.set[index+4], leaveBackTime: self.set[index+5], workEndTime: self.set[index+6])
                                
                                self.diary.append(aDayWork)
                            }
                        }
                        
                        self.workDiaryTableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if( segue.identifier == "showDayWorkDetail" ){
            let detailDayWork = diary[workDiaryTableView.indexPathsForSelectedRows![0].row]
            let detailVC = segue.destination as! DetailViewController
            detailVC.detailDayWork = detailDayWork
        }
    }
    
    // MARK: - Preview view
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?{
        guard let indexPath = workDiaryTableView?.indexPathForRow(at: location) else { return nil }
        
        guard let cell = workDiaryTableView?.cellForRow(at: (indexPath)) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: ("DetailViewController")) as? DetailViewController else { return nil }
        
        let detailDayWork = diary[indexPath.row]
        detailVC.detailDayWork = detailDayWork
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController){
        //        viewControllerToCommit.navigationController?.isNavigationBarHidden = false
        show(viewControllerToCommit, sender: self)
    }
    
    
    // MARK: - Table view
    // Only one section in the table view
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Rows is equal to the number of Quotes defined above
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Our custom cell so we can access the quote text and author
        let cell = tableView.dequeueReusableCell(withIdentifier: "workDateTableViewCell", for: indexPath) as! workDateTableViewCell
        
        let row = indexPath.row
        // Set the labels in the custom cell
        cell.dateWorkLabel.text = diary[row].day
        cell.weekDayLabel.text = diary[row].date
        cell.workTimeLabel.text = diary[row].workShift
        if checkTime(workTime: diary[row].workShift, workRealTime: diary[row].workStartTime, checkLate: true){
            cell.lateLabel.text = ""
        } else {
            cell.lateLabel.text = "▲"
        }
        if checkTime(workTime: diary[row].workShift, workRealTime: diary[row].workEndTime, checkLate: false){
            cell.earlyLabel.text = ""
        } else {
            cell.earlyLabel.text = "▼"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Picker view
    func donePicker(){
        timeTextField.endEditing(true)
    }
}

// MARK: - Define custom func
func checkTime(workTime: String, workRealTime: String, checkLate: Bool) -> Bool{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    // checkLate: true -> check late; false -> check early
    if workTime != ""{
        if workRealTime != ""{
            let index = workTime.index(workTime.startIndex, offsetBy:5)
            let workTimeParse = dateFormatter.date(from: workTime.substring(to: index))
            let workStartParse = dateFormatter.date(from: workRealTime.substring(to: index))
            
            if workStartParse! > workTimeParse!{
                if checkLate{
                    // you're come late
                    return false
                } else {
                    return true
                }
            } else if workStartParse! < workTimeParse!{
                if checkLate{
                    return true
                } else {
                    // you're leave early
                    return false
                }
            }
            
            // in case same hour and minute, need to check second, implement later
            // you're ok
            return true
        }
        else{
            return true
        }
    } else {
        return true
    }
}


