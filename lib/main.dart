import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //https://fakestoreapi.com/products/categories

  Future<List> get_categories() async {
    // var url = Uri.https('fakestoreapi.com', 'products/categories');
    var url = Uri.parse('https://fakestoreapi.com/products/categories');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    List list=jsonDecode(response.body);
    print(list);
    return list;

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    get_categories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ECOMMERS",
        ),backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Text("Categories"),
          Expanded(child: FutureBuilder(
            future: get_categories(),
            builder: (context, snapshot) {
              print(snapshot.connectionState);
              if(snapshot.connectionState==ConnectionState.waiting)
              {
                return Center(child: CircularProgressIndicator(),);
              }
              else
              {
                List? l=snapshot.data;
                return ListView.separated(itemCount: l!.length,itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${l![index]}"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return productpage(l[index]);
                      },));
                    },
                  );
                },separatorBuilder: (context, index) {
                    return Divider(
                      height: 5,
                      color: Colors.orange,
                      thickness: 5,
                    );
                },);
              }
            },
          ))
        ],
      ),
    );
  }
}

class productpage extends StatefulWidget {
  String category;
  productpage(this.category);

  @override
  State<productpage> createState() => _productpageState();
}

class _productpageState extends State<productpage> {

  Future<List> get_products() async {
    // print('https://fakestoreapi.com/products/category/${widget.category}');
    var url = Uri.parse('https://fakestoreapi.com/products/category/${widget.category}');
    var response = await http.get(url);
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    List list=jsonDecode(response.body);
    return list;

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    get_products();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: get_products(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting)
          {
            return Center(child: CircularProgressIndicator(),);
          }
          else
          {
            List? l=snapshot.data;
            return ListView.builder(itemBuilder: (context, index) {

              Map m=l[index];
              print(m);

              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return productDetails(m);
                  },));
                },
                title: Text("${m['title']}"),
                subtitle: Text("${m['price']}"),
                leading: Image.network(m['image']),
              );
            },itemCount: l!.length,);
          }
        },
      ),
    );
  }
}

class productDetails extends StatefulWidget {

  Map m;
  productDetails(this.m);

  @override
  State<productDetails> createState() => _productDetailsState();
}

class _productDetailsState extends State<productDetails> {

  double rate=0;
  int review=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rate=widget.m['rating']['rate'];
    review=widget.m['rating']['count'];
    rate=rate.toDouble();
    print(rate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Image.network("${widget.m['image']}",height: 200,width: 200,),
          Text("${widget.m['title']}",style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25
          )),
          Text("${widget.m['description']}"),
          Text("Rs:${widget.m['price']}"),
          Text("$review Reviews"),
          RatingBar.builder(
            initialRating: rate,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
        ElevatedButton(onPressed: (){
          Razorpay razorpay = Razorpay();
          var options = {
            'key': 'rzp_test_Nmc2Pc6xkgWh2u',
            'amount': 100,
            'name': 'Acme Corp.',
            // 'description': 'Fine T-Shirt',
            'retry': {'enabled': true, 'max_count': 1},
            'send_sms_hash': true,
            'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
            'external': {
              'wallets': ['paytm']
            }
          };
          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
          razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
          razorpay.open(options);
        }, child: Text("Pay Now")),
        ],

      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response){
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");


  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message){
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed:  () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
