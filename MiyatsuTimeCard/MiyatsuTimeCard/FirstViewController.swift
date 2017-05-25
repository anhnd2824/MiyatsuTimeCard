//
//  FirstViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/22/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Kanna
import JTAppleCalendar
import Alamofire

public extension String {
    func stringByReplacingFirstOccurrenceOfString(target: String, withString replaceString: String) -> String {
        if let range = self.range(of: target){
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
    
}

class FirstViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var workingTimeLabel: UILabel!
    @IBOutlet weak var submitWorkStartButton: UIButton!
    @IBOutlet weak var submitWorkEndButton: UIButton!
    @IBOutlet weak var submitLeaveOutButton: UIButton!
    @IBOutlet weak var submitLeaveBackButton: UIButton!
    @IBOutlet weak var workEndTimeLabel: UILabel!
    @IBOutlet weak var workStartTimeLabel: UILabel!
    
    var set: [String] = []
    var calendarDay: [String] = []
    var timeStart: [String] = []
    var timeEnd: [String] = []
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupSubmitButton()
        setupCalendarView()
        setupCalendarDay()
    }
    
    func setupCalendarView(){
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        let dispatchTime = DispatchTime.now() + 0.01
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            // your function here
            self.calendarView.scrollToDate(Date())
            self.calendarView.selectDates([Date()])
        }
    }
    
    func handleCurrentViewDisplaying(date: Date?, cellState: CellState){
        if cellState.isSelected{
            if cellState.dateBelongsTo != .thisMonth{
                calendarView.scrollToDate(date!)
            }
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if cellState.isSelected{
            validCell.dateLabel.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = UIColor.black
            } else {
                validCell.dateLabel.textColor = UIColor.gray
            }
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if cellState.isSelected{
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
        
    }
    
    func setupSubmitButton(){
        set = UserDefaults.standard.value(forKey: "sethtml") as! [String]
        workingTimeLabel.text = set[0] != "" ? set[0].replacingOccurrences(of: "WORKINGTIME~", with: "") : ""
        if set[11] != "Submit"{
            submitWorkStartButton.setTitle(set[11], for: .normal)
            if (submitWorkStartButton.titleLabel?.text?.contains("▲"))!{
                submitWorkStartButton.setTitleColor(UIColor.init(red: 230/255, green: 51/255, blue: 41/255, alpha: 1), for: .normal)
            } else {
                submitWorkStartButton.setTitleColor(UIColor.black, for: .normal)
            }
            submitWorkStartButton.isUserInteractionEnabled = false
        }
        if set[13] != "Submit"{
            submitLeaveOutButton.setTitle(set[13], for: .normal)
            submitLeaveOutButton.setTitleColor(UIColor.black, for: .normal)
            submitLeaveOutButton.isUserInteractionEnabled = false
        }
        if set[15] != "Submit"{
            submitLeaveBackButton.setTitle(set[15], for: .normal)
            submitLeaveBackButton.setTitleColor(UIColor.black, for: .normal)
            submitLeaveBackButton.isUserInteractionEnabled = false
        }
        if set[17] != "Submit"{
            submitWorkEndButton.setTitle(set[17], for: .normal)
            if (submitWorkEndButton.titleLabel?.text?.contains("▼"))!{
                submitWorkEndButton.setTitleColor(UIColor.init(red: 15/255, green: 50/255, blue: 243/255, alpha: 1), for: .normal)
            } else {
                submitWorkEndButton.setTitleColor(UIColor.black, for: .normal)
            }
            submitWorkEndButton.isUserInteractionEnabled = false
        }
    }
    
    func setupCalendarDay(){
        calendarDay = UserDefaults.standard.value(forKey: "calendarDay") as! [String]
//        print("calendarDay: \(calendarDay)")
        for aCalendarDay in calendarDay{
            getTimeFromACalendarDay(aCalendarDay: aCalendarDay, index:calendarDay.index(of: aCalendarDay)! + 1)
        }
    }
    
    func parseStringToGetTime(day: String, date: String){
        var indexes: [String.Index] = []
        let timeString = day.stringByReplacingFirstOccurrenceOfString(target: date, withString: "")
        var searchRange = timeString.startIndex..<timeString.endIndex

        while let range = timeString.range(of: ":", options: .caseInsensitive, range: searchRange) {
            searchRange = range.upperBound..<searchRange.upperBound
            indexes.append(range.lowerBound)
        }
        
        print("indexes: \(indexes)")
        print("timeString: \(timeString)")
        if timeString.characters.count > 8{
//            if timeString.contains("▲"){
                let index = timeString.index(indexes[2], offsetBy:-2)
                let startTime = timeString.substring(to: index)
                print("Start time: \(startTime)")
                timeStart.append(startTime)
                let endTime = timeString.substring(from: index)
                print("End time: \(endTime)")
                timeEnd.append(endTime)
//            } else {
//                let index = timeString.index(timeString.startIndex, offsetBy: 8)
//                let startTime = timeString.substring(to: index)
//                print("Start time: \(startTime)")
//                timeStart.append(startTime)
//                let endTime = timeString.substring(from: index)
//                print("End time: \(endTime)")
//                timeEnd.append(endTime)
//            }
        } else if timeString.characters.count > 0{
                timeStart.append(timeString)
                timeEnd.append("")
        } else {
            timeStart.append("")
            timeEnd.append("")
        }
    }
    
    func getTimeFromACalendarDay(aCalendarDay: String, index: Int){
        switch index {
        case 1:
            parseStringToGetTime(day: aCalendarDay, date: "1")
        case 2:
             parseStringToGetTime(day: aCalendarDay, date: "2")
        case 3:
             parseStringToGetTime(day: aCalendarDay, date: "3")
        case 4:
             parseStringToGetTime(day: aCalendarDay, date: "4")
        case 5:
             parseStringToGetTime(day: aCalendarDay, date: "5")
        case 6:
             parseStringToGetTime(day: aCalendarDay, date: "6")
        case 7:
             parseStringToGetTime(day: aCalendarDay, date: "7")
        case 8:
             parseStringToGetTime(day: aCalendarDay, date: "8")
        case 9:
             parseStringToGetTime(day: aCalendarDay, date: "9")
        case 10:
             parseStringToGetTime(day: aCalendarDay, date: "10")
        case 11:
             parseStringToGetTime(day: aCalendarDay, date: "11")
        case 12:
             parseStringToGetTime(day: aCalendarDay, date: "12")
        case 13:
             parseStringToGetTime(day: aCalendarDay, date: "13")
        case 14:
             parseStringToGetTime(day: aCalendarDay, date: "14")
        case 15:
             parseStringToGetTime(day: aCalendarDay, date: "15")
        case 16:
             parseStringToGetTime(day: aCalendarDay, date: "16")
        case 17:
             parseStringToGetTime(day: aCalendarDay, date: "17")
        case 18:
             parseStringToGetTime(day: aCalendarDay, date: "18")
        case 19:
             parseStringToGetTime(day: aCalendarDay, date: "19")
        case 20:
             parseStringToGetTime(day: aCalendarDay, date: "20")
        case 21:
             parseStringToGetTime(day: aCalendarDay, date: "21")
        case 22:
             parseStringToGetTime(day: aCalendarDay, date: "22")
        case 23:
             parseStringToGetTime(day: aCalendarDay, date: "23")
        case 24:
             parseStringToGetTime(day: aCalendarDay, date: "24")
        case 25:
             parseStringToGetTime(day: aCalendarDay, date: "25")
        case 26:
             parseStringToGetTime(day: aCalendarDay, date: "26")
        case 27:
             parseStringToGetTime(day: aCalendarDay, date: "27")
        case 28:
             parseStringToGetTime(day: aCalendarDay, date: "28")
        case 29:
             parseStringToGetTime(day: aCalendarDay, date: "29")
        case 30:
             parseStringToGetTime(day: aCalendarDay, date: "30")
        case 31:
             parseStringToGetTime(day: aCalendarDay, date: "31")
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func workStartSubmitButtonClicked(_ sender: UIButton) {
        // Submit and reload data
        Alamofire.request("http://timecard.miyatsu.vn/timecard/check?type=1").responseString{ response in
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
                        // Reset data
                        self.set.removeAll()
                        self.calendarDay.removeAll()
                        self.timeStart.removeAll()
                        self.timeEnd.removeAll()
                        
                        self.parseHTML(html: html)
                        
                        self.setupSubmitButton()
                        self.setupCalendarDay()
                        self.calendarView.selectDates([Date()])
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
    }
    
    @IBAction func leaveOutButtonClicked(_ sender: UIButton) {
        // Submit and reload data
        Alamofire.request("http://timecard.miyatsu.vn/timecard/check?type=2").responseString{ response in
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
                        self.set.removeAll()
                        self.calendarDay.removeAll()
                        self.timeStart.removeAll()
                        self.timeEnd.removeAll()
                        
                        self.parseHTML(html: html)
                        
                        self.setupSubmitButton()
                        self.setupCalendarDay()
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
    }
    
    @IBAction func leaveBackButtonClicked(_ sender: UIButton) {
        // Submit and reload data
        Alamofire.request("http://timecard.miyatsu.vn/timecard/check?type=3").responseString{ response in
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
                        // Reset data
                        self.set.removeAll()
                        self.calendarDay.removeAll()
                        self.timeStart.removeAll()
                        self.timeEnd.removeAll()
                        
                        self.parseHTML(html: html)
                        
                        self.setupSubmitButton()
                        self.setupCalendarDay()
                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }
    }
    
    @IBAction func workEndSubmitButtonClicked(_ sender: UIButton) {
        // Submit and reload data
        Alamofire.request("http://timecard.miyatsu.vn/timecard/check?type=4").responseString{ response in
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
                        // Reset data
                        self.set.removeAll()
                        self.calendarDay.removeAll()
                        self.timeStart.removeAll()
                        self.timeEnd.removeAll()
                        
                        self.parseHTML(html: html)
                        
                        self.setupSubmitButton()
                        self.setupCalendarDay()
                        self.calendarView.selectDates([Date()])
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

extension FirstViewController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

extension FirstViewController: JTAppleCalendarViewDelegate{
    // Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell{
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        if cellState.dateBelongsTo == .thisMonth{
            cell.dateLabel.text = cellState.text
            handleCellTextColor(view: cell, cellState: cellState)
            handleCellSelected(view: cell, cellState: cellState)
        } else {
            cell.dateLabel.text = ""
        }
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState){
        if cellState.dateBelongsTo == .thisMonth{
            handleCellTextColor(view: cell, cellState: cellState)
            handleCellSelected(view: cell, cellState: cellState)
            //        handleCurrentViewDisplaying(date: date, cellState: cellState)
            let day = Calendar.current.component(.day, from: date)
            workStartTimeLabel.text = timeStart[day - 1]
            if (workStartTimeLabel.text?.contains("▲"))!{
                workStartTimeLabel.textColor = UIColor.init(red: 230/255, green: 51/255, blue: 41/255, alpha: 1)
            } else {
                workStartTimeLabel.textColor = UIColor.black
            }
            workEndTimeLabel.text = timeEnd[day - 1]
            if (workEndTimeLabel.text?.contains("▼"))!{
                workEndTimeLabel.textColor = UIColor.init(red: 15/255, green: 50/255, blue: 243/255, alpha: 1)
            } else {
                workEndTimeLabel.textColor = UIColor.black
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState){
        if cellState.dateBelongsTo == .thisMonth{
            handleCellTextColor(view: cell, cellState: cellState)
            handleCellSelected(view: cell, cellState: cellState)
        }
    }
}

