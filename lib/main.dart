import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:first_app/models/posts.dart';
import 'package:first_app/services/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();

    notifyListeners();
  }

  var favorites = <WordPair>[];

  void saveFavs() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    print('Favorites List $favorites');

    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = APIPosts();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.api),
                    label: Text('API Tests'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var words = appState.current;

    IconData icon = (appState.favorites.contains(words))
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(words: words),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.saveFavs();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
          backgroundColor: colorScheme.primaryContainer,
          title: Text('List Of Your Favorite Words!'),
          titleTextStyle:
              TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 20)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FavList(),
      ),
    );
  }
}

class FavList extends StatefulWidget {
  const FavList({super.key});

  @override
  State<FavList> createState() => _FavListState();
}

class _FavListState extends State<FavList> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    if (appState.favorites.isNotEmpty) {
      return ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: theme.colorScheme.inversePrimary,
              child: DataTable(
                  columnSpacing: 5,
                  dividerThickness: 0.0,
                  dataTextStyle: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                  headingTextStyle: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                  columns: [
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('Favorites'))
                  ],
                  rows: [
                    for (var fav in appState.favorites)
                      DataRow(cells: [
                        DataCell(ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              appState.favorites.remove(fav);
                            });
                          },
                          icon: Icon(Icons.favorite),
                          label: Text('like'),
                        )),
                        DataCell(Text(fav.toString()))
                      ]),
                  ]),
            );
          });
    } else {
      return Text('No favorite words found!');
    }
  }
}

class APIPosts extends StatefulWidget {
  @override
  State<APIPosts> createState() => _APIPostsState();
}

class _APIPostsState extends State<APIPosts> {
  List<Post>? posts;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    posts = await RemoteServices().getPosts();
    if (posts != null) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing API Rest EndPoints'),
      ),
      body: isLoaded
          ? SingleChildScrollView(
              child: Card(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Data')),
                  ],
                  rows: [
                    for (Post post in posts!)
                      DataRow(cells: [DataCell(Text(post.title))])
                  ],
                ),
              ),
            )
          : Center(
              child:
                  CircularProgressIndicator(), // Mostra um indicador de progresso
            ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.words,
  });

  final WordPair words;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          words.asPascalCase,
          style: style,
          semanticsLabel: words.asPascalCase,
        ),
      ),
    );
  }
}
