//
//  SearchViewController.swift
//  ARt
//
//  Created by Edward on 9/14/19.
//  Copyright © 2019 Edward. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var info: [String: String]? = Optional(["name":"Edward", "description": "cnwkecnnwckjwncjk", "titles" : "cwncnwjnekwjc\ncnwkcjewncjkw\ncnewnewjcnkjwe\n", "birthplace": "cewew"])
    
    var canGoBack = false
    
    var delegate: ARController?
    
    var filemanager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getArtistInfo(_ sender: Any) {
        canGoBack = true
        UIView.animate(withDuration: 0.05,
                       animations: {
                        self.sendButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.05) {
                            self.sendButton.transform = CGAffineTransform.identity
                        }
        })
        
        deleteImages()
        
        getInfo(textField.text!, "http://128.237.211.240:5000/process_artist")
        
//        getArtInfo("http://128.237.211.240:5000/pic1") {
//            self.updateImages()
//        }
//        getArtInfo("http://128.237.211.240:5000/pic2") {
//            self.updateImages()
//        }
//        getArtInfo("http://128.237.211.240:5000/pic3") {
//            self.updateImages()
//        }
//        getArtInfo("http://128.237.211.240:5000/pic4") {
//            self.updateImages()
//        }
//        getArtInfo("http://128.237.211.240:5000/pic5") {
//            self.updateImages()
//        }
//        getArtInfo("http://128.237.211.240:5000/pic6") {
//            self.updateImages()
//        }
        
        self.delegate?.changeName(name: info!["name"]!)
        self.delegate?.changeDescript(des: info!["description"]!)
        self.delegate?.changeArtist(art: info!["titles"]!)
        self.delegate?.changeBirthplace(place: info!["birthplace"]!)
        
        if canGoBack {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func getInfo(_ name: String, _ url: String) {
        let parameters = [
            "artist" : name
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                if let resp = response.result.value {
                    self.info = resp as? [String:String]
                    print(self.info!)
                }
                break
            case .failure(let error):
                self.canGoBack = false
                print(error)
            }
        }
    }
    
    func getArtInfo(_ url: String, completion: @escaping () -> Void) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(url, method: .post, to: destination).validate(contentType: ["image/jpg"])
            .responseData { response in
                switch response.result {
                case .success:
                    print(response.result)
                    completion()
                    break
                case .failure(let error):
                    print(error)
                    self.canGoBack = false
                    break
                }
        }
    }
    
    func deleteImages() {
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try filemanager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            if !fileURLs.isEmpty {
                for fileurl in fileURLs {
                    try filemanager.removeItem(at: fileurl)
                }
            }
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    func updateImages() {
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try filemanager.contentsOfDirectory(at: documentsURL,
                                                               includingPropertiesForKeys: nil)
            var idx = 0
            for fileurl in fileURLs {
                print(idx, fileurl)
                let imageData = try Data(contentsOf: fileurl)
                if let image = UIImage(data: imageData) {
                    (delegate!.imgs[idx])!.firstMaterial?.diffuse.contents = image
                }
                idx += 1
            }
            
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        canGoBack = true
    }
    
    @IBAction func goBack(_ sender: Any) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        self.backButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.05) {
                            self.backButton.transform = CGAffineTransform.identity
                        }
        })
//        if canGoBack {
            self.dismiss(animated: false, completion: nil)
//        }
        
    }

}
