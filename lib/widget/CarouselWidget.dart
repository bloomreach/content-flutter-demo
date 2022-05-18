import 'package:brcontent/api.dart' as br;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../model/CarouselData.dart';

class CarouselWidget extends br.ComponentStatelessWidget<br.ContainerItem, br.Page> {


  const CarouselWidget({Key? key, required br.ContainerItem item, required br.Page page}) : super(key, item, page);

  @override
  Widget build(BuildContext context) {
    br.ComponentContent? content = getContent();

    CarouselData carouselData = CarouselData.fromJson(content?.data);
    List<Slide> slides = carouselData.slides;

    final List<Widget> imageSliders = slides.map((slide) {
      br.Pointer? imagePointer = slide.image;
      br.Imageset image = page.page[imagePointer?.getReference()] as br.Imageset;
      String imageUrl = image.getImageLink() as String;
      String subtitle = slide.subtitle ?? '';

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
