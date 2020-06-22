import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'assets/constants/links.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar, euro, btc;

  Widget buildTextFiled(String label, String prefix,
      TextEditingController controller, Function changeText) {
    return TextField(
      controller: controller,
      onChanged: changeText,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amber,
        ),
        prefixText: prefix,
        border: OutlineInputBorder(),
      ),
      style: TextStyle(
        color: Colors.amber,
        fontSize: 25,
      ),
    );
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = _textToDouble(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = _textToDouble(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
    btcController.text = ((dolar * this.dolar) / btc).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = _textToDouble(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
    btcController.text = ((euro * this.euro) / btc).toStringAsFixed(2);
  }

  void _btcChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double btc = _textToDouble(text);

    realController.text = (btc * this.btc).toStringAsFixed(2);
    dolarController.text = ((btc * this.btc) / dolar).toStringAsFixed(2);
    euroController.text = ((btc * this.btc) / euro).toStringAsFixed(2);
  }

  double _textToDouble(String text) {
    return double.parse(text.replaceAll(RegExp(r','), '.'));
  }

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
    btcController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        title: Text(
          '\$ Conversor de moedas \$',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.black,
              ),
              onPressed: _clearAll)
        ],
      ),
      body: FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            case ConnectionState.active:
              return Center(
                child: Text(
                  'Quase lá',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                btc = snapshot.data["results"]["currencies"]["BTC"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextFiled(
                          'Reais', 'R\$ ', realController, _realChanged),
                      Divider(),
                      buildTextFiled(
                          'Dolares', 'US\$ ', dolarController, _dolarChanged),
                      Divider(),
                      buildTextFiled(
                          'Euros', '€ ', euroController, _euroChanged),
                      Divider(),
                      buildTextFiled(
                          'BitCoin', 'BTC ', btcController, this._btcChanged),
                    ],
                  ),
                );
              }
              break;
            default:
              return Container();
          }
        },
        future: getData(),
      ),
    );
  }

  Future<Map> getData() async {
    http.Response response = await http.get(linkApi);
    return json.decode(response.body);
  }
}
