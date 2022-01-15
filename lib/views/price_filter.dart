import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/models/ad.dart';
import 'package:project/services/database.dart';
import 'package:provider/provider.dart';

import 'ad_details.dart';
import 'helpers/ad_card.dart';
import 'helpers/list_items_builder.dart';

class PriceFilter extends StatelessWidget {
  PriceFilter({
   required this.minPrice,
   required this.maxPrice,
});

  double minPrice = 0;
  double maxPrice = 100000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: const Text(
          "Price Filter",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: _buildContents(context),
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Ad>>(
      stream: database.filteredAdsStream(minPrice, maxPrice),
      builder: (context, snapshot) {
        return ListItemsBuilder<Ad>(
          snapshot: snapshot,
          itemBuilder: (context, ad) =>  AdCard(
              ad: ad,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdDetails(
                      ad: ad,
                    ),
                  ),
                );
              },
            ),
          );
      },
    );
  }
}


