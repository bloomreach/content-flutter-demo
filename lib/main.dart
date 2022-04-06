// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<br.Page> page;

  void update() {
    String? token = Uri.base.queryParameters["token"];
    String? serverId = Uri.base.queryParameters["server-id"];

    if (token != null && serverId != null) {
      final instance = br.PageApi(
          br.ApiClient(basePath: 'https://sandbox-sales02.bloomreach.io'));
      instance.apiClient.defaultHeaderMap
          .putIfAbsent("Authorization", () => "Bearer " + token);
      instance.apiClient.defaultHeaderMap
          .putIfAbsent("Server-Id", () => serverId);
      print(instance.apiClient.defaultHeaderMap);
      this.page = instance.getPage('bauhaus-mobile', '') as Future<br.Page>;
    } else {
      final instance = br.PageApi(
          br.ApiClient(basePath: 'https://sandbox-sales02.bloomreach.io'));
      this.page = instance.getPage('bauhaus-mobile', '') as Future<br.Page>;
    }
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "flutter demo - bauhaus-mobile",
      home: Scaffold(
        appBar: AppBar(
          title: Text("flutter demo - bauhaus-mobile"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      update();
                    });
                  },
                  child: Icon(
                    Icons.refresh,
                    size: 26.0,
                  ),
                ))
          ],
        ),
        body: Center(
          child: FutureBuilder<br.Page>(
            future: page as Future<br.Page>,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                br.Page page = snapshot.data as br.Page;
                br.Container container =
                    page.getComponentByPath('container') as br.Container;

                var items = container.getComponents(page);
                return Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                      // scrollDirection: Axis.vertical,
                      // shrinkWrap: true,
                      // Let the ListView know how many items it needs to build.
                      itemCount: items.length,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      itemBuilder: (context, index) {
                        final item = items[index];

                        if (item.ctype == 'BannerCollection') {
                          return BannerCollection(item: item, page: page);
                        } else if (item.ctype == 'TitleAndText') {
                          return TitleAndText(item: item, page: page);
                        }

                        return ListTile(
                          title: Text(item.name ?? ''),
                          subtitle: Text(item.ctype ?? ''),
                        );
                      },
                    ))
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class TitleAndText extends StatelessWidget {
  final br.ContainerItem? item;
  final br.Page? page;

  const TitleAndText({Key? key, this.item, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var content = this.item?.getContent(this.page as br.Page);
    return Column(children: [Text(content?.getData("title")), SizedBox(height: 100,child: Markdown(data: content?.getData("text")))]);
  }
}

class BannerCollection extends StatelessWidget {
  final br.ContainerItem? item;
  final br.Page? page;

  const BannerCollection({Key? key, this.item, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> banners =
        this.item?.getContent(this.page as br.Page)?.getData("banners");

    return ListView.builder(
      shrinkWrap: true,
      itemCount: banners.length,
      itemBuilder: (context, i) {
        dynamic banner = banners[i];
        String message = banner['subtitle'];
        String title = banner['text'];
        br.Pointer imagePointer =
            br.Pointer.fromJson(banner['image']) as br.Pointer;
        br.Imageset image =
            page?.page[imagePointer.getReference()] as br.Imageset;
        String imageUrl = image.getImageLink() as String;

        return Container(
          margin: const EdgeInsets.all(10.0),
          child: ClipRect(
            /** Banner Widget **/
            child: Banner(
              message: message,
              location: BannerLocation.bottomStart,
              color: Colors.red,
              child: Container(
                color: Colors.grey[100],
                height: 320,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Column(
                    children: <Widget>[
                      Image.network(imageUrl),
                      SizedBox(height: 10),
                      ElevatedButton(
                        child: Text(title),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        onPressed: () {},
                      )
                      //RaisedButton
                    ], //<Widget>[]
                  ), //Column
                ), //Padding
              ), //Container
            ), //Banner
          ), //ClipRect
        );
      },
    );
  }
}
