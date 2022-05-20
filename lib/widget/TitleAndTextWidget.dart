import 'package:brcontent/api.dart' as br;
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TitleAndTextWidget
    extends br.ComponentStatelessWidget<br.ContainerItem, br.Page> {

  TitleAndTextWidget(
      {Key? key, required br.ContainerItem item, required br.Page page})
      : super(key, item, page);

  @override
  Widget build(BuildContext context) {
    br.ComponentContent? content = getContent();

    return Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(children: [
          Text(content?.getData("title"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Center(child: MarkdownBody(data: content?.getData("text"))),
        ]));
  }
}
