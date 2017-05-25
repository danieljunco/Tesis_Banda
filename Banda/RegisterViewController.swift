//
//  RegisterViewController.swift
//  Dron e
//
//  Created by Daniel Junco on 4/7/17.
//  Copyright © 2017 Daniel Junco. All rights reserved.
//

import UIKit
import FirebaseAuth
import AFNetworking

class RegisterViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var perfilPickerText: DesignableTextField!
    @IBOutlet weak var signInSelector: UISegmentedControl!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    @IBOutlet weak var button: CustomButton!
    var isSign: Bool = true
    
    let perfilPicker = UIPickerView()
    
    let perfil = ["Entrenador","Deportista"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customPicker()
        
        self.navigationItem.setHidesBackButton(false, animated: true)
        
        self.perfilPicker.delegate = self
        self.perfilPicker.dataSource = self
        
        self.perfilPickerText.delegate = self
        
    }
    
    @IBAction func signInSelectorChanged(_ sender: Any) {
        isSign = !isSign
        if isSign {
            button.setTitle("Iniciar", for: .normal)
        }
        else{
            button.setTitle("Registrar", for: .normal)
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        
        //performSegue(withIdentifier: "GoToDashBoard", sender: self)
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            
            
            if isSign {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if let u = user {
                        print("Usuario se registro \(u)")
                        print("Entra")
                        let params: [String:Any] = [
                            "application": [
                                "appId":"DroneFit"
                            ]
                        ]
                        
                        manager.requestSerializer = AFJSONRequestSerializer()
                        
                        manager.post("/m2m/applications", parameters: params, progress: { (progress) in
                            
                        }, success: { (task:URLSessionDataTask, response) in
                            let dictionaryResponse: NSDictionary = response! as! NSDictionary
                            print(dictionaryResponse)
                        }) { (task: URLSessionDataTask?, error: Error) in
                            print("Error")
                        }
                        self.performSegue(withIdentifier: "GoToDashBoard", sender: self)
                    }else{
                        GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: (error?.localizedDescription)!)
                    }
                })
            }else {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if let u = user {
                        print("Usuario se registro \(u)")
                        print("Entra")
                        let params: [String:Any] = [
                            "application": [
                                "appId":"DroneFit"
                            ]
                        ]
                        
                        manager.requestSerializer = AFJSONRequestSerializer()
                        
                        manager.post("/m2m/applications", parameters: params, progress: { (progress) in
                            
                        }, success: { (task:URLSessionDataTask, response) in
                            let dictionaryResponse: NSDictionary = response! as! NSDictionary
                            print(dictionaryResponse)
                        }) { (task: URLSessionDataTask?, error: Error) in
                            print("Error")
                        }
                        self.performSegue(withIdentifier: "GoToDashBoard", sender: self)
                    }else {
                        GlobalVariables.sharedInstance.displayAlertMessage(view: self, messageToDisplay: (error?.localizedDescription)!)
                    }
                })
            }
        }
    }
    
    func customPicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        perfilPickerText.inputAccessoryView = toolbar
        perfilPickerText.inputView = perfilPicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == perfilPicker {
            return perfil[row]
        }
        else{
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == perfilPicker {
            self.perfilPickerText.text = perfil[0]
            return perfil.count
        }
        else{
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == perfilPicker {
            perfilPickerText.text = perfil[row]
        }
    }
    
    func donePressed(){
        self.view.endEditing(true)
    }
    

        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return(true)
    }
    
}
