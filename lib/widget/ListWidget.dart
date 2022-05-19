import 'package:brcontent/api.dart' as br;
import 'package:flutter/material.dart';

class ListWidget
    extends br.ComponentStatelessWidget<br.ContainerItem, br.Page> {
  ListWidget(
      {Key? key,
      required br.ContainerItem item,
      required br.Page page,
      required void Function(String newPath)? setPage})
      : super(key, item, page, setPage);

  @override
  Widget build(BuildContext context) {
    var pagination = item.getPagination(page);
    var items = pagination?.getItems(page);

    return Column(
      children: items
              ?.map((document) => ListTile(
                    title: Text(document.data?['title']),
                    subtitle: Text(document.data?['description']),
                    onTap: () => {
                      this.setPage?.call(document.links['site']?.href ?? '')
                    },
                  ))
              .toList() ??
          List<Widget>.empty(),
    );
  }
}
