import 'dart:convert';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:solocoding2019_base/common.dart";
import "package:solocoding2019_base/views/city.dart";


class SearchPage extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => new SearchPageState();
}
class SearchPageState extends State<SearchPage> {
	List<dynamic> cityJSONArray;
	String _searchKeyword;
	SharedPreferences _prefs;
	List<String> _favArray;
	
	final TextEditingController searchTextController = TextEditingController();

	@override
	void initState() {
		// 내 즐겨찾기 정보 읽기
		SharedPreferences.getInstance().then( (prefs) {
			List<String> favArray = prefs.getStringList("myFavs");
			if(favArray==null) favArray=[];
			setState( () {
				_prefs = prefs;
				_favArray = favArray;
			});
		});		
		// 지역 정보를 가진 json 읽기
		DefaultAssetBundle.of(context).loadString('assets/data/city.korea.list.json')
		.then((fileContents) => jsonDecode(fileContents))
		.then((jsonData) {
			// Common.log(jsonData);
			setState(() {
			  cityJSONArray = jsonData;
			});
		});
		super.initState();
	}

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			appBar: AppBar(
				title: Text("지역 검색"),
			),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context) {
		// 데이터 초기화가 안됬으면...
		if( cityJSONArray == null ) return _buildBodyLoading();

		// TODO 지역 검색 만들기
		return Column(
			children: <Widget>[
				Container(
					child: _buildSearchBar(context),
				),
				Expanded(child: _buildList(context) ),
			] 
		);
	}

	/// 초기화 로딩 화면
	Widget _buildBodyLoading(){
		return Center(
			child: CircularProgressIndicator()
		);
	}
	Widget _buildSearchBar(BuildContext context){
		return SizedBox(
			width: MediaQuery.of(context).size.width,
			// height: 60.0,
			child: Container(
				padding: EdgeInsets.fromLTRB(8.0,8.0,8.0,16.0),
				child: TextField(
					controller: searchTextController,
					decoration: InputDecoration(
						border: OutlineInputBorder(),
						hintText: "지역 검색 (영문으로만, KR지역 Only)"
					),
					onChanged: (text){
						setState(() {
							_searchKeyword = text;
						});
					},
				),
			),
		);
	}
	// 지역 목록
	Widget _buildList(BuildContext context){
		final List<dynamic> listItems = ( _searchKeyword==null || _searchKeyword.isEmpty || _searchKeyword.length < 1 ) ? cityJSONArray
			: cityJSONArray.where( (item) => item["name"].toString().toLowerCase().contains( _searchKeyword.toLowerCase() ) ).toList();

		return ListView.builder(
			itemCount: listItems.length,
			itemBuilder: (BuildContext ctxt, int idx){
				final title = listItems[idx]["name"];
				final strId = "${listItems[idx]["id"]}";
				return ListTile(
					title: Text(title),
					subtitle: Text(strId),
					onTap: () {
						final route = MaterialPageRoute(builder: (_)=>CityPage(strId));
						Navigator.push(context, route);
					},
					trailing: (_prefs==null)? null : IconButton(
						icon: Icon(
							_favArray.contains(strId) ? Icons.favorite : Icons.favorite_border ,
							color: _favArray.contains(strId) ? Colors.red : Colors.grey ,
						),
						onPressed: () async {
							if( _favArray.contains( strId ) ){ // 있으면 -> 제거
								_favArray.removeAt( _favArray.indexOf(strId) );
							}else{ // 없으면 추가
								_favArray.add( strId );
							}
							await _prefs.setStringList('myFavs', _favArray);
							setState(() { _favArray; });
						},
					),
				);
			},
		);
	}
}