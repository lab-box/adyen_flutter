import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adyen_flutter/adyen_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AppCardValidator());
  }
}

class AppCardValidator extends StatefulWidget {
  @override
  _AppCardValidatorState createState() => _AppCardValidatorState();
}

class _AppCardValidatorState extends State<AppCardValidator> {
  String token;
  String cardNumber;
  String securityCode;
  String month;
  String year;
  String encryptedResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adyen Card Encrypt Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: "Token",
              ),
              onChanged: (value) {
                token = value;
              },
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Card Number", counterText: ""),
                    onChanged: (value) {
                      cardNumber = value;
                    },
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                      maxLength: 4,
                      maxLengthEnforced: true,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(hintText: "CVC", counterText: ""),
                      onChanged: (value) {
                        securityCode = value;
                      }),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                      maxLength: 2,
                      maxLengthEnforced: true,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(hintText: "Month", counterText: ""),
                      onChanged: (value) {
                        month = value;
                      }),
                ),
                SizedBox(width: 15),
                Expanded(
                  flex: 4,
                  child: TextField(
                      maxLength: 4,
                      maxLengthEnforced: true,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(hintText: "Year", counterText: ""),
                      onChanged: (value) {
                        year = value;
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var encryptedToken = await AdyenFlutter.encryptedToken(
                        publicKeyToken: token,
                        environment: Environment.TEST,
                        card: CreditCard(
                          number: cardNumber,
                          securityCode: securityCode,
                          expiryMonth: month,
                          expiryYear: year,
                        ),
                        generationDate: DateTime.now());
                    setState(() {
                      encryptedResult = 'token:$encryptedToken';
                    });
                  },
                  child: Text('Encrypt Token'),
                ),
                SizedBox(width: 15),
                RaisedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var encryptedCard = await AdyenFlutter.encryptedCard(
                        publicKeyToken: token,
                        environment: Environment.TEST,
                        card: CreditCard(
                          number: cardNumber,
                          securityCode: securityCode,
                          expiryMonth: month,
                          expiryYear: year,
                        ),
                        generationDate: DateTime.now());
                    setState(() {
                      encryptedResult = '''
encryptedNumber:${encryptedCard.number}\r\n
encryptedCode:${encryptedCard.securityCode}\r\n
encryptedMonth:${encryptedCard.expiryMonth}\r\n
encryptedYear:${encryptedCard.expiryYear}\r\n
''';
                      print('Encrypted number:');
                      print(encryptedCard.number);
                      print('');
                      print('Encrypted security code:');
                      print(encryptedCard.securityCode);
                      print('');
                      print('Encrypted expiry month:');
                      print(encryptedCard.expiryMonth);
                      print('');
                      print('Encrypted expiry year:');
                      print(encryptedCard.expiryYear);

                    });
                  },
                  child: Text('Encrypt Card'),
                ),
              ],
            ),
            Expanded(
                child: ListView(children: <Widget>[Text(encryptedResult)])),
          ],
        ),
      ),
    );
  }
}
