package zhuoyuan.li.fluttershareme;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.MessageDialog;
import com.facebook.share.widget.ShareDialog;
import com.twitter.sdk.android.tweetcomposer.TweetComposer;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterShareMePlugin
 */
public class FlutterShareMePlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    final private static String _methodWhatsApp = "whatsapp_share";
    final private static String _methodFaceBook = "facebook_share";
    final private static String _methodMessenger = "messenger_share";
    final private static String _methodTwitter = "twitter_share";
    final private static String _methodSystemShare = "system_share";
    final private static String _methodInstagramShare = "instagram_share";
    final private static String _methodTelegramShare = "telegram_share";
    final private static String _methodEmailShare = "email_share";
    final private static String _methodSMSShare = "sms_share";
    final private static String _methodCheckInstalledApps = "checkInstalledApps";

    private Activity activity;
    private static CallbackManager callbackManager;
    private MethodChannel methodChannel;

    private ArrayList<String> recipients;
    private ArrayList<String> ccrecipients;
    private ArrayList<String> bccrecipients;
    private String subject;
    private String body;
    private Context context;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final FlutterShareMePlugin instance = new FlutterShareMePlugin();
        instance.onAttachedToEngine(registrar.messenger());
        instance.activity = registrar.activity();
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        onAttachedToEngine(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        activity = null;
    }

    private void onAttachedToEngine(BinaryMessenger messenger) {
        methodChannel = new MethodChannel(messenger, "flutter_share_me");
        methodChannel.setMethodCallHandler(this);
        callbackManager = CallbackManager.Factory.create();
    }

    /**
     * method
     *
     * @param call   methodCall
     * @param result Result
     */
    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        String url, msg, fileType;
        switch (call.method) {
            case _methodFaceBook:
                url = call.argument("url");
                msg = call.argument("msg");
                shareToFacebook(url, msg, result);
                break;
            case _methodMessenger:
                url = call.argument("url");
                msg = call.argument("msg");
                shareToMessenger(url, msg, result);
                break;
            case _methodTwitter:
                url = call.argument("url");
                msg = call.argument("msg");
                shareToTwitter(url, msg, result);
                break;
            case _methodWhatsApp:
                msg = call.argument("msg");
                shareWhatsApp(msg, result);
                break;
            case _methodSystemShare:
                msg = call.argument("msg");
                shareSystem(result, msg);
                break;
            case _methodInstagramShare:
                msg = call.argument("url");
                fileType = call.argument("fileType");
                shareInstagramStory(msg, fileType, result);
                break;
            case _methodTelegramShare:
                msg = call.argument("msg");
                shareToTelegram(msg, result);
                break;
            case _methodEmailShare:
                recipients = call.argument("recipients");
                ccrecipients = call.argument("ccrecipients");
                bccrecipients = call.argument("bccrecipients");
                body = call.argument("body");
                subject = call.argument("subject");
                shareEmail(recipients, ccrecipients, bccrecipients, subject, body, result);
            case _methodSMSShare:
                msg = call.argument("msg");
                shareToSMS(msg, result);
                break;
            case _methodCheckInstalledApps:
                checkInstalledApps(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * system share
     *
     * @param msg    String
     * @param result Result
     */
    private void shareSystem(Result result, String msg) {
        try {
            Intent textIntent = new Intent(Intent.ACTION_SEND);
            textIntent.setType("text/plain");
            textIntent.putExtra(Intent.EXTRA_TEXT, msg);
            textIntent.putExtra(Intent.EXTRA_SUBJECT, "Share to");
            activity.startActivity(Intent.createChooser(textIntent, null));
            result.success("success");
        } catch (Exception var7) {
            result.error("error", var7.toString(), "");
        }
    }

    /**
     * share to twitter
     *
     * @param url    String
     * @param msg    String
     * @param result Result
     */

    private void shareToTwitter(String url, String msg, Result result) {
        try {
            String urlScheme = "http://www.twitter.com/intent/tweet?text=" + msg + url;
            Intent twitterIntent = new Intent(Intent.ACTION_VIEW);
            twitterIntent.setData(Uri.parse(urlScheme));
            activity.startActivity(twitterIntent);
            result.success("success");
        } catch (Exception var7) {
            result.error("error", var7.toString(), "");
        }
    }

    /**
     * share to Facebook
     *
     * @param url    String
     * @param msg    String
     * @param result Result
     */
    private void shareToFacebook(String url, String msg, Result result) {

        ShareDialog shareDialog = new ShareDialog(activity);
        // this part is optional
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                System.out.println("--------------------success");
            }

            @Override
            public void onCancel() {
                System.out.println("-----------------onCancel");
            }

            @Override
            public void onError(FacebookException error) {
                System.out.println("---------------onError");
            }
        });

        ShareLinkContent linkContent = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url))
                .build();

        if (ShareDialog.canShow(ShareLinkContent.class)) {
            shareDialog.show(linkContent);
            result.success("success");
        }

    }

    /**
     * share to Messenger
     *
     * @param url    String
     * @param msg    String
     * @param result Result
     */
    private void shareToMessenger(String url, String msg, Result result) {
        ShareLinkContent content = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url))
                .setQuote(msg)
                .build();
        MessageDialog shareDialog = new MessageDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                System.out.println("--------------------success");
            }

            @Override
            public void onCancel() {
                System.out.println("-----------------onCancel");
            }

            @Override
            public void onError(FacebookException error) {
                System.out.println("---------------onError");
            }
        });

        if (shareDialog.canShow(content)) {
            shareDialog.show(content);
            result.success("success");
        }
        result.error("error", "Cannot share thought messenger", "");
    }

    /**
     * share to whatsapp
     *
     * @param msg                String
     * @param result             Result
     * @param shareToWhatsAppBiz boolean
     */
    private void shareWhatsApp(String msg, Result result) {
        try {
            Intent whatsappIntent = new Intent(Intent.ACTION_SEND);
            whatsappIntent.setType("text/plain");
            whatsappIntent.setPackage("com.whatsapp");
            whatsappIntent.putExtra(Intent.EXTRA_TEXT, msg);
            activity.startActivity(whatsappIntent);
            result.success("success");
        } catch (Exception var9) {
            result.error("error", var9.toString(), "");
        }
    }

    /**
     * share to telegram
     *
     * @param msg    String
     * @param result Result
     */

    private void shareToTelegram(String msg, Result result) {
        try {
            Intent telegramIntent = new Intent(Intent.ACTION_SEND);
            telegramIntent.setType("text/plain");
            telegramIntent.setPackage("org.telegram.messenger");
            telegramIntent.putExtra(Intent.EXTRA_TEXT, msg);
            try {
                activity.startActivity(telegramIntent);
                result.success("true");
            } catch (Exception ex) {
                result.success("false:Telegram app is not installed on your device");
            }
        } catch (Exception var9) {
            result.error("error", var9.toString(), "");
        }
    }

    /**
     * share to instagram
     *
     * @param url      local file path
     * @param fileType type of file to share (image or video)
     * @param result   flutterResult
     */
    private void shareInstagramStory(String url, String fileType, Result result) {
        if (instagramInstalled()) {
            File file = new File(url);
            Uri fileUri = FileProvider.getUriForFile(activity,
                    activity.getApplicationContext().getPackageName() + ".provider", file);

            Intent instagramIntent = new Intent(Intent.ACTION_SEND);
            if (fileType.equals("image"))
                instagramIntent.setType("image/*");
            else if (fileType.equals("video"))
                instagramIntent.setType("video/*");
            instagramIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
            instagramIntent.setPackage("com.instagram.android");
            try {
                activity.startActivity(instagramIntent);
                result.success("Success");
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
                result.success("Failure");
            }
        } else {
            result.error("Instagram not found", "Instagram is not installed on device.", "");
        }
    }

    /**
     * share on Email
     *
     * @param recipients    ArrayList<String>
     * @param ccrecipients  ArrayList<String>
     * @param bccrecipients ArrayList<String>
     * @param subject       String
     * @param body          String
     * @param result        Result
     */
    private void shareEmail(ArrayList<String> recipients, ArrayList<String> ccrecipients,
                            ArrayList<String> bccrecipients, String subject, String body, Result result) {

        Intent shareIntent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts(
                "mailto", "", null));
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        shareIntent.putExtra(Intent.EXTRA_TEXT, body);
        shareIntent.putExtra(Intent.EXTRA_EMAIL, recipients);
        shareIntent.putExtra(Intent.EXTRA_CC, ccrecipients);
        shareIntent.putExtra(Intent.EXTRA_BCC, bccrecipients);
        try {
            activity.startActivity(Intent.createChooser(shareIntent, "Send email using..."));
        } catch (android.content.ActivityNotFoundException ex) {
            result.success("Mail services are not available");
        }
    }

    /**
     * share to sms
     *
     * @param msg    String
     * @param result Result
     */

    private void shareToSMS(String msg, Result result) {
        try {
            Intent smsIntent = new Intent(Intent.ACTION_SENDTO);
            smsIntent.setType("vnd.android-dir/mms-sms");
            smsIntent.addCategory(Intent.CATEGORY_DEFAULT);
            smsIntent.putExtra("sms_body", msg);
            smsIntent.setData(Uri.parse("sms:"));
            try {
                activity.startActivity(smsIntent);
                result.success("true");
            } catch (Exception ex) {
                result.success("false:Telegram app is not installed on your device");
            }
        } catch (Exception var9) {
            result.error("error", var9.toString(), "");
        }
    }

    private void checkInstalledApps(Result result) {
        try {
            HashMap<String, Boolean> apps = new HashMap<>();
            apps.put("instagram", false);
            apps.put("facebook", false);
            apps.put("twitter", false);
            apps.put("whatsapp", false);
            apps.put("telegram", false);
            apps.put("messenger", false);

            PackageManager packageManager = context.getPackageManager();
            List<ApplicationInfo> packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA);
            Intent intent = new Intent(Intent.ACTION_SENDTO);
            intent.addCategory(Intent.CATEGORY_DEFAULT);
            intent.setType("vnd.android-dir/mms-sms");
            intent.setData(Uri.parse("sms:"));

            List<ResolveInfo> resolvedActivities = packageManager.queryIntentActivities(intent, 0);
            apps.put("sms", !resolvedActivities.isEmpty());

            for (ApplicationInfo app : packages) {
                System.out.println("--------------------success " + app.packageName);
                if (app.packageName.equals("com.instagram.android")) {
                    apps.put("instagram", true);
                }
                if (app.packageName.equals("com.facebook.katana")) {
                    apps.put("facebook", true);
                }
                if (app.packageName.equals("com.twitter.android")) {
                    apps.put("twitter", true);
                }
                if (app.packageName.equals("com.whatsapp")) {
                    apps.put("whatsapp", true);
                }
                if (app.packageName.equals("org.telegram.messenger")) {
                    apps.put("telegram", true);
                }
                if (app.packageName.equals("com.facebook.orca")) {
                    apps.put("messenger", true);
                }
            }
            result.success(apps);
        } catch (Exception var7) {
            result.error("error", var7.toString(), "");
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {

    }

    /// Utils methods
    private boolean instagramInstalled() {
        try {
            if (activity != null) {
                activity.getPackageManager()
                        .getApplicationInfo("com.instagram.android", 0);
                return true;
            } else {
                Log.d("App", "Instagram app is not installed on your device");
                return false;
            }
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
        // return false;
    }
}
