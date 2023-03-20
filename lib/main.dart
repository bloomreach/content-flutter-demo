// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:bloomreachdemo/widget/ListWidget.dart';
import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';
import 'package:bloomreachdemo/widget/BannerCollection.dart';
import 'package:bloomreachdemo/widget/CarouselWidget.dart';
import 'package:bloomreachdemo/widget/TitleAndTextWidget.dart';


getComponentMapping() {
  Map<String, dynamic Function(br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage])>
  components = HashMap();
  components.putIfAbsent(
      "IntroSlider",
          () => (br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage]) =>
          CarouselWidget(item: item, page: page));
  components.putIfAbsent(
      "BannerCollection",
          () => (br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage]) =>
          BannerCollection(item: item, page: page));
  components.putIfAbsent(
      "TitleAndText",
          () => (br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage]) =>
          TitleAndTextWidget(item: item, page: page));
  components.putIfAbsent(
      "List",
          () => (br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage]) =>
          ListWidget(item: item, page: page, setPage: setPage));
  return components;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //https://trial-3csawakw.bloomreach.io/delivery/site/v1/channels/flutter-demo/pages/
  runApp(DemoApplication("https://sandbox-sales06.bloomreach.io", 'flutter-demo', getComponentMapping()));
}

class DemoApplication extends br.Application {

  DemoApplication(String baseUrl, String channelId,Map<String, Function(br.Page page, br.ContainerItem item, [void Function(String newPath)? setPage])> componentMapping)
      : super(baseUrl, channelId, componentMapping);

  @override
  br.ApplicationState<br.Application> createState() {
    return DemoApplicationState();
  }
}

class DemoApplicationState extends br.ApplicationState {

  @override
  Widget buildPage(BuildContext context, br.Page page) {
    br.Component menuComponent = page.getComponentByPath('menu');
    br.Menu menu = menuComponent.getMenu(page) as br.Menu;

    br.Container container = page.getComponentByPath('container');

    return MaterialApp(
      title: page.getDocument()?.getData('title'),
      home: Scaffold(
        drawer: NavigationDrawer(page, menu, setPage),
        appBar: AppBar(
          backgroundColor: Color(0xFF002840),
          title: Text(page.getDocument()?.getData('title')),
        ),
        body: br.ContainerItemComponentsListView(componentMapping, container, page, setPage),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final br.Page page;
  final br.Menu menu;
  final void Function(String newPath) setPath;
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const NavigationDrawer(this.page, this.menu, this.setPath, {Key? key})
      : super(key: key);

  void onMenuItemClicked(BuildContext context, String newPath) {
    setPath(newPath);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = []
      ..add(SizedBox(height: 40))
      ..add(Image.network(
        "https://sandbox-sales02.bloomreach.io/delivery/resources/content/gallery/logo/br-logo-primary.png",
        fit: BoxFit.cover,
      ))
      ..add(SizedBox(height: 20))
      ..addAll(menu.getSiteMenuItems().map((item) => buildMenuItem(
          icon: Icons.arrow_forward_outlined,
          text: item.name ?? '',
          onClicked: () => onMenuItemClicked(context, item.getLink() ?? ''))));

    return Drawer(
      child: Material(
        color: Colors.white,
        child: Container(
          padding: padding,
          child: Column(
            children: items,
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    VoidCallback? onClicked,
  }) {
    final color = Color(0xFF002840);

    return ListTile(
      trailing: Icon(icon, color: color),
      // leading:
      title: Text(text, style: TextStyle(color: color)),
      onTap: onClicked,
    );
  }
}
