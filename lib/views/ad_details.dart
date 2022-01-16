import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project/models/ad.dart';
import 'package:project/services/database.dart';
import 'package:provider/provider.dart';

import 'edit_ad.dart';
import 'helpers/empty_content.dart';

class AdDetails extends StatelessWidget {
  AdDetails({required this.ad});

  Ad ad;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamBuilder<Ad>(
        stream: database.adStream(adId: ad.adId!),
        builder: (context, snapshot) {
          final ad = snapshot.data;
          final name = ad?.name ?? '';
          final double price = ad?.price ?? 0;
          final description = ad?.description ?? '';
          final imagesUrls = ad?.imageUrls ?? [];
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 10,
              centerTitle: true,
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditAd.create(
                          context: context,
                          adId: ad!.adId,
                          name: name,
                          price: price,
                          description: description,
                          imageUrls: imagesUrls,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            height: 200,
                            child:
                            imagesUrls.isEmpty
                                ? Center(
                              child: Image.asset(
                                "assets/images/no_image.png",
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200,
                              ),
                            )
                                : CarouselSlider(
                              options: CarouselOptions(
                                enlargeCenterPage: false,
                                enableInfiniteScroll: false,
                                autoPlay: true,
                              ),
                              items: ad!.imageUrls!.map((url) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Image.network(url,
                                      width: 600,
                                      height: 350,
                                      fit: BoxFit.cover,)
                                  ],
                                ) ,
                              )).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            "${price.toString()} LKR",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            description,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
