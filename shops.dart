import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'dart:convert';
import 'main.dart';
Dio dio =Dio();
class ShopPage extends StatefulWidget{
  ShopPage({Key key,}):super(key:key);
  @override
  ShopPageState createState()=>ShopPageState();
}
class ShopPageState extends State<ShopPage>{
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
    return FutureBuilder(
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
    );
  }
}