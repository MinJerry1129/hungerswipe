import 'package:flutter/material.dart';
import 'package:hungerswipe/helpers/colors.dart';
import 'package:hungerswipe/helpers/widgets/gradientIcon.dart';

class ListPicker extends StatefulWidget {
  final List dynamicList;
  final handleAddItem;
  final handleRemoveItem;
  const ListPicker(this.dynamicList, this.handleAddItem, this.handleRemoveItem);
  @override
  _ListPickerState createState() => _ListPickerState();
}

class _ListPickerState extends State<ListPicker> {
  @override
  initState() {
    super.initState();
  }

  Widget _buildListPicker(BuildContext context, int index) {
    // var items = widget.dynamicList;
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LightModeColors["gradientLong"]["gradient1"],
                    LightModeColors["gradientLong"]["gradient2"],
                    LightModeColors["gradientLong"]["gradient3"],
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  children: [
                    Container(
                        width: 64,
                        height: 64,
                        child: Image(
                            image: AssetImage(
                                '${widget.dynamicList[index]["img"]}'))),
                    Container(width: 30),
                    Text('${widget.dynamicList[index]["name"]}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Spacer(),
                    IconButton(
                        icon: widget.dynamicList[index]['selected']
                            ? GradientIcon(
                                Icons.check_circle_outline_outlined,
                                28,
                                LinearGradient(colors: [
                                  Color(0x73E54AAF),
                                  Color(0x73F3B3D6),
                                  Color(0x737DCEFB),
                                ]))
                            : Icon(Icons.add,
                                color: LightModeColors["primary"], size: 28),
                        onPressed: widget.dynamicList[index]['selected']
                            ? () {
                                widget.handleAddItem(index);
                              }
                            : () {
                                widget.handleRemoveItem(index);
                              })
                  ],
                )),
            index == widget.dynamicList.length - 1
                ? Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LightModeColors["gradientLong"]["gradient1"],
                          LightModeColors["gradientLong"]["gradient2"],
                          LightModeColors["gradientLong"]["gradient3"],
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink()
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _buildListPicker,
      itemCount: widget.dynamicList.length,
    );
  }
}
