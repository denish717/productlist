import 'package:flutter/material.dart';
import 'package:productlist/qrpage.dart';

class qrcode extends StatefulWidget {
  const qrcode({Key? key}) : super(key: key);

  @override
  State<qrcode> createState() => _qrcodeState();
}

class _qrcodeState extends State<qrcode> {
  @override
  Widget build(BuildContext context) {
    TextEditingController t1=TextEditingController();
    String s="";
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: t1,),
            ElevatedButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return page(t1.text);
              },));

            }, child: Text("generate")),

          ],
        ),
      ),
    );
  }
}