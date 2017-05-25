//
//  DroneViewController.swift
//  Banda
//
//  Created by Daniel Junco on 5/24/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Firebase
import AFNetworking

class DroneViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    var thumbImage: String = "https://blog.majestic.com/wp-content/uploads/2010/10/Video-Icon-crop.png"
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crearContenedor()
        
    }
    
    
    @IBAction func uploadVideo(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            print("Here's the file URL:", videoURL)
        
            if let userID = Auth.auth().currentUser?.uid {
                let randomNum = arc4random_uniform(1000)
                let fileName = "somefilename\(randomNum).mov"
                let uploadTask = Storage.storage().reference().child("userMovies").child(userID).child(fileName).putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        //GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: "Error al cargar el video")
                        print(error?.localizedDescription)
                        return
                    }
                    if let storageUrl = metadata?.downloadURL()?.absoluteString {
                        self.enviarUrl(url: storageUrl)
                        DispatchQueue.main.async {
                            
                            Database.database().reference().child("Users").child(userID).childByAutoId().setValue(["urlMovie":storageUrl,"thumbnailImage":self.thumbImage])
                        }
                        
                        print(storageUrl)
                        
                    }
                    
                })
                uploadTask.observe(.progress, handler: { (snapshot) in
                    if let completedUnitCount = snapshot.progress?.completedUnitCount{
                        self.uploadButton.isHidden = true
                        self.progressLabel.isHidden = false
                        self.progressLabel.text = String(completedUnitCount)
                    }
                })
                uploadTask.observe(.success, handler: { (snapshot) in
                    self.uploadButton.isHidden = false
                    self.progressLabel.text = "Done"
                    self.progressLabel.isHidden = true
                })
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err  {
            print(err)
        }
        return nil
    }
    
    
    func enviarUrl(url: String){
        print("Entro")
        
        let params: [String:Any] = [
            "URL": url
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers/UrlContainer/contentInstances", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
            let alertController = UIAlertController(title: "Video Registrado", message: dictionaryResponse["contentInstance"] as? String, preferredStyle: .alert)
            
            let volverAction = UIAlertAction(title: "Regresar", style: .default) { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(volverAction)
            self.present(alertController, animated: true)
        }) { (task: URLSessionDataTask?, error: Error) in
            GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: "Error en la solicitud")
        }
 
    }
    

    func crearContenedor(){
        let params: [String:Any] = [
            "container": [
                "id":"UrlContainer"
            ]
        ]
        
        manager.requestSerializer = AFJSONRequestSerializer()
        
        manager.post("/m2m/applications/DroneFit/containers", parameters: params, progress: { (progress) in
            
        }, success: { (task:URLSessionDataTask, response) in
            let dictionaryResponse: NSDictionary = response! as! NSDictionary
            print(dictionaryResponse)
            let alertController = UIAlertController(title: "Contenedor Creado", message: dictionaryResponse["contentInstance"] as? String, preferredStyle: .alert)
            
            let volverAction = UIAlertAction(title: "Regresar", style: .default) { (action: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(volverAction)
            self.present(alertController, animated: true)
        }) { (task: URLSessionDataTask?, error: Error) in
            GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: "Error en la solicitud")
        }

    }
    
    
    
    @IBAction func irAPetrone(_ sender: Any) {
        let url = NSURL(string: "itms-apps://itunes.apple.com/app/id1102340558?mt=8")
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.openURL(url as! URL)
        }
        else{
            UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
        }
    }

}
