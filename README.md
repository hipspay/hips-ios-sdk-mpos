# Hips Apple iOS SDK 0.9.2
Hips Apple iOS SDK is a library that provides the native In-App interaction of performing the Hips MPOS payment directly from an app on the iOS device.

# Project Status
---
Supported terminals:
- Miura M010
- Miura M020

Supported payment schemes:
- Cards: Visa, Mastercard, Unionpay, American Express, Diners, Discover

Supported reading methods:
- Contact (online pin)
- Contactless (online pin)
- Mag swipe (online pin)
- ApplePay
- Google Pay (GPay)
- Samsung Pay

Supported features
- Online authorizations
- Offline authorizations (deferred authorizations)
- Offline transaction
- Offline PIN
- Online PIN
- Tip (4 different flows)
- Loyalty card reading (magnetic)
- Refunds/Reversals
- Capture
- Localization
- Remote Key Injection (RKI)
- Remote firmware update
- Remote parameter update

#### Change log
| Version | Description                                                                                                                          | Date       |
|:--------|:-------------------------------------------------------------------------------------------------------------------------------------|:-----------|

| `0.9.4` | Updated currency handling and bug fixes

| `0.9.3` | Bug fixes

| `0.9.2` | Bug fixes

| `0.9.1` | Bug fixes and payment flow updates

| `0.9.0` | Pre-release version                                                                                                               | 2021-04-22 |


# Demo app
----
This git repository contains a demo app for development reference. If you need test cards and test terminals, they can be ordered here: [Hips Store](https://hips.com/store)


# Installation steps

 - Download HipsSDK.framework
 - Drag and drop HipsSDK.framework to your project in XCode.
 - Go to your project target at Build Phases.
 - Add `HipsSDK.framework to Link Binary With Libraries.
 - Set the Status in Link Binary With Libraries to Required
 - Go to your project General tab.
 - Add HipsSDK.framework to Framework, Libraries, and Embedded Content
 - Set the Embed value in the Framework, Libraries, and Embeddfed Content to Embed & Sign

# App Info.plist entries

``` 
<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Needed for payment</string>

<key>UIBackgroundModes</key>
	<array>
		<string>bluetooth-central</string>
		<string>external-accessory</string>
	</array>

<key>UISupportedExternalAccessoryProtocols</key>
	<array>
		<string>com.miura.shuttle</string>
		<string>com.miura.rpi</string>
	</array>
```

# Integration checklist
Please make sure you tick all on this integration checklist to be Hips Certified.
- [x] Make sure you pass any reference for the payment in the reference parameter or as meta data.
- [x] Make sure the data is passed to the server by logging in to the Hips dashboard and look in the API logs
- [x] If you get `requiresParameterDownload` = `true` in the response object you must run `HipsSDK.update()` function as soon as possible to make sure the terminal is up to date.
- [x] Before any transaction is performed, an activation must take place. It can be done via settings or by running `HipsSDK.activate().
- [x] Before activation can take place, the device must be bluetooth paired.
- [x] Do not delete the app if you have stored offline transactions (`requiresTransactionUpload`) before they are posted to Hips.


# Usage
----

## Hips Settings
The SDK provides a UI to handle terminal settings. Launch Hips Settings by calling `HipsSDK.deviceSettings()`.

#### Select Default terminal
Make sure you have paired your Terminal with your iOS device. You do this via your Bluetooth settings. IMPORTANT: Your can only see paired terminals in Hips Settings Device selection

Once your `Default Device` is saved, the SDK will make all connections to this device until the `Default Device` is changed. This allows you to have multiple terminals paired.

#### Activate terminal

Following are the steps to activate a terminal on a device.  
IMPORTANT: Make sure the terminal has external power and is recently rebooted before continuing with activation.

1. Launch Hips Settings and press ACTIVATE
2. If your terminal was pre-added in your merchant account, SKIP step 3, 4 and 5.
3. Upon receiving receiving your activation code, add it with you merchant account on [https://activate.hips.com](https://activate.hips.com)
4. Follow the instructions on hips.com and activate your terminal
5. Return to your app and the terminal will continue with the activation process
6. Once the activation completes, your device will be able to make authorized request to Hips API

#### Inject keys

Add encryption keys to your terminal
IMPORTANT: Make sure the terminal has external power and is recently rebooted before continuing with injection.

1. Launch Hips Settings and press INJECT KEYS

#### Parameter updates

Update terminal with new software, parameters and merchant settings.
IMPORTANT: Make sure the terminal has external power and is recently rebooted before continuing with updates.

1. Launch Hips Settings and press CHECK UPDATES

#### Forget terminal

To deactivate your device, follow the instructions on Hips Settings by selecting Forget terminal.

IMPORTANT: You will not be able to make any authorized requests after this action. A new activation process must be launched, read above.


## Make EMV Payment

The SDK interacts by receiving and returning Request and Result types.

- Requires: `Default Device`, `TerminalApiKeyAuth`
- Request: `HipsPaymentRequest`
- Result: `Bool`
- Delegate for payment response: `HipsPaymentFlowDelegate` implement `func paymentFlowFinished(_ result: HipsTransactionResult)`

To make a new payment, create your `HipsPaymentRequest` body.

| Parameter          | Description                                                                                                                                                                                                                                                                                                                                       | Type     |
|:-------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------|
| `amountInCents`    | This is the amount with vat/tax, but without tip and cashback. We express amounts in minor units according to the ISO 4217 standard. That means they are expressed in the smallest unit of currency. Examples are USD with 1000 representing $10, GBP with 500 representing £5, EUR with 50 representing €0.50 and SEK with 100 representing 1kr. |          |
| `cashbackInCents`  | This is the cashback amount.                                                                                                                                                                                                                                                                                                                      |          |
| `cashierToken`     | This field is reserved for HIPS                                                                                                                                                                                                                                                                                                                   | Optional |
| `currencyIso`      | We use the ISO 4217 standard for defining currencies.                                                                                                                                                                                                                                                                                             |          |
| `employeeNumber`   | This is a reference so you know which employee the tips belongs to or who initiated the transaction.                                                                                                                                                                                                                                              |          |
| `isOfflinePayment` | By enabling offline payments, the SDK will store the transactions until uploaded to HIPS servers. If network connection is available, the SDK will attempt to upload the offline transaction batch will automatically. To do this manually, read section **Offline Batch upload via SDK API**                                                     |          |
| `isTestMode`       | LIVE or TEST mode selected                                                                                                                                                                                                                                                                                                                        |          |
| `metadata1`        | Your metadata 1 for order (max 255 characters)                                                                                                                                                                                                                                                                                                    | Optional |
| `metadata2`        | Your metadata 2 for order (max 255 characters)                                                                                                                                                                                                                                                                                                    | Optional |
| `reference`        | Your reference for this transaction. This reference will pass through in the transaction chain all the way to the card issuer.                                                                                                                                                                                                                    |          |
| `tipFlowType`      | Select gratuity type; NONE, ASK, TOP, TOP_CENT                                                                                                                                                                                                                                                                                                    |          |
| `transactionType`  | Select transaction type; PURCHASE, PREAUTHORIZATION, CAPTURE                                                                                                                                                                                                                                                                                      |          |
| `vatInCents`       | This is the vat/tax amount. This amount is part of net_amount.                                                                                                                                                                                                                                                                                    |          |
| `webHook`          | URL - Webhook URL where HIPS will post all events related to this order                                                                                                                                                                                                                                                                           | Optional |

#### Payment Requests

Pass your `HipsPaymentRequest` along with your view controller (`self` assuming the implementation is inside the view controller) to start a new HipsUI Payment session. `result` will return true if the payment is initiated succesfully.
```Swift

    let myReq = HipsPaymentRequest(amountInCents: 100, vatInCents: 0, cashbackInCents: 0, reference: "This is a test payment", currencyISO: "GBP", tipFlowType:  HipsTipType.none, transactionType: HipsTransactionType.purchase, isOfflinePayment: false, isTestMode: true)
    
    let result = HipsSDK.pay(self, payment: myReq)


```

#### Payment Results
A payment session always completes by returning `HipsTransactionResult`.  
Check status for approved or declined transactions in `HipsTransactionResult`, all available parameters are listed below:

| Parameter                   | Description                                                                                                                                                                                                                                                                                                     | Type |
|:----------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|
| `aid`                       | Application Identifier (AID) – terminal. Identifies the application as described in ISO/IEC 7816-5                                                                                                                                                                                                              |      |
| `amountCashback`            | This is the cashback amount. We express amounts in minor units according to the ISO 4217 standard. That means they are expressed in the smallest unit of currency. Examples are USD with 1000 representing $10, GBP with 500 representing £5, EUR with 50 representing €0.50 and SEK with 100 representing 1kr. |      |
| `amountCurrencyCode`        | Authorization Amount currency. ISO 4217 standard for defining currencies.                                                                                                                                                                                                                                       |      |
| `amountGratuity`            | Tip amount, if any. We express amounts in minor units according to the ISO 4217 standard.                                                                                                                                                                                                                       |      |
| `amountTransaction`         | Authorization amount. We express amounts in minor units according to the ISO 4217 standard.                                                                                                                                                                                                                     |      |
| `authorizationCode`         | Card authorization code                                                                                                                                                                                                                                                                                         |      |
| `authorizationMethod`       | ONLINE or OFFLINE                                                                                                                                                                                                                                                                                               |      |
| `cardFingerprint`           | Unique fingerprint of the card across multiple merchants. Used to identify the specific card for bonus purposes.                                                                                                                                                                                                                                                                                                                |      |
| `createdAt`                 | DateTime when this transaction was created in the system                                                                                                                                                                                                                                                        |      |
| `errorCode`                 | Reason code for declines (see reference)                                                                                                                                                                                                                                                                        |      |
| `errorMessage`              | Reason message                                                                                                                                                                                                                                                                                                  |      |
| `merchantAddressLine1`      | Merchant location street address line 1                                                                                                                                                                                                                                                                         |      |
| `merchantAddressLine2`      | Merchant location street address line 2                                                                                                                                                                                                                                                                         |      |
| `merchantCity`              | Merchant location City                                                                                                                                                                                                                                                                                          |      |
| `merchantCompanyNumber`     | Merchant Legal Business Number                                                                                                                                                                                                                                                                                    |      |
| `merchantCountry`           | Merchant location country code. ISO 3166-1 Alpha-2                                                                                                                                                                                                                                                              |      |
| `merchantId`                | Merchant ID for the merchant                                                                                                                                                                                                                                                                                    |      |
| `merchantLatitude`          | Latitude                                                                                                                                                                                                                                                                                                        |      |
| `merchantLongitude`         | Longitude                                                                                                                                                                                                                                                                                                       |      |
| `merchantName`              | Merchant Legal Business Name                                                                                                                                                                                                                                                                                    |      |
| `merchantPhone`             | Merchant location phone number in international format                                                                                                                                                                                                                                                          |      |
| `merchantRegion`            | Merchant region                                                                                                                                                                                                                                                                                                 |      |
| `merchantTaxVatNumber`      | Merchant V.A.T or Tax ID                                                                                                                                                                                                                                                                                        |      |
| `receiptData`               | Formatted receipt data                                                                                                                                                                                                                                                                                          |      |
| `receiptInfo`               | Application Cryptogram - Cryptogram returned by the ICC in response of the GENERATE AC command                                                                                                                                                                                                                  |      |
| `requiresParameterDownload` | Required terminal parameters are available for download                                                                                                                                                                                                                                                         |      |
| `requiresTransactionUpload` | Offline transactions are batched and ready for upload                                                                                                                                                                                                                                                           |      |
| `responder`                 | HIPS or SDK response code                                                                                                                                                                                                                                                                                       |      |
| `sdkCode`                   | Internal SDK code                                                                                                                                                                                                                                                                                               |      |
| `softwareVersion`           | SDK version                                                                                                                                                                                                                                                                                                     |      |
| `source`                    | Funding source used. Can be card, invoice, part_payment, swift, bitcoin, swish or paypal                                                                                                                                                                                                                        |      |
| `sourceAccountMasked`       | Masked Card PAN                                                                                                                                                                                                                                                                                                 |      |
| `sourceApplicationName`     | Application Label - Mnemonic associated with the AID according to ISO/IEC 7816-5                                                                                                                                                                                                                                |      |
| `sourceMethod`              | Transaction Source Method - can be purchase, refund, chargeback, credit, deprecated_void, chargeback_representation                                                                                                                                                                                             |      |
| `sourceName`                | Card Holder Name                                                                                                                                                                                                                                                                                                |      |
| `sourceScheme`              | Transaction Source Scheme - can be visa, mastercard, amex, unionpay, etc                                                                                                                                                                                                                                        |      |
| `statusCode`                | Transaction Status Code - according to DE 39 in ISO 8583. For all successful transactions the response code is set to ‘00’. All other response codes indicate an error condition.                                                                                                                               |      |
| `taxVat`                    | Vat/tax amount                                                                                                                                                                                                                                                                                                  |      |
| `terminalID`                | Terminal ID                                                                                                                                                                                                                                                                                                     |      |
| `test`                      | Test mode enabled                                                                                                                                                                                                                                                                                               |      |
| `transactionApproved`       | True if EMV status is SUCCESSFUL or AUTHORIZED                                                                                                                                                                                                                                                                  |      |
| `transactionCancelled`      | True if user canceled                                                                                                                                                                                                                                                                                           |      |
| `transactionID`             | Payment ID (store this for later referral to this payment. i.e for `HipsTransactionRequest.Capture` or `HipsTransactionRequest.Refund`                                                                                                                                                                          |      |
| `transactionShortId`        | ID (unique for merchant) for this order, also known as Humanized Token                                                                                                                                                                                                                                          |      |
| `transactionStatus`         | SUCCESSFUL or FAILED                                                                                                                                                                                                                                                                                            |      |
| `transactionType`           | HipsTransactionRequest type used                                                                                                                                                                                                                                                                                |      |
| `tsi`                       | Transaction Status Info                                                                                                                                                                                                                                                                                         |      |
| `tvr`                       | Terminal Verification Result                                                                                                                                                                                                                                                                                    |      |
| `verificationMethod`        | Transaction CVM                                                                                                                                                                                                                                                                                                 |      |
```Swift
    extension MyController : HipsPaymentFlowDelegate {
        func paymentFlowFinished(_ result: HipsTransactionResult) {
            print(result.description())
        }
```
## Refund Payment

The SDK interacts by receiving and returning Request and Result types.

- Requires: `Default Device`
- Request: `HipsRefundRequest`
- Result: `HipsTransactionResult`

To make a new Refund, create your `HipsRefundRequest` body.

> A refund on an authorized payment (not captured) will result in an automatic reversal/void of the whole authorization. Also note that on POS transactions, all transactions (even purchases marked with direct capture) will be in `authorized` state for 10 minutes before they move over to `successful` state (captured). Should you do a refund during this 10 minute period, the authorization will be voided.
> You can refund a maximum amount of the original transaction. If you don't specify the amount; the whole transaction will be refunded.
> You can only refund if there are funds available on your merchant account.

| Parameter       | Description                                                                                                                                                                                                                                                                                                                                       | Type |
|:----------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|
| `amountInCents` | This is the amount with vat/tax, but without tip and cashback. We express amounts in minor units according to the ISO 4217 standard. That means they are expressed in the smallest unit of currency. Examples are USD with 1000 representing $10, GBP with 500 representing £5, EUR with 50 representing €0.50 and SEK with 100 representing 1kr. |      |
| `transactionId` | Payment ID, received from a Payment request                                                                                                                                                                                                                                                                                                       |      |
| `isTestMode`    | Test mode enabled                                                                                                                                                                                                                                                                                                                                 |      |

#### Refund Requests

Pass your `HipsRefundRequest` along with your view controller to `HipsSDK.refund()` to start a new HipsUI Refund session.
```Swift

    let refundRequest = HipsRefundRequest(amountInCents:  100, transactionId: "1234567890", isTest: true)
    
    HipsSDK.refund(self, refundRequest) { result in
        print(result.description())
    }
```

#### Refund Results
A Refund completion closure always completes by returning `HipsTransactionResult`.  
Check status for approved or declined transactions in `HipsTransactionResult`, all available parameters and results are listed above under Payment.

## Capture Payment

The SDK interacts by receiving and returning Request and Result types.

- Requires: `Default Device`, `TerminalApiKeyAuth`
- Request: `HipsCaptureRequest`
- Result: `HipsTransactionResult`

To make a new payment, create your `HipsCaptureRequest` body.

> You can capture a maximum amount of the original transaction. If you want to capture a higher amount than the authorized amount; then we recommend you to refund (reverse) the original authorization and make a new authorization with the higher amount. Incremental authorizations are not yet supported byt the SDK.


| Parameter       | Description                                                                                                                                                                                                                                                                                                                                       | Type |
|:----------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|
| `amountInCents` | This is the amount with vat/tax, but without tip and cashback. We express amounts in minor units according to the ISO 4217 standard. That means they are expressed in the smallest unit of currency. Examples are USD with 1000 representing $10, GBP with 500 representing £5, EUR with 50 representing €0.50 and SEK with 100 representing 1kr. |      |
| `transactionId` | Payment ID, received from a Payment request                                                                                                                                                                                                                                                                                                                                                   |      |
| `isTestMode`    | Test mode enabled                                                                                                                                                                                                                                                                                                                                 |      |

#### Capture Requests

Pass your `HipsCaptureRequest` along with your view controller instance to `HipsSDK.capture()` to start a new HipsUI Payment session.
```kotlin
    let refundRequest = HipsRefundRequest(amountInCents:  100, transactionId: "1234567890", isTest: true)

    HipsSDK.refund(self, refundRequest) { result in
       print(result.description())
    }
}
```

#### Capture Results
A Capture session always completes by returning `HipsTransactionResult`.  
Check status for approved or declined transactions in `HipsTransactionResult`, all available parameters and results are listed above under Payment.

## Make Non Payments - Loyalty cards

Launch a mag swipe session by calling `HipsSDK.loyalty()`. Provide a text string to display on your terminal.
The SDK interacts by receiving and returning Request and Result types.



> ### **IMPORTANT!**
> The BIN (first 6 digits) of the non-payment card that you want to read via this function must be pre-registered as a non-payment BIN. 
> Non registered BINs will not return any track data. To register a non-payment BIN, please email a proof that this BIN is owned by you to support@hips.com

- Requires: `Default Device`
- Request: `HipsNonPaymentRequest`
- Result: `HipsNonPaymentMagSwipeResult`

#### Non Payment Mag Swipe Requests
```Swift
    let request = HipsNonPaymentRequest(with: "Please swipe card")
    
    HipsSDK.loyalty(self, transaction: request, requestCode: 123) { (result) in
        print(result!.description())
    }

```

#### Non Payment Mag Swipe Results
A payment session always completes by returning `HipsNonPaymentMagSwipeResult`.  
Check status for approved or declined transactions in `HipsNonPaymentMagSwipeResult`, all available parameters are listed below:

| Parameter         | Description                                              | Type |
|:------------------|:---------------------------------------------------------|:-----|
| `createdAt`       | DateTime when this transaction was created in the system |      |
| `errorCode`       | Reason code for declines (see reference)                 |      |
| `errorMessage`    | Reason message                                           |      |
| `softwareVersion` | SDK version                                              |      |
| `track1`          | Magnetic Stripe Track 1                                  |      |
| `track2`          | Magnetic Stripe Track 2                                  |      |
| `track3`          | Magnetic Stripe Track 3                                  |      |

## Offline Batch Upload via HipsSDK

Trigger manual offline batch uploads by in invoking `HipsSDK.offlineUpload()`. This will upload any existing offline transactions stored in the SDK
- Requires: `TerminalApiKeyAuth`
- Result: `HipsOfflineTransactionResult`

| Parameter        | Description                       | Type |
|:-----------------|:----------------------------------|:-----|
| `accepted`       | List of accepted `transactionID`s |      |
| `rejected`       | List of rejected `transactionID`s |      |
| `accepted_count` | Number of accepted transactions   |      |
| `rejected_count` | Number of rejected transactions   |      |


#### Trigger Offline Batch Upload
```Swift

    HipsSDK.offlineUpload(self) { (offlineUploadResponse) in
        guard let response = offlineUploadResponse else
        {
            print("Error uploading transactions, please try again later...")
            return
        }
        print("Offline upload accepted \(response.acceptedCount) and rejeted \(response.rejectedCount)")
    }

```


## Terminal Activation via HipsSDK

Launch Activation UI by in invoking `HipsSDK.activate()`. Select a paired device and start the activation process.  Read more about the steps involved in section **Hips Settings - Activate terminal**

- Result: `Bool`

Returns true if the process is initated successfully

#### Trigger Terminal Activation
```Swift
    if(HipsSDK.activate(self))
    {
        print("Unable to load HipsSDK update flow")
    }
```

#### Terminal Activation results  
```Swift
extension MyViewController : HipsUpdateFlowDelegate {
    
    func updateFlowFinished(_ serial : String, _ success: Bool) {
       print("Activation/Update finished with:\(success)")

    }
    
}
```

## Terminal Parameter Update via HipsSDK

Launch Parameter Update UI by in invoking `HipsSDK.update()`. The SDK will attempt to connect to your `Default Device`.  Read more about the steps involved in section **Hips Settings - Parameter updates**

- Requires: `Default Device`,
- Result: `Bool`

Returns true if the process is initiated successfully


#### Trigger Terminal Parameter Update
```Swift
    HipsSDK.update(self)
```
#### Terminal Parameter Update results 
```Swift
extension MyViewController : HipsUpdateFlowDelegate {
    
    func updateFlowFinished(_ serial : String, _ success: Bool) {
       print("Activation/Update finished with:\(success)")

    }
    
}
```

## Response, Decline and Error Codes
Find all response codes at [Hips Docs](https://docs.hips.com/reference#errors). Below are SDK specific error codes listed:

| Code                               | Reason                                                                                  |
|:-----------------------------------|:----------------------------------------------------------------------------------------|
| `DEFAULT_TERMINAL_NOT_FOUND_ERROR` | SDK functions that required a terminal are invoked without a paired default device set. |
| `TERMINAL_COMMUNICATION_ERROR`     | SDK cannot establish a connection to a terminal.                                        |
| `CANCELLED_BY_USER`                | User cancel a session.                                                                  |
| `BLUETOOTH_DISABLED`               | Bluetooth adapter is turned off.                                                        |
| `PARTIAL_REFUND_ERROR`             | Offline refunds require full amount.                                                    |
