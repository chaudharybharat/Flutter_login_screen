import 'package:flutter/material.dart';

Widget _buildTile(BuildContext context, int index) {
  return new ListTile(
    title: new Text("Item $index"),
  );
}

const tabCount = 2;

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.yellow),
      home: new TestAppHomePage(),
    );
  }
}

class TestTabBarDelegate extends SliverPersistentHeaderDelegate {
  TestTabBarDelegate({this.controller});

  final TabController controller;

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context).cardColor,
      height: kToolbarHeight,
      child: new TabBar(
        controller: controller,
        key: new PageStorageKey<Type>(TabBar),
        indicatorColor: Theme.of(context).primaryColor,
        tabs: <Widget>[
          new Tab(text: 'one'),
          new Tab(text: 'two'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TestTabBarDelegate oldDelegate) {
    return oldDelegate.controller != controller;
  }
}

class TestAppHomePage extends StatefulWidget {
  @override
  TestAppHomePageState createState() => new TestAppHomePageState();
}

class TestAppHomePageState extends State<TestAppHomePage>
    with TickerProviderStateMixin {
  ScrollController _scrollController = new ScrollController();

  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: tabCount, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Test Title'),
        elevation: 0.0,
      ),
      body: new NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                _buildTile,
                childCount: 12,
              ),
            ),
            new SliverPersistentHeader(
              pinned: true,
              delegate: new TestTabBarDelegate(controller: _tabController),
            ),
          ];
        },
        body: new TestHomePageBody(
          tabController: _tabController,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}

class TestHomePageBody extends StatefulWidget {
  TestHomePageBody({this.scrollController, this.tabController});

  final ScrollController scrollController;
  final TabController tabController;

  TestHomePageBodyState createState() => new TestHomePageBodyState();
}

class TestHomePageBodyState extends State<TestHomePageBody> {
  Key _key = new PageStorageKey({});
  bool _innerListIsScrolled = false;

  void _updateScrollPosition() {
    if (!_innerListIsScrolled &&
        widget.scrollController.position.extentAfter == 0.0) {
      setState(() {
        _innerListIsScrolled = true;
      });
    } else if (_innerListIsScrolled &&
        widget.scrollController.position.extentAfter > 0.0) {
      setState(() {
        _innerListIsScrolled = false;
        // Reset scroll positions of the TabBarView pages
        _key = new PageStorageKey({});
      });
    }
  }

  @override
  void initState() {
    widget.scrollController.addListener(_updateScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new TabBarView(
      controller: widget.tabController,
      key: _key,
      children: new List<Widget>.generate(tabCount, (int index) {
        return new ListView.builder(
          key: new PageStorageKey<int>(index),
          itemBuilder: _buildTile,
        );
      }),
    );
  }
}
