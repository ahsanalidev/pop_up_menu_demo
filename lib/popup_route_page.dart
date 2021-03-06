import 'package:examples/drop_down_field.dart';
import 'package:examples/w_popup_menu.dart';
import 'package:flutter/material.dart';

class PopupRoutePage extends StatefulWidget {
  @override
  _PopupRoutePageState createState() => _PopupRoutePageState();
}

class _PopupRoutePageState extends State<PopupRoutePage> {
  String valueOne;
  String valueTwo;
  FocusNode focusNodeOne = FocusNode();
  FocusNode focusNodeTwo = FocusNode();
  final List<String> actions = [
    '复制',
    '转发',
    '收藏',
    '删除',
    '多选',
    '提醒',
    '翻译',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PopupRoutePage'),
      ),
      body: ListView.builder(
          itemCount: 40,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              alignment:
                  index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 350,
                height: 40,
                child: WPopupMenu(
                  menuHeight: 100,
                  menuWidth: 300,
                  body: Container(
                    width: 200,
                    height: 80,
                    color: Colors.red,
                    // child: Row(
                    //   children: [
                    //     DropDownField(
                    //       innerText: 'text',
                    //       onChanged: (value) {
                    //         setState(() {
                    //           valueOne = value;
                    //         });
                    //       },
                    //       focusNode: focusNodeOne,
                    //       validator: (value) => null,
                    //       currentValue: valueOne,
                    //       options: [
                    //         'testone',
                    //         'testtwo',
                    //         'testthree',
                    //         'testfour',
                    //       ],
                    //     ),
                    //     DropDownField(
                    //       innerText: 'TestTwo',
                    //       onChanged: (value) {
                    //         setState(() {
                    //           valueTwo = value;
                    //         });
                    //       },
                    //       focusNode: focusNodeTwo,
                    //       validator: (value) => null,
                    //       currentValue: valueTwo,
                    //       options: [
                    //         'testone',
                    //         'testtwo',
                    //         'testthree',
                    //         'testfour',
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      color: index % 2 == 0 ? Colors.orangeAccent : Colors.blue,
                    ),
                    child: Text(
                      'Test $index',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
