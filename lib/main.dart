import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './models/movieModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import './movieDetails.dart';
import './models/movieDetailModel.dart';

const baseUrl = "https://api.themoviedb.org/3/movie/";
const baseImagesUrl = "https://image.tmdb.org/t/p/";
const apiKey = "bd1672a0bdccd4ee8fe84bb509a8fa40";

const nowPlayingUrl = "${baseUrl}now_playing?api_key=$apiKey&language=es";
//const upcomingUrl = "${baseUrl}upcoming?api_key=$apiKey&language=es";
//const popularUrl = "${baseUrl}popular?api_key=$apiKey&language=es";
//const topRatedUrl = "${baseUrl}top_rated?api_key=$apiKey&language=es";

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: MyMovieApp(),
    ));

class MyMovieApp extends StatefulWidget {
  @override
  _MyMovieApp createState() => new _MyMovieApp();
}

class _MyMovieApp extends State<MyMovieApp> {
  Movie nowPlayingMovies;
  Movie upcomingMovies;
  Movie popularMovies;
  Movie topRatedMovies;
  int heroTag = 0;
  int _currentIndex = 0;

  //Paginacion
  int _pageNumberUC = 1;
  int _totalItemsUC = 0;

  int _pageNumberPo = 1;
  int _totalItemsPo = 0;

  int _pageNumberTR = 1;
  int _totalItemsTR = 0;

  @override
  void initState() {
    super.initState();
    _fetchNowPlayingMovies();
    _fetchUpcomingMovies();
    _fetchPopularMovies();
    _fetchTopRatedMovies();
  }

  void _fetchNowPlayingMovies() async {
    var response = await http.get(nowPlayingUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decodeJson);
    });
  }

  void _fetchUpcomingMovies() async {
    var response = await http.get(
        "${baseUrl}upcoming?api_key=$apiKey&language=es&page=$_pageNumberUC");
    var decodeJson = jsonDecode(response.body);
    upcomingMovies == null
        ? upcomingMovies = Movie.fromJson(decodeJson)
        : upcomingMovies.results.addAll(Movie.fromJson(decodeJson).results);
    setState(() {
      _totalItemsUC = upcomingMovies.results.length;
    });
  }

  void _fetchPopularMovies() async {
    var response = await http.get(
        "${baseUrl}popular?api_key=$apiKey&language=es&page=$_pageNumberPo");
    var decodeJson = jsonDecode(response.body);
    popularMovies == null
        ? popularMovies = Movie.fromJson(decodeJson)
        : popularMovies.results.addAll(Movie.fromJson(decodeJson).results);
    setState(() {
      _totalItemsPo = popularMovies.results.length;
    });
  }

  void _fetchTopRatedMovies() async {
    var response = await http.get(
        "${baseUrl}top_rated?api_key=$apiKey&language=es&page=$_pageNumberTR");
    var decodeJson = jsonDecode(response.body);
    topRatedMovies == null
        ? topRatedMovies = Movie.fromJson(decodeJson)
        : topRatedMovies.results.addAll(Movie.fromJson(decodeJson).results);
    setState(() {
      _totalItemsTR = topRatedMovies.results.length;
    });
  }

  Widget _buildCarouselSlider() => CarouselSlider(
        items: nowPlayingMovies == null
            ? <Widget>[Center(child: CircularProgressIndicator())]
            : nowPlayingMovies.results
                .map((movieItem) => _buildmovieItem(movieItem))
                .toList(),
        autoPlay: false,
        height: 240.0,
        viewportFraction: 0.5,
      );

  Widget _buildmovieItem(Results movieItem) {
    heroTag += 1;
    movieItem.heroTag = heroTag;
    return Material(
        elevation: 15.0,
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MovieDetail(movie: movieItem)));
            },
            child: Hero(
                tag: heroTag,
                child: movieItem.posterPath != null
                    ? Image.network(
                        "${baseImagesUrl}w342${movieItem.posterPath}",
                        fit: BoxFit.cover)
                    : Image.asset('assets/no_img.jpg'))));
  }

  Widget _buildMovieListItem(Results movieItem) => Material(
      child: Container(
          width: 128.0,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(6.0),
                    child: _buildmovieItem(movieItem)),
                Padding(
                  padding: EdgeInsets.only(left: 6.0, top: 2.0),
                  child: Text(movieItem.title,
                      style: TextStyle(fontSize: 8.0),
                      overflow: TextOverflow.ellipsis),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 6.0, top: 2.0),
                    child: Text(
                      DateFormat('yyyy')
                          .format(DateTime.parse(movieItem.releaseDate)),
                      style: TextStyle(fontSize: 8.0),
                    )),
              ])));

  Widget _buildMoviesListView(Movie movie, String movieListTitle, int genero) =>
      Container(
        height: 258.0,
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 7.0, bottom: 7.0),
                child: Text(movieListTitle,
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold)),
              ),
              Flexible(
                  child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: genero == 1
                    ? _totalItemsUC
                    : (genero == 2
                        ? _totalItemsPo
                        : (genero == 3 ? _totalItemsTR : 0)),
                itemBuilder: (BuildContext content, int index) {
                  if (index >= movie.results.length - 1) {
                    if (genero == 1) {
                      _pageNumberUC++;
                      _fetchUpcomingMovies();
                    }
                    if (genero == 2) {
                      _pageNumberPo++;
                      _fetchPopularMovies();
                    }
                    if (genero == 3) {
                      _pageNumberTR++;
                      _fetchTopRatedMovies();
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(left: 6.0, right: 2.0),
                    child: _buildMovieListItem(movie.results[index]),
                  );
                },
              )),
            ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            'Movies App',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('NOW PLAYING',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  expandedHeight: 290.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: <Widget>[
                        Container(
                          child: Image.network(
                            "${baseImagesUrl}w500/qJ2H94PpXxZgiGGUNkyLSKZzm8u.jpg",
                            fit: BoxFit.cover,
                            width: 1000.0,
                            colorBlendMode: BlendMode.dstATop,
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 35.0),
                            child: _buildCarouselSlider())
                      ],
                    ),
                  ),
                )
              ];
            },
            body: ListView(
              children: <Widget>[
                _buildMoviesListView(
                    upcomingMovies, 'COMING SOON ($_pageNumberUC)', 1),
                _buildMoviesListView(
                    popularMovies, 'POPULAR ($_pageNumberPo)', 2),
                _buildMoviesListView(
                    topRatedMovies, 'TOP RATED ($_pageNumberTR)', 3),
              ],
            )),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.lightBlue,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_movies),
              title: Text('All Movies'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text('Tickets'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Account'),
            ),
          ],
        ));
  }
}
