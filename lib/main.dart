import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

ValueNotifier<List> products = ValueNotifier([]);
ValueNotifier<bool> isLoading = ValueNotifier(false);
ValueNotifier<List> cartItems = ValueNotifier([]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: DefaultTabController(
        length: 2,
        child: const MyHomePage(title: 'PDV'),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDV"),
        bottom: const TabBar(tabs: [
          Tab(
            icon: Icon(Icons.list),
            text: "Catalogo",
          ),
          Tab(
            icon: Icon(Icons.shopping_cart),
            text: "Carrinho",
          ),
        ]),
      ),
      body: TabBarView(
        children: [
          const Catalog(),
          Cart(),
        ],
      ),
    );
  }
}

class Catalog extends HookWidget {
  const Catalog({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> getProducts() async {
      isLoading.value = true;
      var productsUrl = Uri(host: "fakestoreapi.com", path: "/products");
      var jsonString = http.read(productsUrl);
      var json = await jsonString;
      isLoading.value = false;
      products.value = jsonDecode(json);
    }

    useEffect(() {
      getProducts();
    }, []);

    return ValueListenableBuilder<List>(
      valueListenable: products,
      builder: (context, value, child) {
        return isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            value[index]["image"].toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            value[index]["title"].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            value[index]["description"].toString(),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10),
                          child: Text("R\$" + value[index]["price"].toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextButton(
                                onPressed: () {
                                  cartItems.value.add(value[index]);
                                },
                                child: const Text("Adicionar ao carrinho"),
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(20)),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}

class Cart extends HookWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List>(
      valueListenable: cartItems,
      builder: (context, value, child) {
        return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            return isLoading.value
                ? const CircularProgressIndicator()
                : ListTile(
                    leading: Container(
                        width: 100,
                        child: Image.network(
                          value[index]["image"],
                          fit: BoxFit.cover,
                        )),
                    title: Text(
                      value[index]["title"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      " R\$" + value[index]["price"].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        cartItems.value.removeAt(index);
                      },
                    ),
                  );
          },
        );
      },
    );
  }
}
