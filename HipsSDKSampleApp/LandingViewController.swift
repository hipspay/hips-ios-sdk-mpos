//
//  LandingViewController.swift
//  HipsExample
//
//  Copyright © 2020 Hips. All rights reserved.
//

import UIKit
import HipsSDK

extension UITextField{
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}


class LandingViewController: UIViewController {
    
    
    
    
    
    @IBOutlet weak var txtAmount : UITextField!
    @IBOutlet weak var txtCashBack : UITextField!
    @IBOutlet weak var txtReference : UITextField!
    @IBOutlet weak var txtCashierToken : UITextField!
    @IBOutlet weak var txtNonPayment : UITextField!
    
    @IBOutlet weak var pickTipFlow: UIPickerView!
    @IBOutlet weak var pickCurrency: UIPickerView!
    @IBOutlet weak var pickTransactionType: UIPickerView!
    
    @IBOutlet weak var switchTestMode : UISwitch!
    @IBOutlet weak var switchOfflineMode : UISwitch!
    
    @IBOutlet weak var btnPay : UIButton!
    @IBOutlet weak var btnRefund : UIButton!
    @IBOutlet weak var btnCapture : UIButton!
    @IBOutlet weak var btnLoyalty : UIButton!
    @IBOutlet weak var btnOfflineUpload : UIButton!
    @IBOutlet weak var btnActivateTerminal : UIButton!
    @IBOutlet weak var btnUpdateTerminal : UIButton!
    @IBOutlet weak var btnSettings : UIButton!
    
    @IBOutlet weak var lblTransactionResult: UILabel!
    
    
    var transactionResult : HipsTransactionResult? = nil

    let currencies = ["EUR","GBP","SEK","PLN","USD"]
    func setupInitialValues(){
        
        self.txtAmount.text = "1"
        self.txtReference.text = "1234"
        self.txtNonPayment.text = "Please swipe your card..."
        
    }
    func setupDefaults()
    {
        //for testing:
        setupInitialValues()
        self.switchTestMode.isOn = true
        self.switchOfflineMode.isOn = false
        self.pickTipFlow.tag = 0
        self.pickCurrency.tag = 1
        self.pickTransactionType.tag = 2
        self.pickTipFlow.dataSource = self
        self.pickCurrency.dataSource = self
        self.pickTipFlow.delegate = self
        self.pickCurrency.delegate=self
        self.pickTransactionType.dataSource = self
        self.pickTransactionType.delegate = self
        txtAmount.addDoneButtonOnKeyboard()
        txtReference.addDoneButtonOnKeyboard()
        txtCashBack.addDoneButtonOnKeyboard()
        txtNonPayment.addDoneButtonOnKeyboard()
        txtCashierToken.addDoneButtonOnKeyboard()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pickCurrency.selectRow(0, inComponent: 0, animated: false)
        self.pickTipFlow.selectRow(HipsTipType.toList().firstIndex(of: HipsTipType.none) ?? 0, inComponent: 0, animated: false)
        self.pickTransactionType.selectRow(HipsTransactionType.toList().firstIndex(of: HipsTransactionType.purchase) ?? 0, inComponent: 0, animated: false)

        
    }
    
    @IBAction func hipsSettingsButtonTapped(_ sender: Any) {
        guard let deviceSettingsVC = Hips.deviceSettings() else { return }
        navigationController?.pushViewController(deviceSettingsVC, animated: true)
    }
    
    
    @IBAction func loyaltyButtonTapped(_ sender: Any) {
    
        let request = HipsNonPaymentRequest(with: self.txtNonPayment.text ?? "No text entered")
        Hips.loyalty(self, transaction: request, requestCode: 123) { (result) in
            
                DispatchQueue.main.async {
                    
                    
                    self.lblTransactionResult.text = result!.description()
                }
            }
        }
    
    @IBAction func offlineUploadButtonTapped(_ sender: Any) {
        
        Hips.offlineUpload(self) { (uploads) in
            DispatchQueue.main.async {
                
                self.lblTransactionResult.text = "Offline upload returned \(uploads?.accepted.count ?? 0) accepted transactions"
            }
        }
    }
    
    @IBAction func activateTerminalTapped(_ sender: Any) {
        if(Hips.activate(self))
        {
            print("Unable to load Hips update flow")
        }
    }
    @IBAction func updateTerminalTapped(_ sender: Any) {
        if(Hips.update(self))
        {
            print("Unable to load Hips update flow")
        }
    }
    
    
    @IBAction func refundButtonTapped(_ sender: Any) {
      
        if(transactionResult == nil)
        {
            self.lblTransactionResult.text = "No trasnaction available to refund, please make a transaction first"
            return
        }
        let refundRequest = HipsRefundRequest(amountInCents:  Int.init(self.txtAmount.text!) ?? 0, transactionId: self.transactionResult!.transactionID!, isTest: self.switchTestMode.isOn)
        Hips.refund(self, refundRequest) { result in
            DispatchQueue.main.async {
               
                self.lblTransactionResult.text = "(\(result!.errorCode!)) \(result!.errorMessage!)"
            }
        }
        
    }
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        if(transactionResult == nil)
        {
            self.lblTransactionResult.text = "No trasnaction available to capture, please make a pre-auth transaction first"
            return
        }
        let captureRequest = HipsCaptureRequest.init(amountInCents:  Int.init(self.txtAmount.text!) ?? 0, transactionId: self.transactionResult!.transactionID!, isTest: self.switchTestMode.isOn)
        Hips.capture(self, request: captureRequest) { result in
            DispatchQueue.main.async {
               
                self.lblTransactionResult.text = "(\(result!.errorCode!)) \(result!.errorMessage!)"
            }
        }
    }
    @IBAction func payButtonTapped(_ sender: Any)
    {
        
        let amount = Int(self.txtAmount.text ?? "0") ?? 0
        let vat = 0
        let cashback = Int(self.txtCashBack.text ?? "0") ?? 0
        let reference = self.txtReference.text ?? "-"
        let currencyISO = currencies[self.pickCurrency.selectedRow(inComponent: 0)]
        let tipFlowType = HipsTipType.toList()[self.pickTipFlow.selectedRow(inComponent: 0)]
        let transactionType = HipsTransactionType.toList()[self.pickTransactionType.selectedRow(inComponent: 0)]
        let isOffline = self.switchOfflineMode.isOn
        
        let myReq = HipsPaymentRequest.init(amountInCents: amount, vatInCents: vat, cashbackInCents: cashback, reference: reference, currencyISO: currencyISO, tipFlowType: tipFlowType, transactionType: transactionType, isOfflinePayment: isOffline, isTestMode: self.switchTestMode.isOn)
        let result = Hips.pay(self, payment: myReq)
        if(result == false)
        {
            self.lblTransactionResult.text = "Unable to start payment, payment already started, bluetooth not connected or no default terminal found"
        }
        
    }
            
            
        
        
        @IBAction func removeKeyboard(_ sender: Any)
        {
            self.txtAmount.resignFirstResponder()
            self.txtReference.resignFirstResponder()
        }
        
        
        
        
    }
    
    //Data
    extension LandingViewController : UIPickerViewDataSource, UIPickerViewDelegate{
        
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch pickerView.tag
            {
            case pickTipFlow.tag:
                return HipsTipType.toList().count
                
            case pickCurrency.tag:
                return currencies.count
            case pickTransactionType.tag:
                return HipsTransactionType.toList().count
                
            default:
                break
            }
            return 0
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            switch pickerView.tag
            {
            case pickTipFlow.tag:
                return HipsTipType.toList()[row].rawValue
                
            case pickCurrency.tag:
                return currencies[row]
            case pickTransactionType.tag:
                return HipsTransactionType.toList()[row].rawValue
                
            default:
                break
            }
            return "None"
        }
        
        
    }

extension LandingViewController : HipsUpdateFlowDelegate {
    func updateFlowFinished(_ serial : String, _ success: Bool) {
        DispatchQueue.main.async {
            self.lblTransactionResult.text = "Activation/Update finished with:\(success) for device with Serial: \(serial)"
        }
    }
}
extension LandingViewController : HipsPaymentFlowDelegate {
    func paymentFlowFinished(_ result: HipsTransactionResult) {
        DispatchQueue.main.async {
            self.transactionResult = result
            self.lblTransactionResult.text = result.description()
        }
    }
}
