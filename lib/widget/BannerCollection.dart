import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';

class BannerCollection
    extends br.ComponentStatelessWidget<br.ContainerItem, br.Page> {
  BannerCollection(
      {Key? key, required br.ContainerItem item, required br.Page page})
      : super(key, item, page);

  @override
  Widget build(BuildContext context) {
    List<dynamic> banners =
        this.item.getContent(this.page as br.Page)?.getData("banners");

    return Column(
        children: banners.map((banner) {
      String message = banner['subtitle'];
      String title = banner['text'];
      br.Pointer imagePointer =
          br.Pointer.fromJson(banner['image']) as br.Pointer;
      br.Imageset image =
          page.page[imagePointer.getReference()] as br.Imageset;
      String imageUrl = image.getImageLink() as String;
      return ClipRect(
          /** Banner Widget **/
          child: Banner(
        message: message,
        location: BannerLocation.topEnd,
        color: Colors.red,
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              children: <Widget>[
                Image.network(imageUrl),
                SizedBox(height: 5),
                ElevatedButton(
                  child: Text(title),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: () {},
                )
                //RaisedButton
              ], //<Widget>[]
            ), //Column
          ), //Padding
        ), //Container
      ));
    }).toList());
  }
}
