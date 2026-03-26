import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String)? onCompleted;

  const RoomCodeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onCompleted,
  });

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = widget.focusNode.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ use widget.focusNode
      onTap: () => widget.focusNode.requestFocus(),
      child: Stack(
        children: [
          // Hidden real text field
          SizedBox(
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLength: 6,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) {
                  if (mounted) setState(() {});
                  if (value.length == 6 && widget.onCompleted != null) {
                    widget.onCompleted!(value.toUpperCase());
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),

          // Visible styled container
          Container(
            height: 64,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 22,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused ? Colors.white : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final text = widget.controller.text;
                final hasChar = index < text.length;
                final isActive = index == text.length && _isFocused;

                return SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: hasChar
                            ? Text(
                                text[index].toUpperCase(),
                                key: ValueKey('char_$index${text[index]}'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30,
                                  height: 1.0,
                                  letterSpacing: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                key: ValueKey('dash_$index'),
                                width: 20,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF6B6B6B),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
