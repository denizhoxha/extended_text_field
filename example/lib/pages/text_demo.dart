import 'dart:math';

import 'package:example/common/toggle_button.dart';
import 'package:example/special_text/emoji_text.dart' as emoji;
import 'package:example/special_text/my_special_text_span_builder.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart'
    hide MySpecialTextSpanBuilder;
import 'package:loading_more_list/loading_more_list.dart';

@FFRoute(
    name: 'fluttercandies://TextDemo',
    routeName: 'text',
    description: 'build special text and inline image in text field')
class TextDemo extends StatefulWidget {
  @override
  _TextDemoState createState() => _TextDemoState();
}

class _TextDemoState extends State<TextDemo> {
  TuChongRepository tuChongRepository;
  TextEditingController _textEditingController = TextEditingController();
  MyExtendedMaterialTextSelectionControls _myExtendedMaterialTextSelectionControls =
      MyExtendedMaterialTextSelectionControls();
  final GlobalKey _key = GlobalKey();
  MySpecialTextSpanBuilder _mySpecialTextSpanBuilder = MySpecialTextSpanBuilder();

  List<TuChongItem> images = <TuChongItem>[];

  final FocusNode _focusNode = FocusNode();
  double _keyboardHeight = 267.0;
  bool get showCustomKeyBoard =>
      activeEmojiGird || activeAtGrid || activeDollarGrid || activeImageGrid;
  bool activeEmojiGird = false;
  bool activeAtGrid = false;
  bool activeDollarGrid = false;
  bool activeImageGrid = false;
  List<String> sessions = <String>[
    '[44] @Dota2 CN dota best dota',
    'yes, you are right [36].',
    '大家好，我是拉面，很萌很新 [12].',
    '\$Flutter\$. CN dev best dev',
    '\$Dota2 Ti9\$. Shanghai,I\'m coming.',
    'error 0 [45] warning 0',
  ];

  @override
  void initState() {
    tuChongRepository = TuChongRepository();
    super.initState();
  }

  @override
  void dispose() {
    tuChongRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).autofocus(_focusNode);
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      activeEmojiGird = activeAtGrid = activeDollarGrid = activeImageGrid = false;
    }

    _keyboardHeight = max(_keyboardHeight, keyboardHeight);

    return Scaffold(
      appBar: AppBar(
        title: const Text('special text'),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.backspace),
            onPressed: manualDelete,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ExtendedListView.builder(
            extendedListDelegate: const ExtendedListDelegate(closeToTrailing: true),
            itemBuilder: (BuildContext context, int index) {
              final bool left = index % 2 == 0;
              final Image logo = Image.asset(
                'assets/flutter_candies_logo.png',
                width: 30.0,
                height: 30.0,
              );
              //print(sessions[index]);
              final Widget text = ExtendedText(
                sessions[index],
                textAlign: left ? TextAlign.left : TextAlign.right,
                specialTextSpanBuilder: _mySpecialTextSpanBuilder,
                onSpecialTextTap: (dynamic value) {
                  if (value.toString().startsWith('\$')) {
                    launch('https://github.com/fluttercandies');
                  } else if (value.toString().startsWith('@')) {
                    launch('mailto:zmtzawqlp@live.com');
                  }
                  //image
                  else {
                    final TuChongItem item =
                        images.firstWhere((TuChongItem x) => x.imageUrl == value.toString());
                    Navigator.pushNamed(context, 'fluttercandies://picswiper',
                        arguments: <String, dynamic>{
                          'index': images.indexOf(item),
                          'pics': item.images
                              .map<PicSwiperItem>(
                                  (ImageItem f) => PicSwiperItem(picUrl: f.imageUrl, des: f.title))
                              .toList(),
                          'tuChongItem': item,
                        });
                  }
                },
              );
              List<Widget> list = <Widget>[
                logo,
                Expanded(child: text),
                Container(
                  width: 30.0,
                )
              ];
              if (!left) {
                list = list.reversed.toList();
              }
              return Row(
                children: list,
              );
            },
            padding: const EdgeInsets.only(bottom: 10.0),
            reverse: true,
            itemCount: sessions.length,
          )),
          //  TextField()
          Container(
            height: 2.0,
            color: Colors.blue,
          ),
          ExtendedTextField(
            key: _key,
            specialTextSpanBuilder: MySpecialTextSpanBuilder(
              showAtBackground: true,
            ),
            controller: _textEditingController,
            textSelectionControls: _myExtendedMaterialTextSelectionControls,
            maxLines: null,
            focusNode: _focusNode,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      sessions.insert(0, _textEditingController.text);
                      _textEditingController.value = _textEditingController.value.copyWith(
                          text: '',
                          selection: const TextSelection.collapsed(offset: 0),
                          composing: TextRange.empty);
                    });
                  },
                  child: Icon(Icons.send),
                ),
                contentPadding: const EdgeInsets.all(12.0)),
            //textDirection: TextDirection.rtl,
          ),
          Container(
            color: Colors.grey.withOpacity(0.3),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ToggleButton(
                      activeWidget: Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.orange,
                      ),
                      unActiveWidget: Icon(Icons.sentiment_very_satisfied),
                      activeChanged: (bool active) {
                        final Function change = () {
                          setState(() {
                            if (active) {
                              activeAtGrid = activeDollarGrid = activeImageGrid = false;
                              FocusScope.of(context).requestFocus(_focusNode);
                            }
                            activeEmojiGird = active;
                          });
                        };
                        update(change);
                      },
                      active: activeEmojiGird,
                    ),
                    ToggleButton(
                        activeWidget: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            '@',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        unActiveWidget: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            '@',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ),
                        activeChanged: (bool active) {
                          final Function change = () {
                            setState(() {
                              if (active) {
                                activeEmojiGird = activeDollarGrid = activeImageGrid = false;
                                FocusScope.of(context).requestFocus(_focusNode);
                              }
                              activeAtGrid = active;
                            });
                          };
                          update(change);
                        },
                        active: activeAtGrid),
                    ToggleButton(
                        activeWidget: Icon(
                          Icons.attach_money,
                          color: Colors.orange,
                        ),
                        unActiveWidget: Icon(Icons.attach_money),
                        activeChanged: (bool active) {
                          final Function change = () {
                            setState(() {
                              if (active) {
                                activeEmojiGird = activeAtGrid = activeImageGrid = false;
                                FocusScope.of(context).requestFocus(_focusNode);
                              }
                              activeDollarGrid = active;
                            });
                          };
                          update(change);
                        },
                        active: activeDollarGrid),
                    ToggleButton(
                        activeWidget: Icon(
                          Icons.picture_in_picture,
                          color: Colors.orange,
                        ),
                        unActiveWidget: Icon(Icons.picture_in_picture),
                        activeChanged: (bool active) {
                          final Function change = () {
                            setState(() {
                              if (active) {
                                activeEmojiGird = activeAtGrid = activeDollarGrid = false;
                                FocusScope.of(context).requestFocus(_focusNode);
                              }
                              activeImageGrid = active;
                            });
                          };
                          update(change);
                        },
                        active: activeImageGrid),
                    Container(
                      width: 20.0,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
                Container(),
              ],
            ),
          ),
          Container(
            height: 2.0,
            color: Colors.blue,
          ),
          Container(
            height: showCustomKeyBoard ? _keyboardHeight : 0.0,
            child: buildCustomKeyBoard(),
          )
        ],
      ),
    );
  }

  void update(Function change) {
    if (showCustomKeyBoard) {
      change();
    } else {
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide').whenComplete(() {
        Future<void>.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          change();
        });
      });
    }
  }

  Widget buildCustomKeyBoard() {
    if (!showCustomKeyBoard) {
      return Container();
    }
    if (activeEmojiGird) {
      return buildEmojiGird();
    }
    if (activeAtGrid) {
      return buildAtGrid();
    }
    if (activeDollarGrid) {
      return buildDollarGrid();
    }
    if (activeImageGrid)
      return ImageGrid((TuChongItem item, String text) {
        images.add(item);
        insertText(text);
      }, tuChongRepository);
    return Container();
  }

  Widget buildEmojiGird() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Image.asset(emoji.EmojiUitl.instance.emojiMap['[${index + 1}]']),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            insertText('[${index + 1}]');
          },
        );
      },
      itemCount: emoji.EmojiUitl.instance.emojiMap.length,
      padding: const EdgeInsets.all(5.0),
    );
  }

  Widget buildAtGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemBuilder: (BuildContext context, int index) {
        final String text = atList[index];
        return GestureDetector(
          child: Align(
            child: Text(text),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            insertText(text);
          },
        );
      },
      itemCount: atList.length,
      padding: const EdgeInsets.all(5.0),
    );
  }

  Widget buildDollarGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemBuilder: (BuildContext context, int index) {
        final String text = dollarList[index];
        return GestureDetector(
          child: Align(
            child: Text(text.replaceAll('\$', '')),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            insertText(text);
          },
        );
      },
      itemCount: dollarList.length,
      padding: const EdgeInsets.all(5.0),
    );
  }

  void insertText(String text) {
    final TextEditingValue value = _textEditingController.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textEditingController.value = value.copyWith(
          text: newText,
          selection: value.selection
              .copyWith(baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textEditingController.value = TextEditingValue(
          text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  void manualDelete() {
    //delete by code
    final TextEditingValue _value = _textEditingController.value;
    final TextSelection selection = _value.selection;
    if (!selection.isValid) {
      return;
    }

    TextEditingValue value;
    final String actualText = _value.text;
    if (selection.isCollapsed && selection.start == 0) {
      return;
    }
    final int start = selection.isCollapsed ? selection.start - 1 : selection.start;
    final int end = selection.end;

    value = TextEditingValue(
      text: actualText.replaceRange(start, end, ''),
      selection: TextSelection.collapsed(offset: start),
    );

    final TextSpan oldTextSpan = _mySpecialTextSpanBuilder.build(_value.text);

    value = handleSpecialTextSpanDelete(value, _value, oldTextSpan, null);

    _textEditingController.value = value;
  }
}

class ImageGrid extends StatefulWidget {
  const ImageGrid(this.insertText, this.tuChongRepository);
  final Function(TuChongItem item, String text) insertText;
  final TuChongRepository tuChongRepository;
  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> with AutomaticKeepAliveClientMixin<ImageGrid> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LoadingMoreList<TuChongItem>(ListConfig<TuChongItem>(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
        itemBuilder: (BuildContext context, TuChongItem item, int index) {
          final String url = item.imageUrl;

          ///<img src=‘http://pic2016.5442.com:82/2016/0513/12/3.jpg!960.jpg’/>
          return GestureDetector(
            child: ExtendedImage.network(
              url,
              fit: BoxFit.scaleDown,
            ),
            behavior: HitTestBehavior.translucent,
            onTap: () {
              widget.insertText?.call(item,
                  '<img src=\'$url\' width=\'${item.imageSize.width}\' height=\'${item.imageSize.height}\'/>');
            },
          );
        },
        padding: const EdgeInsets.all(5.0),
        sourceList: widget.tuChongRepository));
  }

  @override
  bool get wantKeepAlive => true;
}
