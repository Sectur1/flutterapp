import 'dart:core';
import 'dart:core' as prefix0;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/rendering.dart';
import 'classes.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'posts.dart';
import 'user.dart';
import 'shops.dart';
final String url = 'http://172.17.0.1:8080';
final storage = new FlutterSecureStorage();
Dio dio = new Dio();
var cookieJar = CookieJar();
double fontSize = 15;
Color fontColor = Colors.black;
Future<void> main() async{
  await storage.read(key: 'status').then((val){
    val == 'loggedin'?runApp(
    FutureBuilder(
      future: storage.read(key: 'sessionid'),
      builder: (BuildContext context,snapshot){
        if(snapshot.hasData){
          return Provider<String>.value(
              value: snapshot.data.toString(),
              child: FutureBuilder(
                future: dio.get(url+'/user',options: Options(headers: {'cookie':'sessionid=${snapshot.data.toString()}'})),
                builder:(BuildContext context,snapshot){
                  if(snapshot.hasData&&snapshot.data.toString() !='error'){
                    var user = jsonDecode(snapshot.data.toString());
                    return Provider<Map>.value(
                      value: user,
                      child: MaterialApp(
                      theme: ThemeData(
                      primarySwatch: Colors.blue,
                    ),
                    home: Home(),
                    )
                  );
                  }else if(snapshot.hasError||snapshot.data.toString() =='error'){
                    return ErrorWidget();
                  }else{
                    return Container(color: Colors.white,child: Center(child: CircularProgressIndicator(),));
                  }
              },
            ),
          );
        }else{
          return LoginSignup();
        }
      },
    )
  ):runApp(
       LoginSignup(),
  );
  });
  
} 

class LoginSignup extends StatefulWidget{
  LoginSignupState createState()=>LoginSignupState();
}
class NotificationPage extends StatefulWidget{
  NotificationPage({Key key,this.shop,this.search,this.notifications,this.home}):super(key:key);
  final shop,search,notifications,home;
  NotificationPageState createState()=>NotificationPageState();
}
class HomePage extends StatefulWidget {
  HomePage({Key key, this.shop,this.home,this.search,this.notifications}) : super(key: key);
  final shop,search,notifications,home;
  @override
  _HomePageState createState() => _HomePageState();
}

class Home extends StatefulWidget{
  Home({Key key, this.title}):super(key:key);
  final String title;
  HomeState createState()=> HomeState(); 
}

class SearchPage extends StatefulWidget{
  SearchPage({Key key,this.shop,this.search,this.notifications,this.home}):super(key:key);
  final shop,search,notifications,home;
  SearchPageState createState()=>SearchPageState();
}

class MenuPage extends StatefulWidget{
  MenuPage({Key key}):super(key:key);
  MenuState createState()=>MenuState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venmun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Venmun'),
    );
  }
}

class MenuState extends State<MenuPage>{
  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(children: <Widget>[
        Container(child: RaisedButton(color: Colors.white,child: Row(children:<Widget>[
          Container(margin: EdgeInsets.only(right: 10),child: Icon(Icons.payment,color: Colors.blueAccent,)),
          Text('Payments',style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),)
        ],),
        onPressed: (){},
        ),
        width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
        Container(child: RaisedButton(color: Colors.white,child: Row(
          children: <Widget>[
            Container(margin: EdgeInsets.only(right: 10),child: Icon(Icons.add_shopping_cart,color: Colors.blueAccent,),),
            Text('Orders',style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),),
          ],
        ),
        onPressed: (){},
        ),
        width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),)
      ],),
    );
  }
}
class ErrorWidget extends StatelessWidget{
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        title: "Venmun",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
        appBar: AppBar(title:Text('Venmun')),
        body: SafeArea(
          child: Center(
            child: RaisedButton(color: Colors.white,
              child: Text('Sorry an error occurred. Click to try again', style: TextStyle(fontSize: 20,color: Colors.redAccent),),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
              },
            ),
          ),
        ),
      ),
    );
  } 
}
class LoginSignupState extends State<LoginSignup>{
  String page = 'login';  
  @override
  Widget build(BuildContext context){
    PageController _pageController = PageController();
    return MaterialApp(
          theme: ThemeData(
          primaryColor: Colors.white,
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body:Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.png'))),
            child:PageView(
            controller: _pageController,
            children: <Widget>[
              Login(),
              Signup()
            ],
          )),
          bottomNavigationBar: BottomNavigationBar(onTap: (index){index==0?setState(()=>page='login'):setState(()=>page='signup');
          _pageController.animateToPage(index,duration: Duration(seconds: 1),curve: Curves.linearToEaseOut);},
            items: [
            BottomNavigationBarItem(icon:Icon(Icons.person,color: page=='login'?Colors.blueAccent:Colors.grey,),title: Text('Login',style: TextStyle(color: page=='login'?Colors.blueAccent:Colors.grey,),),),
            BottomNavigationBarItem(icon:Icon(Icons.person_add,color: page!='login'?Colors.blueAccent:Colors.grey,),title: Text('Signup',
            style: TextStyle(color: page!='login'?Colors.blueAccent:Colors.grey,),))
          ],),
      ),
    );
  }
}

class HomeState extends State<Home>{
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  PageController _pageController = PageController();
  ScrollController _intialPostPageController = ScrollController();
  ScrollController _postPageController = ScrollController();
  Color bgcolor = Colors.blueAccent.withOpacity(1);
  Color ic = Colors.blueAccent.withOpacity(1);
  GlobalKey fKey = GlobalKey();
  double elevation = 1;
  GlobalKey drawerKey = GlobalKey();  
  double postOffset=0;
  var size = 0,recommend,dontRecommend,storedPosts = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _listChildren(data){
    var items = <Widget> [];
    var parsedTags = data.split(',');
    for (var i = 0; i < parsedTags.length; i++) { 
      items.add(Text('${i+1}. ${parsedTags[i]}',style: TextStyle(fontSize: 20,color: Colors.grey),)); 
    }
    return items;
  }
  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Scaffold(
        key: _key,
        backgroundColor: Colors.white,  
        appBar: AppBar(title: Container(child: Image.asset('assets/logo1024.png',width: 80),height: 50,),backgroundColor: Colors.white,
          actions: <Widget>[FlatButton(
            onPressed: (){_key.currentState.showSnackBar(SnackBar(duration: Duration(days: 1),content: Container(
            child: Column(children: <Widget>[
              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.blueAccent,),height: 30,padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/4),
              width: MediaQuery.of(context).size.width,
                child: GestureDetector(child: Text(Provider.of<Map>(context)['name'],overflow: TextOverflow.clip,style:TextStyle(color: Colors.white,fontSize:fontSize)),onTap: (){
                },),
              ),
              Container(padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/3),height: 30,width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.blue,),margin: EdgeInsets.only(top: 20),
                child: GestureDetector(child: Text('Update profile',style:TextStyle(color: Colors.white,fontSize:fontSize)),onTap: (){
                },),
              ),
              Container(padding: EdgeInsets.only(left:MediaQuery.of(context).size.width/3+20),height: 30,width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.redAccent,),margin: EdgeInsets.only(top: 20),
                child: GestureDetector(child: Text('Log out',style:TextStyle(color: Colors.white,fontSize:fontSize)),onTap: ()async{
                  await storage.deleteAll().then((val)=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Login()))).catchError((err){
                    _key.currentState.showSnackBar(SnackBar(content: Text('An error occurred',style: TextStyle(color: Colors.red,fontSize:fontSize),),));
                  });
                },),
              ),
              Center(child: RaisedButton(color: Colors.white,child: Text("Close",style: TextStyle(color: Colors.redAccent),),
              onPressed: (){
                _key.currentState.hideCurrentSnackBar();
              },),)   
            ],),
          height:180,),
          backgroundColor: Colors.white,));},
          child: Container(height: 35,width: 35,decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),image: DecorationImage(image: NetworkImage(url+Provider.of<Map>(context)['dp'])),),
            ),
          ),],),
        body:SafeArea(child:PageView(controller: _pageController,children: <Widget>[
          storedPosts.isEmpty?FutureBuilder(
          future:dio.get(url,options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'})),
          builder: (BuildContext context,snapshot){
              if(snapshot.hasData){
                List posts =new PostMap.fromJson(jsonDecode(snapshot.data.toString())).data;
                storedPosts=posts;
                return Container(
                  child: ListView.builder(
                    controller: _intialPostPageController,
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, index){
                    String username = Provider.of<Map>(context)['username'];
                    recommend = posts[index]['recommend'];
                    dontRecommend = posts[index]['dontrecommend'];
                    _intialPostPageController.addListener((){
                      setState(() {
                        postOffset = _intialPostPageController.offset;
                      });
                    });
                    _intialPostPageController.addListener((){
                      print('${_intialPostPageController.offset} ${_intialPostPageController.position.maxScrollExtent}');
                    });
                    List<Widget> images(list,index){
                      List returnedImages = <Widget>[];
                        for(var i in list){
                          if(i != "null"&&i!=null&&i!=""){
                                returnedImages.add(FlatButton(padding: EdgeInsets.all(0),child: Image.network(url+i,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress){
                                  if(loadingProgress==null)return child;
                                  return Center(child:CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                    : null,));
                                  },),onPressed: (){
                                  Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(days: 1),backgroundColor: Colors.white,
                                  content:PostPage(name: posts[index]["name"],description: posts[index]["description"],
                                  date: '${posts[index]["datePosted"]} ${posts[index]["timePosted"]}',pic: url+posts[index]["pic"],pic1: url+posts[index]["pic1"],
                                  pic2: url+posts[index]["pic2"],creator: posts[index]["creator"],location: posts[index]["location"],profilepic: posts[index]["profilepic"],
                                  tags: posts[index]["tags"],price: posts[index]["price"],currency: posts[index]["currency"],id: posts[index]["_id"],)));
                                }),);
                            }
                        }
                        return returnedImages;
                      }
                        return Column(
                        children: <Widget>[
                          Container(padding: EdgeInsets.all(5),margin: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.grey,width: .2)),
                            child: Container(height: 30,child: Stack(
                                children: <Widget>[
                                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),image: DecorationImage(image: 
                                NetworkImage(url+posts[index]["profilepic"],scale: 2.0)),),
                                ),
                                Text(posts[index]["creator"],style: TextStyle(color: fontColor,fontSize: fontSize),),
                                Positioned(right: -20,height: 20,child: FlatButton(child: Icon(Icons.more_vert),onPressed: (){
                                Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(minutes: 1),backgroundColor: Colors.white,content: Container(
                                  height:100,
                                  child: Column(children: <Widget>[
                                    RaisedButton(color: Colors.red,child: Text("Report",style: TextStyle(color: Colors.white),),onPressed: ()=>{},),
                                    FlatButton(child: Text("Close",style: TextStyle(color: Colors.red),),onPressed: (){Scaffold.of(context).removeCurrentSnackBar();},)
                                  ],),
                                ),)
                                );
                                },),)
                              ],),
                            ),),
                            Container(
                              margin: EdgeInsets.only(left: 10,top: 10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.white,),
                              child:
                                Text(posts[index]["name"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                            ),
                            Container(
                              child: SizedBox(height: 350,width: MediaQuery.of(context).size.width,
                                child:posts[index]["pic1"].toString().length>5?
                                Carousel(images: 
                                  images([posts[index]["pic"],posts[index]["pic1"],posts[index]["pic2"]],index),
                                  dotSize: 6,dotBgColor: Colors.white,dotColor: Colors.blueAccent,dotIncreasedColor: Colors.blue,dotHorizontalPadding: 0,autoplay: false,dotVerticalPadding: 0,
                                  ):Center(child:Image.network(url+posts[index]["pic"],)), 
                              ),
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Container(height: 50,margin: EdgeInsets.all(2),
                                    child: Stack(children:<Widget>[
                                      Positioned(left: 1 ,
                                        child: Container(child: RaisedButton(color: recommend!=null&&recommend.contains(username)?Colors.blueAccent:Colors.white,
                                        child:Row(children: [ Icon(Icons.thumb_up,color:recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent,),
                                        Container(margin: EdgeInsets.only(left: 5),child: Text("Recommend ${posts[index]["recommend"]!=null?posts[index]["recommend"].length:0}",style: 
                                        TextStyle(color: recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent),))]),
                                        onPressed: (){
                                          dio.post(url+'/recommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: posts[index]['_id'])
                                            .then((val){
                                              if(val.data.toString() != 'Error'){
                                                setState(() {
                                                  if(dontRecommend!=null)dontRecommend.remove(username);
                                                  recommend!=null?recommend.add(username):recommend=[username];
                                                });
                                                }else{
                                                    Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                  }
                                                }).catchError((err){
                                                  Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),),));
                                                });
                                          },
                                        ),
                                        margin: EdgeInsets.all(2)),
                                        ),
                                        Positioned(right: 1,
                                          child: Container(child: RaisedButton(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.blueAccent:Colors.white,
                                            child:Row(children: [ Icon(Icons.thumb_down,color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent,),
                                            Container(margin: EdgeInsets.only(left: 5),child: Text("Don't Recommend ${posts[index]["dontrecommend"]!=null?posts[index]["dontrecommend"].length:0}",
                                            style: TextStyle(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent),softWrap: true,))]),onPressed: (){
                                              dio.post(url+'/dontrecommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: posts[index]['_id'])
                                                .then((val){
                                                  if(val.data.toString() != 'Error'){
                                                    setState(() {
                                                      if(recommend!=null)recommend.remove(username);
                                                      dontRecommend!=null?dontRecommend.add(username):dontRecommend=[username];
                                                    });
                                                  }else{
                                                    Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                                    overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                  }
                                                }).catchError((err){
                                                  Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                                  overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                });
                                              },
                                            ),
                                            margin: EdgeInsets.all(2),
                                            ),
                                        ),
                                        ],
                                      ),
                                  ),
                                  Container(child: Text(posts[index]["description"],style: TextStyle(color: Colors.black,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                                  constraints: BoxConstraints(maxHeight: 50),),
                                  Container(child: Text(posts[index]["datePosted"] +' '+ posts[index]["timePosted"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text(posts[index]["currency"] +' '+ posts[index]["price"].toString(),style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text(posts[index]["location"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              }else if(snapshot.hasError){
                return ErrorWidget();
              }else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ):Container(
                  child: ListView.builder(
                    controller: _postPageController,
                    itemCount: storedPosts.length,
                    itemBuilder: (BuildContext context, index){
                    String username = Provider.of<Map>(context)['username'];
                    recommend = storedPosts[index]['recommend'];
                    dontRecommend = storedPosts[index]['dontrecommend'];
                    _postPageController.addListener((){
                      setState(() {
                        postOffset = _postPageController.offset;
                      });
                    });
                    _pageController.addListener((){
                      _postPageController.jumpTo(postOffset);
                    });
                    List<Widget> images(list,index){
                      List returnedImages = <Widget>[];
                        for(var i in list){
                          if(i != "null"&&i!=null&&i!=""){
                                returnedImages.add(FlatButton(padding: EdgeInsets.all(0),child: Image.network(url+i,loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress){
                                  if(loadingProgress==null)return child;
                                  return Center(child:CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                    : null,));
                                  },),onPressed: (){
                                  Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(days: 1),backgroundColor: Colors.white,
                                  content:PostPage(name: storedPosts[index]["name"],description: storedPosts[index]["description"],
                                  date: '${storedPosts[index]["datePosted"]} ${storedPosts[index]["timePosted"]}',pic: url+storedPosts[index]["pic"],pic1: url+storedPosts[index]["pic1"],
                                  pic2: url+storedPosts[index]["pic2"],creator: storedPosts[index]["creator"],location: storedPosts[index]["location"],profilepic: storedPosts[index]["profilepic"],
                                  tags: storedPosts[index]["tags"],price: storedPosts[index]["price"],currency: storedPosts[index]["currency"],id: storedPosts[index]["_id"],)));
                                }),);
                            }
                        }
                        return returnedImages;
                      }
                        return Column(
                        children: <Widget>[
                          Container(padding: EdgeInsets.all(5),margin: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.grey,width: .2)),
                            child: Container(height: 30,child: Stack(
                                children: <Widget>[
                                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),image: DecorationImage(image: 
                                NetworkImage(url+storedPosts[index]["profilepic"],scale: 2.0)),),
                                ),
                                Text(storedPosts[index]["creator"],style: TextStyle(color: fontColor,fontSize: fontSize),),
                                Positioned(right: -20,height: 20,child: FlatButton(child: Icon(Icons.more_vert),onPressed: (){
                                Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(minutes: 1),backgroundColor: Colors.white,content: Container(
                                  height:100,
                                  child: Column(children: <Widget>[
                                    RaisedButton(color: Colors.red,child: Text("Report",style: TextStyle(color: Colors.white),),onPressed: ()=>{},),
                                    FlatButton(child: Text("Close",style: TextStyle(color: Colors.red),),onPressed: (){Scaffold.of(context).removeCurrentSnackBar();},)
                                  ],),
                                ),)
                                );
                                },),)
                              ],),
                            ),),
                            Container(
                              margin: EdgeInsets.only(left: 10,top: 10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: Colors.white,),
                              child:
                                Text(storedPosts[index]["name"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                            ),
                            Container(
                              child: SizedBox(height: 350,width: MediaQuery.of(context).size.width,
                                child:storedPosts[index]["pic1"].toString().length>5?
                                Carousel(images: 
                                  images([storedPosts[index]["pic"],storedPosts[index]["pic1"],storedPosts[index]["pic2"]],index),
                                  dotSize: 6,dotBgColor: Colors.white,dotColor: Colors.blueAccent,dotIncreasedColor: Colors.blue,dotHorizontalPadding: 0,autoplay: false,dotVerticalPadding: 0,
                                  ):Center(child:Image.network(url+storedPosts[index]["pic"],)), 
                              ),
                            ),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Container(height: 50,margin: EdgeInsets.all(2),
                                    child: Stack(children:<Widget>[
                                      Positioned(left: 1 ,
                                        child: Container(child: RaisedButton(color: recommend!=null&&recommend.contains(username)?Colors.blueAccent:Colors.white,
                                        child:Row(children: [ Icon(Icons.thumb_up,color:recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent,),
                                        Container(margin: EdgeInsets.only(left: 5),child: Text("Recommend ${storedPosts[index]["recommend"]!=null?storedPosts[index]["recommend"].length:0}",style: 
                                        TextStyle(color: recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent),))]),
                                        onPressed: (){
                                          dio.post(url+'/recommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: storedPosts[index]['_id'])
                                            .then((val){
                                              if(val.data.toString() != 'Error'){
                                                setState(() {
                                                  if(dontRecommend!=null)dontRecommend.remove(username);
                                                  recommend!=null?recommend.add(username):recommend=[username];
                                                });
                                                }else{
                                                    Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                  }
                                                }).catchError((err){
                                                  Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),),));
                                                });
                                          },
                                        ),
                                        margin: EdgeInsets.all(2)),
                                        ),
                                        Positioned(right: 1,
                                          child: Container(child: RaisedButton(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.blueAccent:Colors.white,
                                            child:Row(children: [ Icon(Icons.thumb_down,color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent,),
                                            Container(margin: EdgeInsets.only(left: 5),child: Text("Don't Recommend ${storedPosts[index]["dontrecommend"]!=null?storedPosts[index]["dontrecommend"].length:0}",
                                            style: TextStyle(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent),softWrap: true,))]),onPressed: (){
                                              dio.post(url+'/dontrecommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: storedPosts[index]['_id'])
                                                .then((val){
                                                  if(val.data.toString() != 'Error'){
                                                    setState(() {
                                                      if(recommend!=null)recommend.remove(username);
                                                      dontRecommend!=null?dontRecommend.add(username):dontRecommend=[username];
                                                    });
                                                  }else{
                                                    Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                                    overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                  }
                                                }).catchError((err){
                                                  Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                                  overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                                });
                                              },
                                            ),
                                            margin: EdgeInsets.all(2),
                                            ),
                                        ),
                                        ],
                                      ),
                                  ),
                                  Container(child: Text(storedPosts[index]["description"],style: TextStyle(color: Colors.black,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                                  constraints: BoxConstraints(maxHeight: 50),),
                                  Container(child: Text(storedPosts[index]["datePosted"] +' '+ storedPosts[index]["timePosted"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text(storedPosts[index]["currency"] +' '+ storedPosts[index]["price"].toString(),style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text(storedPosts[index]["location"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
          FutureBuilder(
            future: dio.get(url+'/shop',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'})),
            builder: (context,snapshot){
              dynamic _items(data,index){
                var parseData =data.substring(1,data.length - 1).split('},{');
                Map shopsMap;
                if(parseData[index][0]=='{'){
                  shopsMap = jsonDecode(parseData[index]+'}');
                }else if(parseData[index][parseData[index].length-1]!= '}'){
                  shopsMap = jsonDecode('{'+parseData[index]+'}');
                }
                dynamic shops = new Shops.fromJson(shopsMap);
                return shops;
              }
              if(snapshot.hasData){
                return ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, index){
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: (){
                        String interested = 'Interested';
                        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Container(child: ListView(children: <Widget>[
                          FlatButton(child: Icon(Icons.arrow_drop_down,size: 40,color: Colors.blue,),onPressed: (){_scaffoldKey.currentState.removeCurrentSnackBar();},color: Colors.white,),                      
                          RaisedButton(child: Text(interested,style:TextStyle(fontSize: 20)),color: Colors.blueAccent,onPressed: (){},),
                        ],),constraints: BoxConstraints(maxHeight: 200),
                        ),backgroundColor: Colors.white,duration: Duration(minutes: 20),)
                        );
                      },
                      child: Container(
                        child: Container(
                          child: Column(children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                          color: Colors.white,
                              padding: EdgeInsets.all(3),
                              child: Row(
                                children: <Widget>[
                                  Container(height: 45,width: 45,decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),image: DecorationImage(image: 
                                  NetworkImage(url+_items(snapshot.data.toString(), index).dp,)),
                                  ),),
                                Text(_items(snapshot.data.toString(), index).creator,style: TextStyle(color: Colors.grey,fontSize: 30),),
                              ],),
                              ),
                            Container(
                              child: SizedBox(
                                  height: 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(children:_listChildren(_items(snapshot.data.toString(),index).items,)
                                ),
                              ),
                            ),
                            _items(snapshot.data.toString(), index).pic.toString() != 'null'?
                            Container(child: Image.network(url+_items(snapshot.data.toString(), index).pic,)):Text(''),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Container(child: Text('Max sum: ${_items(snapshot.data.toString(),index).estimate} ${_items(snapshot.data.toString(),index).currency}',style: TextStyle(color: Colors.grey,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                                  constraints: BoxConstraints(maxHeight: 50),color: Colors.white),
                                  Container(child: Text('${_items(snapshot.data.toString(),index).dateCreated} ${_items(snapshot.data.toString(),index).timeCreated}' ,style: TextStyle(color: Colors.grey,fontSize: 17)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text('${_items(snapshot.data.toString(),index).currency} ${_items(snapshot.data.toString(),index).price.toString()}',style: TextStyle(color: Colors.grey,fontSize: 17)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                                  Container(child: Text('Buy at: ${_items(snapshot.data.toString(),index).location}',style: TextStyle(color: Colors.grey,fontSize: 17)),
                                  width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                                ],
                              )      
                            )
                          ],
                        ),
                        ),
                      ),
                    ),
                  );
                },
              );
              }else if(snapshot.hasError){
                return Center(child: RaisedButton(
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ShopPage())),
                  child: Text('An error occurred, Click to try again',style:TextStyle(color: Colors.grey)),),);
              }else{
                return Center(child: CircularProgressIndicator());
              }
            },
          ),SearchPage(),NotificationPage(),MenuPage()
         ],
         onPageChanged: (data){setState((){size=data;});},
         ),
      ),
      bottomNavigationBar: BottomNavigationBar(showSelectedLabels: true,showUnselectedLabels: true,
      onTap: ((int index){
          setState(()=>_pageController.jumpToPage(index));        
        }),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home,size: size==0?28:20,color: Colors.blueAccent,),title: Text('Home',style: TextStyle(color: Colors.blueAccent,fontSize: 12),),),
        BottomNavigationBarItem(icon : Icon(Icons.shopping_basket,size: size==1?28:19,color: Colors.blueAccent,),title: Text('Shop',style: TextStyle(color: Colors.blueAccent,fontSize: 12))),
        BottomNavigationBarItem(icon: Icon(Icons.search,size: size==2?28:19,color: Colors.blueAccent,),title: Text('Search',style: TextStyle(color: Colors.blueAccent,fontSize: 12))),
        BottomNavigationBarItem(icon: Icon(Icons.notifications,size: size==3?28:19,color: Colors.blueAccent,),title: Text('Notifications',style: TextStyle(color: Colors.blueAccent,fontSize: 12)),),
        BottomNavigationBarItem(icon: Icon(Icons.menu,size: size==4?28:19,color: Colors.blueAccent,),title: Text('More',style: TextStyle(color: Colors.blueAccent,fontSize: 12)),),
      ],),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add_box),onPressed: ()=>Navigator.push(context, MaterialPageRoute(maintainState: true,builder: (context)=>CreatePostPage())),),

      ),
    );
  }
}



class _HomePageState extends State<HomePage> {
  var recommend;
  var dontRecommend;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:dio.get(url,options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'})),
      builder: (BuildContext context,snapshot){
        if(snapshot.hasData){
          List posts =new PostMap.fromJson(jsonDecode(snapshot.data.toString())).data;
          return Container(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, index){
              String username = Provider.of<Map>(context)['username'];
              recommend = posts[index]['recommend'];
              dontRecommend = posts[index]['dontrecommend']; 
              List<Widget> images(list,index){
                List returnedImages = <Widget>[];
                  for(var i in list){
                    if(i != "null"&&i!=null&&i!=""){
                          returnedImages.add(FlatButton(padding: EdgeInsets.all(0),child: Image.network(url+i,),onPressed: (){
                            Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(days: 1),backgroundColor: Colors.white,
                            content:PostPage(name: posts[index]["name"],description: posts[index]["description"],
                            date: '${posts[index]["datePosted"]} ${posts[index]["timePosted"]}',pic: url+posts[index]["pic"],pic1: url+posts[index]["pic1"],
                            pic2: url+posts[index]["pic2"],creator: posts[index]["creator"],location: posts[index]["location"],profilepic: posts[index]["profilepic"],
                            tags: posts[index]["tags"],price: posts[index]["price"],currency: posts[index]["currency"],id: posts[index]["_id"],)));
                          }),);
                      }
                  }
                  return returnedImages;
                }
                  return Column(
                  children: <Widget>[
                    Container(padding: EdgeInsets.all(5),margin: EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.grey,width: .2)),
                      child: Container(height: 30,child: Stack(
                          children: <Widget>[
                          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),image: DecorationImage(image: 
                          NetworkImage(url+posts[index]["profilepic"],scale: 2.0)),),
                           ),
                          Text(posts[index]["creator"],style: TextStyle(color: fontColor,fontSize: fontSize),),
                          Positioned(right: -20,height: 20,child: FlatButton(child: Icon(Icons.more_vert),onPressed: (){
                          Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(minutes: 1),backgroundColor: Colors.white,content: Container(
                            height:100,
                            child: Column(children: <Widget>[
                              RaisedButton(color: Colors.red,child: Text("Report",style: TextStyle(color: Colors.white),),onPressed: ()=>{},),
                              FlatButton(child: Text("Close",style: TextStyle(color: Colors.red),),onPressed: (){Scaffold.of(context).removeCurrentSnackBar();},)
                            ],),
                          ),)
                          );
                          },),)
                        ],),
                      ),),
                      Container(
                        margin: EdgeInsets.only(left: 10,top: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white,),
                        child:
                          Text(posts[index]["name"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                      ),
                      Container(
                        child: SizedBox(height: 350,width: MediaQuery.of(context).size.width,
                          child:posts[index]["pic1"].toString().length>5?
                           Carousel(images: 
                            images([posts[index]["pic"],posts[index]["pic1"],posts[index]["pic2"]],index),
                            dotSize: 6,dotBgColor: Colors.white,dotColor: Colors.blueAccent,dotIncreasedColor: Colors.blue,dotHorizontalPadding: 0,autoplay: false,dotVerticalPadding: 0,
                            ):Center(child:Image.network(url+posts[index]["pic"],)), 
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(height: 50,margin: EdgeInsets.all(2),
                              child: Stack(children:<Widget>[
                                Positioned(left: 1 ,
                                  child: Container(child: RaisedButton(color: recommend!=null&&recommend.contains(username)?Colors.blueAccent:Colors.white,
                                  child:Row(children: [ Icon(Icons.thumb_up,color:recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent,),
                                  Container(margin: EdgeInsets.only(left: 5),child: Text("Recommend ${posts[index]["recommend"]!=null?posts[index]["recommend"].length:0}",style: 
                                  TextStyle(color: recommend!=null&&recommend.contains(username)? Colors.white:Colors.blueAccent),))]),
                                  onPressed: (){
                                    dio.post(url+'/recommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: posts[index]['_id'])
                                      .then((val){
                                        if(val.data.toString() != 'Error'){
                                          setState(() {
                                            if(dontRecommend!=null)dontRecommend.remove(username);
                                            recommend!=null?recommend.add(username):recommend=[username];
                                          });
                                          }else{
                                              Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                            }
                                          }).catchError((err){
                                            Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),),));
                                          });
                                    },
                                  ),
                                  margin: EdgeInsets.all(2)),
                                  ),
                                  Positioned(right: 1,
                                    child: Container(child: RaisedButton(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.blueAccent:Colors.white,
                                      child:Row(children: [ Icon(Icons.thumb_down,color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent,),
                                      Container(margin: EdgeInsets.only(left: 5),child: Text("Don't Recommend ${posts[index]["dontrecommend"]!=null?posts[index]["dontrecommend"].length:0}",
                                      style: TextStyle(color: dontRecommend!=null&&dontRecommend.contains(username)?Colors.white:Colors.blueAccent),softWrap: true,))]),onPressed: (){
                                        dio.post(url+'/dontrecommend',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: posts[index]['_id'])
                                          .then((val){
                                            if(val.data.toString() != 'Error'){
                                              setState(() {
                                                if(recommend!=null)recommend.remove(username);
                                                dontRecommend!=null?dontRecommend.add(username):dontRecommend=[username];
                                              });
                                            }else{
                                              Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                              overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                            }
                                          }).catchError((err){
                                            Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An Error occurred',
                                            overflow: TextOverflow.clip,style: TextStyle(color: Colors.white),)));
                                          });
                                        },
                                      ),
                                      margin: EdgeInsets.all(2),
                                      ),
                                  ),
                                  ],
                                ),
                            ),
                            Container(child: Text(posts[index]["description"],style: TextStyle(color: Colors.black,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(maxHeight: 50),),
                            Container(child: Text(posts[index]["datePosted"] +' '+ posts[index]["timePosted"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(posts[index]["currency"] +' '+ posts[index]["price"].toString(),style: TextStyle(color: Colors.black,fontSize: fontSize)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(posts[index]["location"],style: TextStyle(color: Colors.black,fontSize: fontSize)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }else if(snapshot.hasError){
          return ErrorWidget();
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
    }
}

class NotificationPageState extends State<NotificationPage>{
  NetworkNotification notification;
  Widget build(BuildContext context){
    return SafeArea(
      child: FutureBuilder(
        future: dio.post(url+'/notification',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data:Provider.of<Map>(context)['username']),
        builder: (context, snapshot){
          if(snapshot.hasData){
            int length = snapshot.data.toString().substring(1,snapshot.data.toString().length - 1).split('},{').length -4;
            dynamic _items(data,index){
              var parseData =data.substring(1,data.length - 1).split('},{');
              Map notificationsMap;
              if(parseData[index][0]=='{'){
                notificationsMap = jsonDecode(parseData[index]+'}');
              }else if(parseData[index][parseData[index].length-1]!= '}'){
                notificationsMap = jsonDecode('{'+parseData[index]+'}');
              }
              dynamic notifications = new NetworkNotification.fromJson(notificationsMap);
              return notifications;
            }
            TextStyle bodyTextStyle = TextStyle(fontSize:fontSize);
            TextStyle headerTextStyle = TextStyle(fontSize: 18,);
            BoxDecoration boxDecoration = BoxDecoration();
            notificationItem(type,creator, dateTime){
              if(type=='post'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator has posted recently',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: (){Scaffold.of(context).showSnackBar(SnackBar(content: Container(height: MediaQuery.of(context).size.height-170,child:PostDetailsPage(),),backgroundColor: Colors.white,duration: Duration(days: 1),));},color: Colors.white,),
                );
              }else if(type=='shop'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator has created a shopping chart near you',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else if(type == 'comment'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator commented on your post',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else if(type == 'approved'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator approved your offer',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else if(type == 'follow'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator has started following you',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else if(type == 'comment'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator commented on your post',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else if(type == 'request'){
                return Container(margin: EdgeInsets.only(bottom: 10),
                  child: RaisedButton(child: Column(children:<Widget>[ 
                  Container(child: Text('$dateTime',style: headerTextStyle,),decoration: boxDecoration,height: 30, width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(10),),
                  Container(child: Text('$creator request to shop for you',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10)),]),
                  onPressed: ()=>{},color: Colors.white,),
                );
              }else{                
                return Container(child: Text('$creator request to shop for you',style: bodyTextStyle,),width: MediaQuery.of(context).size.width,decoration: boxDecoration,margin: EdgeInsets.all(10));
              }
            }
            return Container(
              child: ListView.builder(
              itemCount: length>0?length:0,
              itemBuilder: (context, index){
                return Container(child: Column(children: <Widget>[
                  // Container(child: GridTile(child: Text('data'),))
                  notificationItem(_items(snapshot.data.toString(), index).type, _items(snapshot.data.toString(), index).creator, 
                  '${_items(snapshot.data.toString(), index).dateCreated} ${_items(snapshot.data.toString(), index).timeCreated}')
                ],),);
              },
          ),
            );
          }else if(snapshot.hasError){
            return Container(
              child: Center(child: Container(decoration: BoxDecoration(color: Colors.red,),
                child: FlatButton(child: Text('Error ,Click to reload'),onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationPage()));
              },),),),
            );
          }else{
            return Container(child: Center(child: CircularProgressIndicator(),));
          }
        },
      ),
    );
  }
}






class SearchPageState extends State<SearchPage>{
  final _controller = TextEditingController();
  List <Widget> listChildren = <Widget>[
    Text(''),
    Container(child: Center(child: Text('No result found',style: TextStyle(fontSize: 20),),),margin: EdgeInsets.only(top:20,bottom: 20),),
  ];
  Widget build(BuildContext context){
    return SafeArea(
          child: Container(child:
          ListView.builder(
            itemCount: listChildren.length,
            itemBuilder: (context,index){
              if(index==1){
                return Container(color: Colors.white,margin: EdgeInsets.only(left: 10),child: TextField(controller: _controller,decoration: InputDecoration(suffix: Icon(Icons.search,color:Colors.grey),hintText: 'Search',),onChanged: (val){
                void fetch()async{
                  await dio.post(url+'/search',options: Options(headers: {'cookie':'sessionid=${Provider.of<String>(context)}'}),data: {'searchdata':val,'sort':'relevant'}).then((data)async{
                  var parseData =data.toString().substring(1,data.toString().length - 1).split('},{');  
                  List<Widget>postsList = <Widget>[];        
                  dynamic posts(index){
                    Map postMap;
                        if(parseData[index][0]=='{'){
                          postMap = jsonDecode(parseData[index]+'}');
                        }else if(parseData[index][parseData[index].length-1]!= '}'){
                          postMap= jsonDecode('{'+parseData[index]+'}');
                        }
                        
                    dynamic posts = new Posts.fromJson(postMap);
                    return posts;
                  }
                  for(int i=0; i<parseData.length-1;i++){
                    postsList.add(
                      Container(color: Colors.white,margin: EdgeInsets.only(bottom:10),child: FlatButton(child: Row(children: <Widget>[
                        Container(width:50,height: 50,decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),image: DecorationImage(image: 
                        NetworkImage(url+posts(i).pic,)),)),
                        Container(padding: EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Container(margin: EdgeInsets.only(right: 205,top: 15,left: 10),child: Text(posts(i).name),),
                              Container(margin: EdgeInsets.only(top: 10,),child: 
                              Text('Created by ${posts(i).creator} on ${posts(i).datePosted}'),)
                            ],
                          ),
                        ),
                        
                      ],),onPressed:(){}),
                      ));
                  }
                  setState(() {
                    data.toString().length>5?listChildren.removeRange(2,listChildren.length):listChildren.replaceRange(2,listChildren.length,[Container(child: Center(child: Text('No result found',style: 
                    TextStyle(fontSize: 20),),),margin: EdgeInsets.only(top:20,bottom: 20),)]);
                    listChildren.addAll(postsList);
                  });
                }).catchError((err){
                  Scaffold.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent,content: Text('An error occurred',style: TextStyle(fontSize: 20,color: Colors.white),),));
                });
                }
                fetch();
              },)
              );
              }else if(index == 0){
                return listChildren[0];
              }else{
                return listChildren[index];
              }
            },
        )
      ),
    );
  }
}

