import 'dart:collection';

import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttersdkv1/widget/CarouselWidget.dart';

import '../main.dart';

class SimpleComponentListView2 extends br.ComponentListView {

  Map<String, dynamic Function(br.Page page, br.ContainerItem item)> components;

  SimpleComponentListView2(
      this.components, List<br.ContainerItem> items, br.Page page)
      : super(items, page);

  @override
  Widget instantiateWidgetByName(
      String ctype, br.ContainerItem item, br.Page page) {
    return components[ctype]?.call(page, item) ??
        ListTile(
          title: Text(item.ctype ?? ''),
          subtitle: Text('not yet defined'),
        );
  }
}
