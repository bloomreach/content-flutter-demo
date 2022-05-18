// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttersdkv1/widget/CarouselWidget.dart';
import 'package:fluttersdkv1/widget/TitleAndTextWidget.dart';

import 'experimental/SimpleComponentListView2.dart';



void main() {
  runApp(BrApplication(
      "https://sandbox-sales02.bloomreach.io", 'mobile-native-demo'));
}

Map<String, dynamic Function(br.Page page, br.ContainerItem item)> getComponentMapping(){
  Map<String, dynamic Function(br.Page page, br.ContainerItem item)>
  components = HashMap();
  components.putIfAbsent(
      "IntroSlider",
          () => (br.Page page, br.ContainerItem item) =>
          CarouselWidget(item: item, page: page));
  components.putIfAbsent(
      "BannerCollection",
          () => (br.Page page, br.ContainerItem item) =>
          BannerCollection(item: item, page: page));
  components.putIfAbsent(
      "TitleAndText",
          () => (br.Page page, br.ContainerItem item) =>
          TitleAndTextWidget(item: item, page: page));
  return components;
}

class BrApplication extends StatefulWidget {
  final String baseUrl;
  final String channelId;

  const BrApplication(this.baseUrl, this.channelId, {Key? key}) : super(key: key);

  @override
  BrApplicationState createState() {
    return BrApplicationState(baseUrl, channelId);
  }
}

class BrApplicationState extends State<BrApplication> {
  final String baseUrl;
  final String channelId;
  late Future<br.Page> page;
  String currentPath = '';
  final Map<String, dynamic Function(br.Page page, br.ContainerItem item)> componentMapping = getComponentMapping();

  @override
  void initState() {
    super.initState();
    this.currentPath = Uri?.base?.path ?? '';
    update();
  }

  void setPage(String newPath) {
    setState(() {
      currentPath = newPath;
      update();
    });
  }

  BrApplicationState(this.baseUrl, this.channelId);

  void update() {
    final String? token = Uri.base.queryParameters["token"];
    final String? serverId = Uri.base.queryParameters["server-id"];
    final String path = currentPath;

    final pageApi = br.PageApi(br.ApiClient(basePath: baseUrl));

    if (token != null && serverId != null) {
      pageApi.apiClient.defaultHeaderMap
          .putIfAbsent("Authorization", () => "Bearer " + token);
      pageApi.apiClient.defaultHeaderMap
          .putIfAbsent("Server-Id", () => serverId);
    }
    this.page = pageApi.getPage(channelId, path.replaceFirst('/', ''))
        as Future<br.Page>;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "path: " + currentPath,
      home: Scaffold(
        drawer: FutureBuilder<br.Page>(
          future: page as Future<br.Page>,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              br.Page page = snapshot.data as br.Page;
              br.Component menuComponent = page.getComponentByPath('menu');
              br.Menu menu = menuComponent.getMenu(page) as br.Menu;

              return NavigationDrawer(page, menu, setPage);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ),
        appBar: AppBar(
          title: FutureBuilder<br.Page>(
            future: page,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                br.Page page = snapshot.data as br.Page;
                return Text(page.getDocument()?.data?['title']);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
        body: FutureBuilder<br.Page>(
          future: page,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              br.Page page = snapshot.data as br.Page;
              br.Container container = page.getComponentByPath('container');
              var items = container.getComponents(page);

              return SimpleComponentListView2(componentMapping, items, page);
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

class NavigationDrawer extends StatelessWidget {
  final br.Page page;
  final br.Menu menu;
  final void Function(String newPath) setPath;

  NavigationDrawer(this.page, this.menu, this.setPath);

  void onMenuItemClicked(BuildContext context, String newPath) {
    setPath(newPath);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = menu
        ?.getSiteMenuItems()
        ?.map((item) => buildMenuItem(
            text: item.name ?? '',
            onClicked: () =>
                onMenuItemClicked(context, item.getLink() as String)))
        .toList() as List<Widget>;
    return Drawer(
        child: Container(
            color: Colors.blue,
            child: Column(
              children: items,
            )));
  }

  Widget buildMenuItem({
    required String text,
    // required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      // leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
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
