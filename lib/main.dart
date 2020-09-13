import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'entities/products.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

List<Product> _products = List<Product>();

Future<List<Product>> fetchNotes() async {
  var url = 'http://localhost:3000/products';
  var response = await http.get(url);

  var products = List<Product>();

  if (response.statusCode == 200) {
    var productsJson = json.decode(response.body);
    for (var productJson in productsJson) {
      products.add(Product.fromJson(productJson));
    }
  }
  return products;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_makePostRequest(String name, int quantity) async {
  String url = 'http://localhost:3000/products';
  Map<String, String> headers = {"Content-Type": "application/json"};
  final body = json.encode({'name': name, 'quantity': quantity.toString()});
  
  // make POST request
  var response = await http.post(url, headers: headers, body: body);

  if ({response.statusCode}.first == 201) {
    String body = response.body;
    debugPrint(body);
  }
  else {
    debugPrint('error');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final newName = TextEditingController();
  final newQuantity = TextEditingController();

  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _products.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // row widget, put 3 text boxes that fetches get all products of api
              Row(
                children: <Widget>[
                  Expanded(
                      child: Column(children: <Widget>[
                    Text(_products.length.toString(),
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center),
                    Text('items'),
                  ])),
                  Expanded(
                      child: Column(children: <Widget>[
                    Text('1.7k',
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center),
                    Text('quantity')
                  ])),
                  Expanded(
                      child: Column(children: <Widget>[
                    Text('51k',
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center),
                    Text('dollars')
                  ])),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: RaisedButton(
                  onPressed: () {
                    // navigate to products page when pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsPage()),
                    );
                  },
                  child: const Text('View Inventory',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            Text('Add Product',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center
              ),
            Container(
              width: 280,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: newName,
                  autocorrect: true,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(hintText: 'Enter Product Name'),
                )
              ),
              Container(
              width: 280,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  controller: newQuantity,
                  autocorrect: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Quantity'
                  ),
                )
              ),
              FloatingActionButton(
                onPressed: () {
                  _makePostRequest(newName.text, int.parse(newQuantity.text));
                  newName.clear();
                  newQuantity.clear();
                },
                tooltip: 'Increment',
                child: Icon(Icons.add),
                heroTag: null,
              ),
            ]
          ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => new _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _products.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Products"),
        ),
        body: 
            ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_products[index].name,
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold)),
                            Text(_products[index].quantity.toString()),
                          ],  
                        ),
                        Spacer(), // moves buttons to edge
                        FloatingActionButton(
                          onPressed: () {
                            // navigate to item page when pressed
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ItemsPage(product: _products[index])),
                            );
                          },
                          heroTag: null, // stops black screen / hero animation
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: _products.length,
            ),
        
      );
  }

  var _products = [];
}

_makePatchRequest(Product product, String amount, bool isAddition) async {
  // set up Patch arguments
  String url = 'http://localhost:3000/products/' + product.id;
  Map<String, String> headers = {"Content-Type": "application/json"};
  var newQuantity = product.quantity;

  if (isAddition) {
    newQuantity = product.quantity + int.parse(amount);
  }
  else {
    newQuantity = product.quantity - int.parse(amount);
  }

  String json = '{"quantity":$newQuantity}';

  var response = await http.patch(url, headers: headers, body: json);

  if (response.statusCode == 200) {
    String body = response.body;
    debugPrint(body);
  }
  else {
    debugPrint('error');
  }
}

_makeDeleteRequest(Product product) async {
  String url = 'http://localhost:3000/products/' + product.id;
  var response = await http.delete(url);

  if (response.statusCode == 200) {
    debugPrint('deleted');
  }
  else {
    debugPrint('error');
  }
}


class ItemsPage extends StatefulWidget {
  final Product product;
  ItemsPage({Key key, @required this.product}) : super(key: key);

  @override
  _ItemsPageState createState() => new _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> { 
  final number1 = TextEditingController();
  final number2 = TextEditingController();

  /*
  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        product[index].addAll(value); // pass in the index instead
      });
    });
    super.initState();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.product.name.toString()),
        ),
        body: Center(
          child: Column(
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: BoxConstraints.expand(height: 250, width: 300),
                  child: Placeholder(
                  ),
                ), 
              ),
              Text(widget.product.quantity.toString(),
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center),
              // add increase and decrease buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Container(
                    width: 80,
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                        controller: number1,
                        autocorrect: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder()
                        )
                    )
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      _makePatchRequest(widget.product, number1.text, true);
                      number1.clear();
                    },
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                    heroTag: null,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                  ),
                  //second set
                  Container(
                    width: 80,
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                        controller: number2,
                        autocorrect: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder()
                        )
                    )
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      _makePatchRequest(widget.product, number2.text, false);
                      number2.clear();
                    },
                    tooltip: 'Decrement',
                    child: Icon(Icons.remove),
                    heroTag: null,
                  ),
                ]
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: FloatingActionButton.extended(
                    onPressed: () {
                      //navigate to products page
                      //delete item
                      Navigator.pop(context, true);
                      _makeDeleteRequest(widget.product);
                    },
                    label: Text('Delete'),
                    icon: Icon(Icons.delete),
                    backgroundColor: Colors.pink,
                ),
              ),
            ],
          )
        )
    );
  }
}
