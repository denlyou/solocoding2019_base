import "package:flutter/material.dart";

class SearchPage extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => new SearchPageState();
}
class SearchPageState extends State<SearchPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("지역 검색"),
			),
			body: _buildBody(context),
		);
	}

	Widget _buildBody(BuildContext context){
		// TODO 지역 검색 만들기
		return Container();
	}
}