// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
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
    String? path = Uri.base.path ?? '';

    final instance = br.PageApi(
        br.ApiClient(basePath: 'https://sandbox-sales02.bloomreach.io'));

    if (token != null && serverId != null) {
      instance.apiClient.defaultHeaderMap
          .putIfAbsent("Authorization", () => "Bearer " + token);
      instance.apiClient.defaultHeaderMap
          .putIfAbsent("Server-Id", () => serverId);
    }
    this.page = instance.getPage('bauhaus-mobile', path.replaceFirst('/', '')) as Future<br.Page>;
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
        body: FutureBuilder<br.Page>(
          future: page as Future<br.Page>,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              br.Page page = snapshot.data as br.Page;
              br.Container container = page.getComponentByPath('container');
              var items = container.getComponents(page);

              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  switch (item.ctype) {
                    case 'BannerCollection':
                      return BannerCollection(item: item, page: page);
                    case 'TitleAndText':
                      return TitleAndText(item: item, page: page);
                    case 'IntroSlider':
                      return Carousel(item: item, page: page);
                    default:
                      return ListTile(
                        title: Text(item.ctype ?? ''),
                        subtitle: Text('not yet defined'),
                      );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class Carousel extends StatelessWidget {
  final br.ContainerItem? item;
  final br.Page? page;

  const Carousel({Key? key, this.item, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var content = item?.getContent(page!);

    List<dynamic> slides = content?.getData('slides');

    final List<Widget> imageSliders = slides.map((slide) {
      br.Pointer imagePointer =
          br.Pointer.fromJson(slide['image']) as br.Pointer;
      br.Imageset image =
          page?.page[imagePointer.getReference()] as br.Imageset;
      String imageUrl = image.getImageLink() as String;
      String subtitle = slide['subtitle'];

      return Container(
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Image.network(imageUrl, fit: BoxFit.cover, width: 1000.0),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      );
    }).toList();

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 2.0,
        enlargeCenterPage: true,
      ),
      items: imageSliders,
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
    String text = content?.getData("text");
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(children: [
          Text(content?.getData("title"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 8,
          ),
          Center(child: MarkdownBody(data: content?.getData("text"))),
        ]));
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

    return Column(
        children: banners.map((banner) {
      String message = banner['subtitle'];
      String title = banner['text'];
      br.Pointer imagePointer =
          br.Pointer.fromJson(banner['image']) as br.Pointer;
      br.Imageset image =
          page?.page[imagePointer.getReference()] as br.Imageset;
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
