import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class page extends StatefulWidget {
  String s;
  page(this.s);

  @override
  State<page> createState() => _pageState();
}

class _pageState extends State<page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: QrImage(
        data: widget.s,
        version: QrVersions.min,
        size: 200.0,
        gapless: false,
        errorStateBuilder: (context, error) {
          return Container();
          print(error);
        },
      ),
    );
  }
}