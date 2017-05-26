//
//  UserProfileViewController.swift
//  MiyatsuTimeCard
//
//  Created by miyatsu-imac on 5/26/17.
//  Copyright © 2017 miyatsu-imac. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class UserProfileViewController: UIViewController {
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userBirthdayLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    
    var set: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUserInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func loadUserInformation(){
        Alamofire.request("http://timecard.miyatsu.vn/timecard/profile").responseString{ response in
            let statuscode = response.response?.statusCode
            switch response.result
            {
            case .success(_):
                if (statuscode == 200)
                {
                    if let html = response.result.value{
                        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                            for show in doc.css("td") {
                                
                                // Strip the string of surrounding whitespace.
                                let showString = show.text!.trimmingCharacters(in: CharacterSet.newlines)
                                
                                // Filter whitespace
//                                let subString = String(showString.characters.filter({ !(" ".characters.contains($0))}))
                                self.set.append(showString)
                            }
                            
                            let imgUrl = doc.css("img").first
                            let userAvatarImgUrl = imgUrl?["src"]
                            
                            if let url = URL.init(string: userAvatarImgUrl!) {
                                    self.userAvatarImage.downloadedFrom(url: url)
                            }
                        }
                        
                        self.userNameLabel.text = self.set[0]
                        self.userEmailLabel.text = self.set[1]
                        self.userBirthdayLabel.text = self.set[2]
                        self.userDescriptionLabel.text = self.set[3]
                        
                        

                    }
                }
            case .failure(let error):
                print("Request Failed With Error:\(error)")
                self.view.makeToast("Wrong")
            }
        }

    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
