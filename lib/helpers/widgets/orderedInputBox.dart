import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:hungerswipe/helpers/colors.dart';

class OrderedInputBox<T> extends StatefulWidget {
  const OrderedInputBox(
      {Key? key,
      this.canRequestFocus = true,
      required this.controller,
      required this.onChanged,
      required this.order})
      : super(key: key);

  final bool canRequestFocus;
  final onChanged;
  final TextEditingController? controller;
  final T order;
  @override
  _OrderedInputBoxState<T> createState() => _OrderedInputBoxState<T>();
}

class _OrderedInputBoxState<T> extends State<OrderedInputBox<T>> {
  late FocusNode focusNode;
  late FocusAttachment nodeAttachment;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(canRequestFocus: widget.canRequestFocus);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrderedInputBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    focusNode.canRequestFocus = widget.canRequestFocus;
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (widget.order != 0) {
          node.parent?.previousFocus();
        }
        return KeyEventResult.handled;
      } else if (double.tryParse(event.character ?? "") != null) {
        widget.controller?.text = event.character ?? "";
        widget.onChanged();
        if (widget.order != 5) {
          node.parent?.nextFocus();
        } else {
          // ik this is ugly, just a temporary workaround
          node.parent?.previousFocus();
          node.parent?.previousFocus();
          node.parent?.previousFocus();
          node.parent?.previousFocus();
          node.parent?.previousFocus();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    FocusOrder order = NumericFocusOrder((widget.order as num).toDouble());
    return Container(
        width: 50,
        child: Focus(
            focusNode: focusNode,
            onKey: _handleKeyPress,
            child: FocusTraversalOrder(
                order: order,
                child: TextField(
                    controller: widget.controller,
                    maxLength: 1,
                    autofocus: widget.order == 0 ? true : false,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    cursorColor: Colors.black26,
                    cursorHeight: 24,
                    textAlign: TextAlign.center,
                    onChanged: (text){
                      widget.onChanged();
                    },
                    decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: LightModeColors["inputColor"],
                        border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5)))))));
  }
}
