import Flutter
import UIKit
import FBSDKShareKit
import FBSDKCoreKit
import PhotosUI
import MessageUI

public class SwiftFlutterShareMePlugin: NSObject, FlutterPlugin {
    
    
    let _methodWhatsApp = "whatsapp_share";
    let _methodFaceBook = "facebook_share";
    let _methodMessenger = "messenger_share";
    let _methodTwitter = "twitter_share";
    let _methodInstagram = "instagram_share";
    let _methodSystemShare = "system_share";
    let _methodTelegramShare = "telegram_share";
    let _methodEmail = "email_share";
    let _methodSMSShare = "sms_share";
    let _methodCheckInstalledApps = "checkInstalledApps";
    
    private func failedWithMessage(_ message: String) -> [String: Any] {
        return ["code": 0, "message": message]
    }
    
    private let succeeded = ["code": 1]
    private let cancelled = ["code": -1]
    
    var result: FlutterResult?
    var documentInteractionController: UIDocumentInteractionController?
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_share_me", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterShareMePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        if(call.method.elementsEqual(_methodWhatsApp)){
            let args = call.arguments as? Dictionary<String,Any>
            shareWhatsApp(message: args!["msg"] as! String, result: result)
        }
        else if(call.method.elementsEqual(_methodFaceBook)){
            let args = call.arguments as? Dictionary<String,Any>
            sharefacebook(message: args!, result: result)
        }
        else if(call.method.elementsEqual(_methodMessenger)){
            let args = call.arguments as? Dictionary<String,Any>
            shareMessenger(message: args!, result: result)
        }
        else if(call.method.elementsEqual(_methodTwitter)){
            let args = call.arguments as? Dictionary<String,Any>
            shareTwitter(message: args!["msg"] as! String, urlParam: args!["url"] as! String, result: result)
        }
        else if(call.method.elementsEqual(_methodInstagram)){
            let args = call.arguments as? Dictionary<String,Any>
            shareInstagram(args: args!)
        }
        else if(call.method.elementsEqual(_methodTelegramShare)){
            let args = call.arguments as? Dictionary<String,Any>
            shareToTelegram(message: args!["msg"] as! String, result: result)
        }
        else if (call.method.elementsEqual(_methodEmail)){
            if let arguments = call.arguments as? [String:Any] {
                let recipients = arguments["recipients"] as? [String] ?? []
                let ccrecipients = arguments["ccrecipients"] as? [String] ?? []
                let bccrecipients = arguments["bccrecipients"] as? [String] ?? []
                let subject = arguments["subject"] as? String ?? ""
                let body = arguments["body"] as? String ?? ""
                let isHTML = arguments["isHTML"] as? Bool ?? false
                sendEmail(withRecipient: recipients, withCcRecipient: ccrecipients, withBccRecipient: bccrecipients, withBody: body, withSubject: subject, withisHTML: isHTML)
            }
        }
        else if (call.method.elementsEqual(_methodSMSShare)){
            let args = call.arguments as? Dictionary<String,Any>
            shareToSMS(message: args!["msg"] as! String, result: result)
        }
        else if (call.method.elementsEqual(_methodCheckInstalledApps)) {
            checkInstalledApps(result:result);
        }
        else{
            let args = call.arguments as? Dictionary<String,Any>
            systemShare(message: args!["msg"] as! String,result: result)
        }
    }
    
    
    func shareWhatsApp(message:String, result: @escaping FlutterResult)  {
        // @ For ios
        // we can't set both if you pass image then text will ignore
        let whatsURL = "whatsapp://send?text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            //mean user did not pass image url  so just got with text message
            result("Sucess");
            UIApplication.shared.openURL(whatsAppURL! as URL)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "WhatsApp is not found", details: "WhatsApp not intalled or Check url scheme."));
        }
    }
    
    // share facebook
    // params
    // @ map conting meesage and url
    
    func sharefacebook(message:Dictionary<String,Any>, result: @escaping FlutterResult)  {
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        //let shareDialog = ShareDialog()
        let shareContent = ShareLinkContent()
        guard let url = URL(string: message["url"] as! String) else {
            preconditionFailure("URL is invalid")
        }
        
        shareContent.contentURL = url
        shareContent.quote = message["msg"] as? String
        
        let shareDialog = ShareDialog(viewController: viewController, content: shareContent, delegate: self)
        shareDialog.mode = .automatic
        shareDialog.show()
        result("Sucess")
    }
    
    // share messenger
    // params
    // @ map conting meesage and url
    
    func shareMessenger(message:Dictionary<String,Any>, result: @escaping FlutterResult)  {
        guard let url = URL(string: message["url"] as! String) else {
            preconditionFailure("URL is invalid")
        }
        
        let content = ShareLinkContent()
        content.contentURL = url
        
        share(content, result)
    }
    
    private func share(_ content: SharingContent, _ result: FlutterResult) {
        let dialog = MessageDialog(content: content, delegate: self)
        
        do {
            try dialog.validate()
        } catch {
            result(failedWithMessage(error.localizedDescription))
            print(error)
        }
        
        dialog.show()
    }
    
    // share twitter params
    // @ message
    // @ url
    func shareTwitter(message:String,urlParam:String, result: @escaping FlutterResult)  {
        let urlstring = urlParam
        let twitterUrl =  "twitter://post?message=\(message)"
        
        let urlTextEscaped = urlstring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let url = URL(string: urlTextEscaped ?? "")
        
        let urlWithLink = twitterUrl + (url?.absoluteString ?? "")
        
        let escapedShareString = urlWithLink.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // cast to an url
        let urlschme = URL(string: escapedShareString)
        // open in safari
        do {
            if UIApplication.shared.canOpenURL(urlschme! as URL){
                UIApplication.shared.openURL(urlschme!)
                result("Sucess")
            }else{
                result(FlutterError(code: "Not found", message: "Twitter is not found", details: "Twitter not intalled or Check url scheme."));
                
            }
        }
        
    }
    
    //share via telegram
    //@ text that you want to share.
    func shareToTelegram(message: String,result: @escaping FlutterResult ) {
        let telegram = "tg://msg?text=\(message)"
        let telegramURL  = URL(string: telegram.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        if UIApplication.shared.canOpenURL(telegramURL!)
        {
            result("Sucess");
            UIApplication.shared.openURL(telegramURL!)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "telegram is not found", details: "telegram not intalled or Check url scheme."));
        }
        
    }
    
    //share via system native dialog
    //@ text that you want to share.
    func systemShare(message:String,result: @escaping FlutterResult)  {
        // find the root view controller
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        // set up activity view controller
        // Here is the message for for sharing
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        /// if want to exlude anything then will add it for future support.
        //        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = viewController?.view
                popup.sourceRect = CGRect(x: (viewController?.view.frame.size.width)! / 2, y: (viewController?.view.frame.size.height)! / 4, width: 0, height: 0)
            }
        }
        viewController!.present(activityVC, animated: true, completion: nil)
        result("Sucess");
        
        
    }
    
    // share image via instagram stories.
    // @ args image url
    func shareInstagram(args:Dictionary<String,Any>)  {
        let imageUrl=args["url"] as! String
        
        let image = UIImage(named: imageUrl)
        if(image==nil){
            self.result!("File format not supported Please check the file.")
            return;
        }
        guard let instagramURL = NSURL(string: "instagram://app") else {
            if let result = result {
                self.result?("Instagram app is not installed on your device")
                result(false)
            }
            return
        }
        
        do{
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image!)
                let assetId = request.placeholderForCreatedAsset?.localIdentifier
                let instShareUrl:String? = "instagram://library?LocalIdentifier=" + assetId!
                
                //Share image
                if UIApplication.shared.canOpenURL(instagramURL as URL) {
                    if let sharingUrl = instShareUrl {
                        if let urlForRedirect = NSURL(string: sharingUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(urlForRedirect as URL, options: [:], completionHandler: nil)
                            }
                            else{
                                UIApplication.shared.openURL(urlForRedirect as URL)
                            }
                        }
                        self.result?("Success")
                    }
                } else{
                    self.result?("Instagram app is not installed on your device")
                }
            }
            
        } catch {
            print("Fail")
        }
    }
    
    func sendEmail(withRecipient recipent: [String], withCcRecipient ccrecipent: [String],withBccRecipient bccrecipent: [String],withBody body: String, withSubject subject: String, withisHTML isHTML:Bool ) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: isHTML)
            mail.setToRecipients(recipent)
            mail.setCcRecipients(ccrecipent)
            mail.setBccRecipients(bccrecipent)
            UIApplication.shared.keyWindow?.rootViewController?.present(mail, animated: true, completion: nil)
        } else {
            self.result?("Mail services are not available")
        }
    }
    
    func shareToSMS(message:String, result: @escaping FlutterResult) {
        let sms = "sms:?&body=\(message)";
        let smsURL = URL(string: sms.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        if UIApplication.shared.canOpenURL(smsURL!)
        {
            result("Sucess");
            UIApplication.shared.openURL(smsURL!)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "cannot find Sms app", details: "cannot find Sms app"));
        }
    }
    
    func checkInstalledApps(result: @escaping FlutterResult) {
        var installedApps = [String:Bool]()
        if UIApplication.shared.canOpenURL(URL(string: "instagram-stories://")!) {
            installedApps["instagram"] = true;
        } else {
            installedApps["instagram"] = false;
        }
        if UIApplication.shared.canOpenURL(URL(string: "facebook-stories://")!) {
            installedApps["facebook"] = true;
        } else {
            installedApps["facebook"] = false;
        }
        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
            installedApps["twitter"] = true
        } else {
            installedApps["twitter"] = false
        }
        if UIApplication.shared.canOpenURL(URL(string: "sms://")!) {
            installedApps["sms"] = true
        } else {
            installedApps["sms"] = false
        }
        if UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) {
            installedApps["whatsapp"] = true
        } else {
            installedApps["whatsapp"] = false
        }
        if UIApplication.shared.canOpenURL(URL(string: "tg://")!) {
            installedApps["telegram"] = true
        } else {
            installedApps["telegram"] = false
        }
        if UIApplication.shared.canOpenURL(URL(string: "fb-messenger://")!) {
            installedApps["messenger"] = true
        } else {
            installedApps["messenger"] = false
        }
        if MFMailComposeViewController.canSendMail() {
            installedApps["email"] = true
        } else {
            installedApps["email"] = false;
        }
        result(installedApps)
    }
    
    /// START ALLOW HANDLE NATIVE FACEBOOK APP
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        var options = [UIApplication.LaunchOptionsKey: Any]()
        for (k, value) in launchOptions {
            let key = k as! UIApplication.LaunchOptionsKey
            options[key] = value
        }
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: options)
        return true
    }
    
    public func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        let processed = ApplicationDelegate.shared.application(
            app, open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return processed;
    }
    /// END ALLOW HANDLE NATIVE FACEBOOK APP
}

//MARK: MFMailComposeViewControllerDelegate
extension SwiftFlutterShareMePlugin: MFMailComposeViewControllerDelegate{
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SwiftFlutterShareMePlugin: SharingDelegate {
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        self.result?(succeeded)
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        self.result?(failedWithMessage(error.localizedDescription))
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        self.result?(cancelled)
    }
}
