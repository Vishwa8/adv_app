import 'package:flutter/material.dart';
import 'package:project/services/database.dart';
import 'package:project/views/ad_details.dart';
import 'package:project/views/helpers/ad_card.dart';
import 'package:project/views/price_filter.dart';
import 'package:provider/provider.dart';
import 'add_new_ad.dart';
import 'package:project/models/ad.dart';

import 'helpers/list_items_builder.dart';

class HomePage extends StatelessWidget {

  Future<void> _delete(BuildContext context, Ad ad) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteAd(ad);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 10,
          centerTitle: true,
          title: const Text(
            "ADV APP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                child: Card(
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        child: Text(
                          "Price",
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        margin: const EdgeInsets.all(4),
                      ),
                      InkWell(
                        onTap: () => _submit(context, "low"),
                        child: const Card(
                          child: Text("\$"),
                          margin: EdgeInsets.all(4),
                          elevation: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () => _submit(context, "medium"),
                        child: const Card(
                          child: Text("\$\$"),
                          margin: EdgeInsets.all(4),
                          elevation: 2,
                        ),
                      ),
                      InkWell(
                        onTap: () => _submit(context, "high"),
                        child: const Card(
                          child: Text("\$\$\$"),
                          margin: EdgeInsets.all(4),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _buildContents(context),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddNewAd.create(context)));
          },
          child: const Icon(Icons.add),
          backgroundColor: Theme
              .of(context)
              .primaryColor,
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Ad>>(
      stream: database.adsStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Ad>(
          snapshot: snapshot,
          itemBuilder: (context, ad) =>
              Dismissible(
                key: Key('ad-${ad.adId}'),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => _delete(context, ad),
                child: AdCard(
                  ad: ad,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AdDetails(
                              ad: ad,
                            ),
                      ),
                    );
                  },
                ),
              ),
        );
      },
    );
  }

  Future<void> _submit(context, value) async {
    double minPrice = 0;
    double maxPrice = 0;

    if (value == "low") {
      minPrice = 0;
      maxPrice = 1000;
    } else if (value == "medium") {
      minPrice = 1000;
      maxPrice = 2000;
    } else if (value == "high") {
      minPrice = 2000;
      maxPrice = 3000;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          PriceFilter(
            minPrice: minPrice,
            maxPrice: maxPrice,
          ),
      ),
    );
  }
}
