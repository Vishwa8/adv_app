import 'package:flutter/material.dart';
import 'package:project/models/ad.dart';

class AdCard extends StatelessWidget {
  final Ad ad;
  final VoidCallback onTap;

  AdCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10, left: 10),
        child: Card(
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  child: ad.imageUrls!.isNotEmpty ?  Image.network(
                    ad.imageUrls!.first,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ) : Container(
                    child: Image.asset(
                      "assets/images/no_image.png",
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${ad.name}",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      "${ad.price} LKR",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
