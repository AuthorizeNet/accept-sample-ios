//
//  ViewController.swift
//  AcceptSDK
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 7/11/16.
//  Copyright © 2016 Ramamurthy, Rakesh Ramamurthy. All rights reserved.
//

import UIKit
import AuthorizeNetAccept


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


class ViewController: UIViewController {
    
    @IBOutlet weak var cardNumberTextField:UITextField!
    @IBOutlet weak var expirationMonthTextField:UITextField!
    @IBOutlet weak var expirationYearTextField:UITextField!
    @IBOutlet weak var cardVerificationCodeTextField:UITextField!
    @IBOutlet weak var getTokenButton:UIButton!
    @IBOutlet weak var activityIndicatorAcceptSDKDemo:UIActivityIndicatorView!
    @IBOutlet weak var textViewShowResults:UITextView!
    @IBOutlet weak var headerView:UIView!

    private var cardNumber:String!
    private var cardExpirationMonth:String!
    private var cardExpirationYear:String!
    private var cardVerificationCode:String!
    private var cardNumberBuffer:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.backgroundColor = UIColor(colorLiteralRed: 48/255, green: 85/255, blue: 112/255, alpha: 1)

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
    }
    
    func initializeMembers() {
        self.cardNumber = nil
        self.cardExpirationMonth = nil
        self.cardExpirationYear = nil
        self.cardVerificationCode = nil
        self.cardNumberBuffer = ""
    }

    func darkBlueColor() -> UIColor {
        let color = UIColor(colorLiteralRed: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        
        return color;
    }
    
    @IBAction func getTokenButtonTapped(sender: AnyObject) {
        self.activityIndicatorAcceptSDKDemo.startAnimating()
        self.updateTokenButton(false)
        
        self.getToken()
    }

    func updateTokenButton(isEnable: Bool) {
        self.getTokenButton.enabled = isEnable
        if isEnable {
            self.getTokenButton.backgroundColor = UIColor(colorLiteralRed: 48/255, green: 85/255, blue: 112/255, alpha: 1)
        } else {
            self.getTokenButton.backgroundColor = UIColor(colorLiteralRed: 48/255, green: 85/255, blue: 112/255, alpha: 0.2)
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
            dispatch_async(dispatch_get_main_queue(),{
                self.updateTokenButton(true)

                self.activityIndicatorAcceptSDKDemo.stopAnimating()
                print("Token--->%@", inResponse.getOpaqueData().getDataValue())
                var output = String(format: "Response: %@\nData Value: %@ \nDescription: %@", inResponse.getMessages().getResultCode(), inResponse.getOpaqueData().getDataValue(), inResponse.getOpaqueData().getDataDescriptor())
                output = output + String(format: "\nMessage Code: %@\nMessage Text: %@", inResponse.getMessages().getMessages()[0].getCode(), inResponse.getMessages().getMessages()[0].getText())
                self.textViewShowResults.text = output
                self.textViewShowResults.textColor = UIColor.greenColor()
            })
        }) { (inError:AcceptSDKErrorResponse) -> () in
            self.activityIndicatorAcceptSDKDemo.stopAnimating()
            self.updateTokenButton(true)

            let output = String(format: "Response:  %@\nError code: %@\nError text:   %@", inError.getMessages().getResultCode(), inError.getMessages().getMessages()[0].getCode(), inError.getMessages().getMessages()[0].getText())
            self.textViewShowResults.text = output
            self.textViewShowResults.textColor = UIColor.redColor()
            print(output)
        }
    }

    func scrollTextViewToBottom(textView:UITextView) {
        if(textView.text.characters.count > 0 )
        {
            let bottom = NSMakeRange(textView.text.characters.count-1, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    func updateTextViewWithMessage(message:String) {
        if message.characters.count > 0 {
            self.textViewShowResults.text = self.textViewShowResults.text.stringByAppendingString(message)
            self.textViewShowResults.text = self.textViewShowResults.text.stringByAppendingString("\n")
        } else {
            self.textViewShowResults.text = self.textViewShowResults.text.stringByAppendingString("Empty Message\n")
        }
        
        self.scrollTextViewToBottom(self.textViewShowResults)
    }
    
    @IBAction func hideKeyBoard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func formatCardNumber(textField:UITextField) {
        var value = String()
        
        if textField == self.cardNumberTextField {
            let length = self.cardNumberBuffer.characters.count
            
            for (i, _) in self.cardNumberBuffer.characters.enumerate() {

                // Reveal only the last character.
                if (length <= kAcceptSDKDemoCreditCardObscureLength) {
                    if (i == (length - 1)) {
                        let charIndex = self.cardNumberBuffer.startIndex.advancedBy(i)
                        let tempStr = String(self.cardNumberBuffer.characters.suffixFrom(charIndex))
                        //let singleCharacter = String(tempStr.characters.first)

                        value = value.stringByAppendingString(tempStr)
                    } else {
                        value = value.stringByAppendingString("●")
                    }
                } else {
                    if (i < kAcceptSDKDemoCreditCardObscureLength) {
                        value = value.stringByAppendingString("●")
                    } else {
                        let charIndex = self.cardNumberBuffer.startIndex.advancedBy(i)
                        let tempStr = String(self.cardNumberBuffer.characters.suffixFrom(charIndex))
                        //let singleCharacter = String(tempStr.characters.first)
                        //let singleCharacter = String(tempStr.characters.suffix(1))
                        
                        value = value.stringByAppendingString(tempStr)
                        break
                    }
                }
                
                //After 4 characters add a space
                if (((i + 1) % 4 == 0) && (value.characters.count < kAcceptSDKDemoCreditCardLengthPlusSpaces)) {
                    value = value.stringByAppendingString(kAcceptSDKDemoSpace)
                }
            }
        }
        
        textField.text = value
    }

    func isMaxLength(textField:UITextField) -> Bool {
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
    
    func textFieldDidBeginEditing(textField:UITextField) {
    }
    
    func textFieldShouldBeginEditing(textField:UITextField) -> Bool {
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
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
                        let length = self.cardNumberBuffer.characters.count-1
                        self.cardNumberBuffer = self.cardNumberBuffer[self.cardNumberBuffer.startIndex.advancedBy(0)...self.cardNumberBuffer.startIndex.advancedBy(length-1)]
                    }
                    else
                    {
                        self.cardNumberBuffer = ""
                    }
                }
                self.formatCardNumber(textField)
                return false
                
            break;
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

            break;
            
        default:
            break;
        }
        
        return result;

    }
    
    func validInputs() -> Bool {
        var inputsAreOKToProceed = false
        
        let validator = AcceptSDKCardFieldsValidator()
        
        if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!) && validator.validateExpirationDate(self.expirationMonthTextField.text!, inYear: self.expirationYearTextField.text!) && validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer)) {
            inputsAreOKToProceed = true
        }

        return inputsAreOKToProceed
    }

    func textFieldDidEndEditing(textField: UITextField) {
        
        let validator = AcceptSDKCardFieldsValidator()

        switch (textField.tag)
        {
            
        case 1:

            self.cardNumber = self.cardNumberBuffer;
                
                let luhnResult = validator.validateCardWithLuhnAlgorithm(self.cardNumberBuffer)
                
                if ((luhnResult == false) || (textField.text?.characters.count < AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardNumberCharacterCountMin))
                {
                    self.cardNumberTextField.textColor = UIColor.redColor()
                }
                else
                {
                    self.cardNumberTextField.textColor = self.darkBlueColor() //[UIColor greenColor];
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)

                }
                else
                {
                    self.updateTokenButton(false)
                }

            break;
        case 2:

            self.cardExpirationMonth = textField.text;
                
                if (self.expirationMonthTextField.text?.characters.count == 1)
                {
                    if ((textField.text == "0") == false) {
                        self.expirationMonthTextField.text = "0".stringByAppendingString(self.expirationMonthTextField.text!)
                    }
                }
                
                let newMonth = Int(textField.text!)
                
                if ((newMonth >= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationMonthMin)  && (newMonth <= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationMonthMax))
                {
                    self.expirationMonthTextField.textColor = self.darkBlueColor() //[UIColor greenColor];
                    
                }
                else
                {
                    self.expirationMonthTextField.textColor = UIColor.redColor()
                    
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)
                }
                else
                {
                    self.updateTokenButton(false)
                }

            break;
        case 3:

            self.cardExpirationYear = textField.text;
                
                let newYear = Int(textField.text!)
                if ((newYear >= validator.cardExpirationYearMin())  && (newYear <= AcceptSDKCardFieldsValidatorConstants.kInAppSDKCardExpirationYearMax))
                {
                    self.expirationYearTextField.textColor = self.darkBlueColor() //[UIColor greenColor];
                }
                else
                {
                    self.expirationYearTextField.textColor = UIColor.redColor()
                }
                
                if (self.expirationYearTextField.text?.characters.count == 0)
                {
                    return;
                }
                if (self.expirationMonthTextField.text?.characters.count == 0)
                {
                    return;
                }
                if (validator.validateExpirationDate(self.expirationMonthTextField.text!, inYear: self.expirationYearTextField.text!))
                {
                    self.expirationMonthTextField.textColor = self.darkBlueColor()
                    self.expirationYearTextField.textColor = self.darkBlueColor()
                }
                else
                {
                    self.expirationMonthTextField.textColor = UIColor.redColor()
                    self.expirationYearTextField.textColor = UIColor.redColor()
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)
                }
                else
                {
                    self.updateTokenButton(false)
                }

            break;
        case 4:

            self.cardVerificationCode = textField.text;
                
                if (validator.validateSecurityCodeWithString(self.cardVerificationCodeTextField.text!))
                {
                    self.cardVerificationCodeTextField.textColor = self.darkBlueColor()
                }
                else
                {
                    self.cardVerificationCodeTextField.textColor = UIColor.redColor()
                }
                
                if (self.validInputs())
                {
                    self.updateTokenButton(true)
                }
                else
                {
                    self.updateTokenButton(false)
                }

            break;
            
        default:
            break;
        }
    }

    func textFieldShouldClear(textField: UITextField) -> Bool {
        if (textField == self.cardNumberTextField)
        {
            self.cardNumberBuffer = String();
        }
        
        return true;
    }
}

