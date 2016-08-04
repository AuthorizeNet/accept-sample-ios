//
//  ApplePayViewController.swift
//  AcceptSDKSampleApp
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 8/4/16.
//  Copyright © 2016 Ramamurthy, Rakesh Ramamurthy. All rights reserved.
//

import Foundation
import PassKit

class ApplePayViewController:UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    @IBOutlet weak var applePayButton:UIButton!
    @IBOutlet weak var headerView:UIView!

    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.backgroundColor = UIColor(colorLiteralRed: 48/255, green: 85/255, blue: 112/255, alpha: 1)

//        self.applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }
    
    @IBAction func payWithApplePay(sender: AnyObject) {
        
        let supportedNetworks = [ PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa ]
        
        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            return self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(supportedNetworks) == false {
            let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            return self.presentViewController(alert, animated: true, completion: nil)
        }

        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.authorize.net.test.dev15"
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "T-Shirt", amount: 0.1),
            PKPaymentSummaryItem(label: "Watch", amount: 0.1)
        ]

        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self
        
        self.presentViewController(applePayController, animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")
//        if payment {
//            NSString *base64string = [CreditCardViewController  base64forData:payment.token.paymentData];
//            
//            [self performTransactionWithEncryptedPaymentData:base64string withPaymentAmount:amount];
//            
//            completion(PKPaymentAuthorizationStatusSuccess);
//        }
//        else
//        {
//            completion(PKPaymentAuthorizationStatusFailure);
//        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    func base64forData(theData: NSData) -> String {
//        var input = (theData.bytes as? UInt8)
        var input = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(theData.bytes), count: theData.length))
        var length: Int = theData.length
        
        var myString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        let table = [UInt8](myString.characters)
        
        let count = ((theData.length + 2) / 3) * 4
        var output = [UInt8](count: count, repeatedValue: 0)

        var data: NSMutableData = NSMutableData(length: ((length + 2) / 3) * 4)!
        data.getBytes(&output, length:count * sizeof(UInt8))

        
        var i: Int
        for i = 0 ; i < length ; i += 3 {
            var value: UInt8 = 0
            var j: Int
            for j = i ; j < (i+3) ; j++ {
                value <<= 8
                if j < length {
                    value |= (0xFF&input[j])
                }
            }
            var theIndex: Int = (i/3)*4
            output[theIndex+0] = table[(value>>18)&0x3F]
            output[theIndex+1] = table[(value>>12)&0x3F]
            output[theIndex+2] = (i+1) < length ? table[(value>>6)&0x3F] : Character("=")
            output[theIndex+3] = (i+2) < length ? table[(value>>0)&0x3F] : Character("=")
        }
    }
}
