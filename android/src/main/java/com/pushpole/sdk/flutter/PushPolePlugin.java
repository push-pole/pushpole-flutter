package com.pushpole.sdk.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import org.json.JSONException;
import com.pushpole.sdk.PushPole;
import com.pushpole.sdk.util.InvalidJsonException;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterMain;

/**
 * PushPolePlugin
 *
 * #author Mahdi Malvandi
 */
public class PushPolePlugin implements MethodCallHandler {

    private Context context;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "PushPole");
        channel.setMethodCallHandler(new PushPolePlugin(registrar));
    }

    private PushPolePlugin(Registrar registrar) {
        this.context = registrar.context();

        IntentFilter i = new IntentFilter();
        i.addAction(context.getPackageName() + ".NOTIFICATION_RECEIVED");
        i.addAction(context.getPackageName() + ".NOTIFICATION_CLICKED");
        i.addAction(context.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED");
        i.addAction(context.getPackageName() + ".NOTIFICATION_DISMISSED");
        i.addAction(context.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED");
        context.registerReceiver(new PushPoleNotificationReceiver(new MethodChannel(registrar.messenger(), "PushPole")), i);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String methodName = call.method;
        switch (methodName) {
            case "PushPole#initialize":
                Boolean showDialog = null;
                if (call.hasArgument("showDialog")) {
                    showDialog = call.argument("showDialog");
                }
                if (showDialog == null) showDialog = true;
                PushPole.initialize(context, showDialog);
                System.out.println("[Plugin] Trying to initialize PushPole");
                PushPole.initialize(context, true);
                break;
            case "PushPole#getId":
                result.success(PushPole.getId(context));
                break;
            case "PushPole#subscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    PushPole.subscribe(context, topic);
                    result.success("Will subscribe to topic " + topic);
                } else {
                    result.error("404", "Failed to subscribe. No topic argument is passed", null);
                }
                break;
            case "PushPole#unsubscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    PushPole.unsubscribe(context, topic);
                    result.success("Will unsubscribe from topic " + topic);
                } else {
                    result.error("404", "Failed to unsubscribe. No topic provided.", null);
                }
                break;
            case "PushPole#setNotificationOff":
                PushPole.setNotificationOff(context);
                break;
            case "PushPole#setNotificationOn":
                PushPole.setNotificationOn(context);
                break;
            case "PushPole#isNotificationOn":
                result.success(PushPole.isNotificationOn(context));
                break;
            case "PushPole#isPushPoleInitialized":
                result.success(PushPole.isPushPoleInitialized(context));
                break;
            case "PushPole#sendSimpleNotifToUser":
                if (call.hasArgument("pushpoleId")
                        && call.hasArgument("title")
                        && call.hasArgument("content")) {
                    PushPole.sendSimpleNotifToUser(context,
                            (String) call.argument("pushpoleId"),
                            (String) call.argument("title"),
                            (String) call.argument("content"));
                }
                break;
            case "PushPole#sendAdvancedNotifToUser":
                if (call.hasArgument("pushpoleId")
                        && call.hasArgument("json")) {
                    try {
                        PushPole.sendAdvancedNotifToUser(context,
                                (String) call.argument("pushpoleId"),
                                (String) call.argument("json"));
                        result.success("Will send advanced notification");
                    } catch (InvalidJsonException e) {
                        result.error("Invalid json entered", null, null);
                    } catch (Exception c) {
                        result.error("Something bad happened.", null, null);
                    }
                }
                break;
            case "PushPole#initNotificationListenerManually":
                initNotificationListenerManually();
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    private void initNotificationListenerManually() {
        PushPoleApplication.initializeNotificationListeners(context.getApplicationContext());
    }

    public static class PushPoleNotificationReceiver extends BroadcastReceiver {
        private MethodChannel channel;

        public PushPoleNotificationReceiver(MethodChannel methodChannel) {
            channel = methodChannel;
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            FlutterMain.ensureInitializationComplete(context, null);
            String action = intent.getAction() == null ? "" : intent.getAction();
            if (action.equals(context.getPackageName() + ".NOTIFICATION_RECEIVED")) {
                String data = intent.getStringExtra("data");
                channel.invokeMethod("PushPole#onNotificationReceived", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_CLICKED")) {
                String data = intent.getStringExtra("data");
                channel.invokeMethod("PushPole#onNotificationClicked", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED")) {
                String data = intent.getStringExtra("data");
                String button = intent.getStringExtra("button");
                channel.invokeMethod("PushPole#onNotificationButtonClicked", data+"|||"+button);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED")) {
                String data = intent.getStringExtra("json");
                channel.invokeMethod("PushPole#onCustomContentReceived", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_DISMISSED")) {
                String data = intent.getStringExtra("data");
                channel.invokeMethod("PushPole#onNotificationDismissed", data);
            }
        }
    }

}
