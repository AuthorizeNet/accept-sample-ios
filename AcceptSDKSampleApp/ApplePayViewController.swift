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
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
}
