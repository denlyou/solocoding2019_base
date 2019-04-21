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
	List<dynamic> _cityJSONArray;
	String _searchKeyword;
	
	SharedPreferences _prefs;
	List<String> _favArray = [];
	List<String> _recentArray = [];
	
	bool _isFavMode = false; // 즐겨찾기 필터
	bool _isRecentMode = false; // 최근 조회 지역 필터링 여부
	
	final TextEditingController searchTextController = TextEditingController();

	@override
	void initState() {
		// 내 즐겨찾기 정보 읽기
		SharedPreferences.getInstance().then( (prefs) {
			List<String> favArray = prefs.getStringList("myFavs");
			List<String> recentArray = prefs.getStringList("recent");
			if(favArray==null) favArray=[];
			if(recentArray==null) recentArray=[];
			setState( () {
				_prefs = prefs;
				_favArray = favArray;
				_recentArray = recentArray;
			});
		});		
		// 지역 정보를 가진 json 읽기
		DefaultAssetBundle.of(context).loadString('assets/data/city.korea.list.json')
		.then((fileContents) => jsonDecode(fileContents))
		.then((jsonData) {
			// Common.log(jsonData);
			setState(() {
			  _cityJSONArray = jsonData;
			});
		});
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		if( _prefs != null ) { // sync
			_favArray = _prefs.getStringList("myFavs"); 
			if(_favArray==null) _favArray=[];
			_recentArray = _prefs.getStringList("recent"); 
			if(_recentArray==null) _recentArray=[];
		}

		String title = "지역 검색";
		if( _isFavMode ) title = "Like City";
		if( _isRecentMode ) title = "최근 조회 지역";

		return Scaffold(
			appBar: AppBar(
				title: Text(title),
				actions: <Widget>[
					IconButton(
						icon: Icon( _isRecentMode ? Icons.close : Icons.history),
						onPressed: (){
							setState(() {
								_isRecentMode = !_isRecentMode;
							});
						},
					)
				],
			),
			body: _buildBody(context),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
			floatingActionButton: _cityJSONArray==null || _isRecentMode ? null : FloatingActionButton(
				child: Icon( _isFavMode ? Icons.list : Icons.favorite ),
				onPressed: (){
					setState(() {
						_isFavMode = !_isFavMode;
					});
				},
			),
		);
	}

	Widget _buildBody(BuildContext context) {
		// 데이터 초기화가 안됬으면...
		if( _cityJSONArray == null ) return _buildBodyLoading();

		// TODO 지역 검색 만들기
		return Column(
			children: <Widget>[
				Container(
					child: _isFavMode ? null : _buildSearchBar(context),
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
		return Container(
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
		);
	}	

	// 지역 목록
	Widget _buildList(BuildContext context){
		List<dynamic> listItems = [];
		if ( _isRecentMode ) { // 최근 조회 지역
			List<dynamic> $list = _cityJSONArray.where( (item) {
				return _recentArray.contains( item["id"].toString() );
			} ).toList();
			// 문제는 순서 (최근 조회 배열 역순)
			for(var idx=_recentArray.length-1; idx>=0; idx--){
				for (var i = 0; i < $list.length; i++) {
					if( _recentArray[idx].toString() == $list[i]["id"].toString() ){
						listItems.add( $list[i] as dynamic );
						break;
					}
				}
			}
		} else if ( _isFavMode ) { // 즐겨찾기 필터링
			listItems = _cityJSONArray.where( (item) {
				return _favArray.contains( item["id"].toString() );
			} ).toList();
		} else if ( _searchKeyword==null || _searchKeyword.isEmpty || _searchKeyword.length < 1 ) { // 필터x + 검색어가 없는 경우
			listItems = _cityJSONArray;
		} else { // 검색어가 있는 경우
			listItems = _cityJSONArray.where( (item) {
				return item["name"].toString().toLowerCase().contains( _searchKeyword.toLowerCase() );
			} ).toList();
		}

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
							setState(() {  });
						},
					),
				);
			},
		);
	}
}