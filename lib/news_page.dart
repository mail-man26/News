import 'package:flutter/material.dart';
import 'package:flutter_news_app/news_web_view.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  bool isDarkMode = false;
  late Future<List<Article>> future;
  String? searchTerm;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<String> categoryItems = [
    "GENERAL",
    "BUSINESS",
    "ENTERTAINMENT",
    "HEALTH",
    "SCIENCE",
    "SPORTS",
    "TECHNOLOGY",
  ];

  late String selectedCategory;
  Set<String> bookmarks = {};

  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    selectedCategory = categoryItems[0];
    future = getNewsData();
    initializeSharedPreferences();
    super.initState();
  }

  Future<void> initializeSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadBookmarks();
  }

  void loadBookmarks() {
    bookmarks = sharedPreferences.getStringList('bookmarks')?.toSet() ?? {};
  }

  Future<void> saveBookmarks() async {
    await sharedPreferences.setStringList('bookmarks', bookmarks.toList());
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI("bc9c663f14bb46e9bac9c584eef667e1");
    return await newsAPI.getTopHeadlines(
      country: "us",
      query: searchTerm,
      category: selectedCategory,
      pageSize: 50,
    );
  }

  void toggleThemeMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 20,
          onTap: (context) {},
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.new_label_rounded),
                activeIcon: Icon(Icons.new_label_outlined),
                label: 'Feed'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_add_outlined),
                activeIcon: Icon(Icons.bookmark_added_rounded),
                label: 'Bookmarked'),
          ]),
      appBar: isSearching ? searchAppBar() : appBar(),
      body: SafeArea(
          child: Column(
        children: [
          _buildCategories(),
          Expanded(
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error loading the news"),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildNewsListView(snapshot.data as List<Article>);
                  } else {
                    return const Center(
                      child: Text("No news available"),
                    );
                  }
                }
              },
              future: future,
            ),
          )
        ],
      )),
    );
  }

  searchAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchTerm = null;
            searchController.text = "";
            future = getNewsData();
          });
        },
      ),
      title: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                searchTerm = searchController.text;
                future = getNewsData();
              });
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: Colors.lightBlue,
      title: const Text(
        "My News",
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      actions: [
        IconButton(
          onPressed: toggleThemeMode,
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = true;
            });
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        itemBuilder: (context, index) {
          Article article = articleList[index];
          return _buildNewsItem(article);
        },
        itemCount: articleList.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
      ),
    );
  }

  Widget _buildNewsItem(Article article) {
    bool isBookmarked = bookmarks.contains(article.url!);

    return InkWell(
      hoverColor: Colors.amberAccent,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsWebView(url: article.url!),
            ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(6),
                  bottomLeft: Radius.circular(6))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    article.urlToImage ?? "",
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  )),
              SizedBox(
                height: 12,
              ),
              Text(
                article.title!,
                maxLines: 2,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                article.content!,
                maxLines: 4,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsWebView(url: article.url!),
                            ));
                      },
                      icon: Icon(Icons.read_more),
                      label: Text('Read more')),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (isBookmarked) {
                          bookmarks.remove(article.url);
                        } else {
                          bookmarks.add(article.url!);
                        }
                        saveBookmarks();
                      });
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.lightBlue : null,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory = categoryItems[index];
                  future = getNewsData();
                });
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                categoryItems[index] == selectedCategory
                    ? Colors.lightBlue.withOpacity(0.5)
                    : Colors.blue,
              )),
              child: Text(categoryItems[index]),
            ),
          );
        },
        itemCount: categoryItems.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
