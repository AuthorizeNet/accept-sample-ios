//
//  ViewController.swift
//  AcceptSDK
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 7/11/16.
//  Copyright © 2016 Ramamurthy, Rakesh Ramamurthy. All rights reserved.
//

import UIKit
import AcceptSDK

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}



let kClientName = "5KP3u95bQpv"
let kClientKey  = "5FcB6WrfHGS76gHW3v7btBCE3HuuBuke9Pj96Ztfn5R32G5ep42vne7MCWZtAucY"

let kAcceptSDKDemoCreditCardLength:Int = 16
let kAcceptSDKDemoCreditCardLengthPlusSpaces:Int = (kAcceptSDKDemoCreditCardLength + 3)
let kAcceptSDKDemoExpirationLength:Int = 4
let kAcceptSDKDemoExpirationMonthLength:Int = 2
let kAcceptSDKDemoExpirationYearLength:Int = 2
let kAcceptSDKDemoExpirationLengthPlusSlash:Int = kAcceptSDKDemoExpirationLength + 1
let kAcceptSDKDemoCVV2Length:Int = 4

let kAcceptSDKDemoCreditCardObscureLength:Int = (kAcceptSDKDemoCreditCardLength - 4)

let kAcceptSDKDemoSpace:String = " "
let kAcceptSDKDemoSlash:String = "/"


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cardNumberTextField:UITextField!
    @IBOutlet weak var expirationMonthTextField:UITextField!
    @IBOutlet weak var expirationYearTextField:UITextField!
    @IBOutlet weak var cardVerificationCodeTextField:UITextField!
    @IBOutlet weak var getTokenButton:UIButton!
    @IBOutlet weak var activityIndicatorAcceptSDKDemo:UIActivityIndicatorView!
    @IBOutlet weak var textViewShowResults:UITextView!
    @IBOutlet weak var headerView:UIView!

    fileprivate var cardNumber:String!
    fileprivate var cardExpirationMonth:String!
    fileprivate var cardExpirationYear:String!
    fileprivate var cardVerificationCode:String!
    fileprivate var cardNumberBuffer:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.backgroundColor = UIColor.init(red: 48.0/255.0, green: 85.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        self.setUIControlsTagValues()
        self.initializeUIControls()
        self.initializeMembers()
        
        self.updateTokenButton(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUIControlsTagValues() {
        self.cardNumberTextField.tag = 1
        self.expirationMonthTextField.tag = 2
        self.expirationYearTextField.tag = 3
        self.cardVerificationCodeTextField.tag = 4
    }
    
    func initializeUIControls() {
        self.cardNumberTextField.text = ""
        self.expirationMonthTextField.text = ""
        self.expirationYearTextField.text = ""
        self.cardVerificationCodeTextField.text = ""
        self.textChangeDelegate(self.cardNumberTextField)
        self.textChangeDelegate(self.expirationMonthTextField)
        self.textChangeDelegate(self.expirationYearTextField)
        self.textChangeDelegate(self.cardVerificationCodeTextField)
        
        self.cardNumberTextField.delegate = self
        self.expirationMonthTextField.delegate = self
        self.expirationYearTextField.delegate = self
        self.cardVerificationCodeTextField.delegate = self
    }
    
    func initializeMembers() {
        self.cardNumber = nil
        self.cardExpirationMonth = nil
        self.cardExpirationYear = nil
        self.cardVerificationCode = nil
        self.cardNumberBuffer = ""
    }

    func darkBlueColor() -> UIColor {
        let color = UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        return color 
    }
    
    @IBAction func getTokenButtonTapped(_ sender: AnyObject) {
        self.activityIndicatorAcceptSDKDemo.startAnimating()
        self.updateTokenButton(false)
        
        self.getToken()
    }

    @IBAction func backButtonButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    func updateTokenButton(_ isEnable: Bool) {
        self.getTokenButton.isEnabled = isEnable
        if isEnable {
            self.getTokenButton.backgroundColor = UIColor.init(red: 48.0/255.0, green: 85.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        } else {
            self.getTokenButton.backgroundColor = UIColor.init(red: 48.0/255.0, green: 85.0/255.0, blue: 112.0/255.0, alpha: 0.2)
        }
    }
    
    func getToken() {
        
        let handler = AcceptSDKHandler(environment: AcceptSDKEnvironment.ENV_TEST)
        
        let request = AcceptSDKRequest()
        request.merchantAuthentication.name = kClientName
        request.merchantAuthentication.clientKey = kClientKey
        
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = self.cardNumberBuffer
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = self.cardExpirationMonth
        request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = self.cardExpirationYear
        request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = self.cardVerificationCode

        handler!.getTokenWithRequest(request, successHandler: { (inResponse:AcceptSDKTokenResponse) -> () in
            DispatchQueue.main.async(execute: {
                self.updateTokenButton(true)

                self.activityIndicatorAcceptSDKDemo.stopAnimating()
                print("Token--->%@", inResponse.getOpaqueData().getDataValue())
                var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
                output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
                self.textViewShowResults.text = output
                self.textViewShowResults.textColor = UIColor.green
            })
        }) { (inError:AcceptSDKErrorResponse) -> () in
            self.activityIndicatorAcceptSDKDemo.stopAnimating()
            self.updateTokenButton(true)

            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            self.textViewShowResults.text = output
            self.textViewShowResults.textColor = UIColor.red
            print(output)
        }
    }

    func scrollTextViewToBottom(_ textView:UITextView) {
        if(textView.text.characters.count > 0 )
        {
            let bottom = NSMakeRange(textView.text.characters.count-1, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    func updateTextViewWithMessage(_ message:String) {
        if message.characters.count > 0 {
            self.textViewShowResults.text = self.textViewShowResults.text + message
            self.textViewShowResults.text = self.textViewShowResults.text + "\n"
        } else {
            self.textViewShowResults.text = self.textViewShowResults.text + "Empty Message\n"
        }
        
        self.scrollTextViewToBottom(self.textViewShowResults)
    }
    
    @IBAction func hideKeyBoard(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func formatCardNumber(_ textField:UITextField) {
        var value = String()
        
        if textField == self.cardNumberTextField {
            let length = self.cardNumberBuffer.characters.count
            
            for (i, _) in self.cardNumberBuffer.characters.enumerated() {

                // Reveal only the last character.
                if (length <= kAcceptSDKDemoCreditCardObscureLength) {
                    if (i == (length - 1)) {
                        let charIndex = self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: i)
                        let tempStr = String(self.cardNumberBuffer.characters.suffix(from: charIndex))
                        //let singleCharacter = String(tempStr.characters.first)

                        value = value + tempStr
                    } else {
                        value = value + "●"
                    }
                } else {
                    if (i < kAcceptSDKDemoCreditCardObscureLength) {
                        value = value + "●"
                    } else {
                        let charIndex = self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: i)
                        let tempStr = String(self.cardNumberBuffer.characters.suffix(from: charIndex))
                        //let singleCharacter = String(tempStr.characters.first)
                        //let singleCharacter = String(tempStr.characters.suffix(1))
                        
                        value = value + tempStr
                        break
                    }
                }
                
                //After 4 characters add a space
                if (((i + 1) % 4 == 0) && (value.characters.count < kAcceptSDKDemoCreditCardLengthPlusSpaces)) {
                    value = value + kAcceptSDKDemoSpace
                }
            }
        }
        
        textField.text = value
    }

    func isMaxLength(_ textField:UITextField) -> Bool {
        var result = false
        
        if (textField.tag == self.cardNumberTextField.tag && textField.text?.characters.count > kAcceptSDKDemoCreditCardLengthPlusSpaces)
        {
            result = true
        }
        
        if (textField == self.expirationMonthTextField && textField.text?.characters.count > kAcceptSDKDemoExpirationMonthLength)
        {
            result = true
        }
        
        if (textField == self.expirationYearTextField && textField.text?.characters.count > kAcceptSDKDemoExpirationYearLength)
        {
            result = true
        }
        if (textField == self.cardVerificationCodeTextField && textField.text?.characters.count > kAcceptSDKDemoCVV2Length)
        {
            result = true
        }
        
        return result
    }
    
    
    // MARK:
    // MARK: UITextViewDelegate delegate methods
    // MARK:
    
    func textFieldDidBeginEditing(_ textField:UITextField) {
    }
    
    func textFieldShouldBeginEditing(_ textField:UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = true
        
        switch (textField.tag)
        {
        case 1:
                if (string.characters.count > 0)
                {
                    if (self.isMaxLength(textField)) {
                        return false
                    }
                    
                    self.cardNumberBuffer = String(format: "%@%@", self.cardNumberBuffer, string)
                }
                else
                {
                    if (self.cardNumberBuffer.characters.count > 1)
                    {
                        let length = self.cardNumberBuffer.characters.count - 1
                        
            //self.cardNumberBuffer = self.cardNumberBuffer[self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: 0)...self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: length-1)]
                        
                        self.cardNumberBuffer = String(self.cardNumberBuffer[self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: 0)...self.cardNumberBuffer.index(self.cardNumberBuffer.startIndex, offsetBy: length - 1)])
                    }
                    else
                    {
                        self.cardNumberBuffer = ""
                    }
                }
                self.formatCardNumber(textField)
                return false
        case 2:

            if (string.characters.count > 0) {
                if (self.isMaxLength(textField)) {
                    return false
                }
            }

            break
        case 3:

            if (string.characters.count > 0) {
                if (self.isMaxLength(textField)) {
                    return false
                }
            }

            break
        case 4:

            if (string.characters.count > 0) {
                if (self.isMaxLength(textField)) {
                    return false
                }
            }

            break
            
        default:
            break
        }
        
        return result 
    }
    
    func validInputs() -> Bool {
        var inputsAreOKToProceed = false
        
        let validator = AcceptSDKCardFieldsValidator()
        
        if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!) && validator.validateExpirationDate(self.expirationMonthTextField.text!, inYear: self.expirationYearTextField.text!) && validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer)) {
            inputsAreOKToProceed = true
        }

        return inputsAreOKToProceed
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let validator = AcceptSDKCardFieldsValidator()

        switch (textField.tag)
        {
            
        case 1:

            self.cardNumber = self.cardNumberBuffer 
                
                let luhnResult = validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer)
                
                if ((luhnResult == false) || (textField.text?.characters.count < AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardNumberCharacterCountMin))
                {
                    self.cardNumberTextField.textColor = UIColor.red
                }
                else
                {
                    self.cardNumberTextField.textColor = self.darkBlueColor() //[UIColor greenColor] 
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)
                }
                else
                {
                    self.updateTokenButton(false)
                }

            break
        case 2:
                self.validateMonth(textField)
                if let expYear = self.expirationYearTextField.text {
                    self.validateYear(expYear)
                }

            break
        case 3:
            
            self.validateYear(textField.text!)

            break
        case 4:

            self.cardVerificationCode = textField.text 
                
                if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!))
                {
                    self.cardVerificationCodeTextField.textColor = self.darkBlueColor()
                }
                else
                {
                    self.cardVerificationCodeTextField.textColor = UIColor.red
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)
                }
                else
                {
                    self.updateTokenButton(false)
                }

            break
            
        default:
            break
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (textField == self.cardNumberTextField)
        {
            self.cardNumberBuffer = String() 
        }
        
        return true 
    }
    
    func validateYear(_ textFieldText: String) {
        
        self.cardExpirationYear = textFieldText
        let validator = AcceptSDKCardFieldsValidator()

        let newYear = Int(textFieldText)
        if ((newYear >= validator.cardExpirationYearMin())  && (newYear <= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationYearMax))
        {
            self.expirationYearTextField.textColor = self.darkBlueColor() //[UIColor greenColor]
        }
        else
        {
            self.expirationYearTextField.textColor = UIColor.red
        }
        
        if (self.expirationYearTextField.text?.characters.count == 0)
        {
            return
        }
        if (self.expirationMonthTextField.text?.characters.count == 0)
        {
            return
        }
        if (validator.validateExpirationDate(self.expirationMonthTextField.text!, inYear: self.expirationYearTextField.text!))
        {
            self.expirationMonthTextField.textColor = self.darkBlueColor()
            self.expirationYearTextField.textColor = self.darkBlueColor()
        }
        else
        {
            self.expirationMonthTextField.textColor = UIColor.red
            self.expirationYearTextField.textColor = UIColor.red
        }
        
        if (self.validInputs())
        {
            self.updateTokenButton(true)
        }
        else
        {
            self.updateTokenButton(false)
        }
    }
    
    func validateMonth(_ textField: UITextField) {
        
        self.cardExpirationMonth = textField.text
        
        if (self.expirationMonthTextField.text?.characters.count == 1)
        {
            if ((textField.text == "0") == false) {
                self.expirationMonthTextField.text = "0" + self.expirationMonthTextField.text!
            }
        }
        
        let newMonth = Int(textField.text!)
        
        if ((newMonth >= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationMonthMin)  && (newMonth <= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationMonthMax))
        {
            self.expirationMonthTextField.textColor = self.darkBlueColor() //[UIColor greenColor]
            
        }
        else
        {
            self.expirationMonthTextField.textColor = UIColor.red
        }
        
        if (self.validInputs())
        {
            self.updateTokenButton(true)
        }
        else
        {
            self.updateTokenButton(false)
        }
    }

    func textChangeDelegate(_ textField: UITextField) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: nil, using: { note in
                if (self.validInputs()) {
                    self.updateTokenButton(true)
                } else {
                    self.updateTokenButton(false)
                }
            })
    }
}

