package com.pikaway.adyen_flutter;

import android.app.Activity;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.adyen.checkout.base.HostProvider;
import com.adyen.checkout.core.card.CardApi;
import com.adyen.checkout.core.card.CardEncryptor;
import com.adyen.checkout.core.card.Card;
import com.adyen.checkout.core.card.EncryptedCard;
import com.adyen.checkout.core.card.internal.CardEncryptorImpl;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

/**
 * AdyenFlutterPlugin
 */
public class AdyenFlutterPlugin implements MethodCallHandler {
    private final Activity activity;

    private AdyenFlutterPlugin(Activity activity) {
        this.activity = activity;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "adyen_flutter");
        channel.setMethodCallHandler(new AdyenFlutterPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Plugin not passing a map as parameter: " + call.arguments);
        }
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        switch (call.method) {
            case "encryptedToken":
                try {
                    result.success(getEncryptedToken(arguments));
                } catch (Exception ex) {
                    result.error("Error", "Get encrypted Token failed.", ex);
                }
                break;
            case "encryptedCard":
                try {
                    result.success(getEncryptedCard(arguments));
                } catch (Exception ex) {
                    result.error("Error", "Get encrypted Card failed.", ex);
                }
                break;
            default:
                result.notImplemented();
        }
    }

    private String getEncryptedToken(Map<String, Object> arguments) throws Error {
        String publicKey;
        String publicKeyToken = (String) arguments.get("publicKeyToken");
        String environment = (String) arguments.get("environment");
        HostProvider hostProvider = environment.equals("TEST") ? CardApi.TEST : CardApi.LIVE_EU;
        try {
            publicKey = fetchPublicKey(hostProvider, publicKeyToken);
        } catch (Exception ex) {
            throw new Error("Could not fetch the publicKey for token:'" + publicKeyToken + "'", ex);
        }

        String cardNumber = (String) arguments.get("cardNumber");
        String cardSecurityCode = (String) arguments.get("cardSecurityCode");
        int cardExpiryMonth = Integer.parseInt((String) arguments.get("cardExpiryMonth"));
        int cardExpiryYear = Integer.parseInt((String) arguments.get("cardExpiryYear"));
        Card card = buildCard(cardNumber, cardSecurityCode, cardExpiryMonth, cardExpiryYear);
        String holderName = (String) arguments.get("holderName");

        Date generationDate;
        String generationDateString = (String) arguments.get("generationDate");
        try {
            generationDate = convertDate(generationDateString);
        } catch (Exception ex) {
            throw new Error("Could not parse the generation date string:'" + generationDateString + "'", ex);
        }

        try {
            CardEncryptor encryptor = new CardEncryptorImpl();
            return encryptor.encrypt(holderName, card, generationDate, publicKey).call();
        } catch (Exception ex) {
            throw new Error("Could not encrypt the card", ex);
        }
    }

    private Map<Object, Object> getEncryptedCard(Map<String, Object> arguments) throws Error {
        String publicKey;
        String publicKeyToken = (String) arguments.get("publicKeyToken");
        String environment = (String) arguments.get("environment");
        HostProvider hostProvider = environment.equals("TEST") ? CardApi.TEST : CardApi.LIVE_EU;
        try {
            publicKey = fetchPublicKey(hostProvider, publicKeyToken);
        } catch (Exception ex) {
            throw new Error("Could not fetch the publicKey for token:'" + publicKeyToken + "'", ex);
        }

        String cardNumber = (String) arguments.get("cardNumber");
        String cardSecurityCode = (String) arguments.get("cardSecurityCode");
        int cardExpiryMonth = Integer.parseInt((String) arguments.get("cardExpiryMonth"));
        int cardExpiryYear = Integer.parseInt((String) arguments.get("cardExpiryYear"));
        Card card = buildCard(cardNumber, cardSecurityCode, cardExpiryMonth, cardExpiryYear);

        Date generationDate;
        String generationDateString = (String) arguments.get("generationDate");
        try {
            generationDate = convertDate(generationDateString);
        } catch (Exception ex) {
            throw new Error("Could not parse the generation date string:'" + generationDateString + "'", ex);
        }
        CardEncryptor encryptor = new CardEncryptorImpl();
        try {
            EncryptedCard encryptedCard = encryptor.encryptFields(card, generationDate, publicKey).call();
            Map<Object, Object> dict = new HashMap<>();
            dict.put("encryptedNumber", encryptedCard.getEncryptedNumber());
            dict.put("encryptedSecurityCode", encryptedCard.getEncryptedSecurityCode());
            dict.put("encryptedExpiryMonth", encryptedCard.getEncryptedExpiryMonth());
            dict.put("encryptedExpiryYear", encryptedCard.getEncryptedExpiryYear());
            return dict;
        } catch (Exception ex) {
            throw new Error("Could not encrypt the card", ex);
        }
    }

    private String fetchPublicKey(HostProvider hostProvider, String publicKeyToken) throws Error {
        String publicKey = "";
        CardApi cardApi = CardApi.getInstance(this.activity.getApplication(), hostProvider);
        Callable<String> publicKeyFetcherCallable = cardApi.getPublicKey(publicKeyToken);
        FutureTask publicKeyFetcherTask = new FutureTask(publicKeyFetcherCallable);
        ExecutorService executor = Executors.newFixedThreadPool(1);
        executor.execute(publicKeyFetcherTask);
        while (true) {
            try {
                if (publicKeyFetcherTask.isDone()) {
                    executor.shutdown();
                    break;
                }
                if (!publicKeyFetcherTask.isDone()) {
                    publicKey = (String) publicKeyFetcherTask.get();
                }
            } catch (Exception ex) {
                throw new Error("Could not get the publicKey from token:''" + publicKeyToken + "'");
            }
        }
        return publicKey;
    }

    private Card buildCard(String cardNumber, String cardSecurityCode, int cardExpiryMonth, int cardExpiryYear) {
        Card.Builder cardBuilder = new Card.Builder();
        cardBuilder.setNumber(cardNumber);
        cardBuilder.setExpiryDate(cardExpiryMonth, cardExpiryYear);
        cardBuilder.setSecurityCode(cardSecurityCode);
        return cardBuilder.build();
    }

    private Date convertDate(String generationDateString) throws Error {
        DateFormat df2 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
        try {
            return df2.parse(generationDateString);
        } catch (Exception ex) {
            throw new Error("Could not parse the generation date string:'" + generationDateString + "'");
        }
    }

}
