import 'dart:convert';
// import "dart:async"; // ?!
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as Http;
import "package:solocoding2019_base/common.dart";
import "package:solocoding2019_base/models/weather_response.dart";


class CityPage extends StatefulWidget {
	final String cityId;
	CityPage(this.cityId);
	@override
	State<StatefulWidget> createState() => new CityPageState();
}
class CityPageState extends State<CityPage> {
	bool _isInitData = false; // 초기 데이터(위치 가져오기) 완료 여부
	bool _isNetworking = false; // API 통신중?

	bool _isError = false; // 오류 발생 여부
	String _errorMessage = ""; // 에러시 메세지

	bool _isFav = false; // 즐겨찾기 여부
	WeatherResponse _nowWeather; // 날시 정보 객체

	@override
	void initState() {
		// 내 즐겨찾기 정보 읽기
		SharedPreferences.getInstance().then( (prefs) {
			List<String> favArray = prefs.getStringList("myFavs");
			if(favArray==null) favArray=[];
			setState( () {
				_isFav = favArray.contains(widget.cityId);
			});
			_netGetNowWeather();
		});	
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		
		return Scaffold(
			backgroundColor: Color.fromRGBO(37, 97, 161, 1.0),
			appBar: AppBar(
				title: Text("날씨"),
				actions: <Widget>[	
					IconButton(
						icon: Icon( _isFav ? Icons.favorite : Icons.favorite_border),
						onPressed: () async {
							SharedPreferences prefs = await SharedPreferences.getInstance();
							List<String> favArray = prefs.getStringList("myFavs");
							if(favArray==null) favArray=[];
							if( favArray.contains( widget.cityId ) ){ // 있으면 -> 제거
								favArray.removeAt( favArray.indexOf(widget.cityId) );
							}else{ // 없으면 추가
								favArray.add( widget.cityId );
							}
							await prefs.setStringList('myFavs', favArray);
							setState(() { _isFav = !_isFav; });
						},
					),
				],
			),
			// 새로 고침 버튼
			// floatingActionButton: FloatingActionButton(
			// 	child: Icon(Icons.replay),
			// 	onPressed: () {
			// 		setState(() { _isError = false; });
			// 		_netGetNowWeather();
			// 	},
			// ),
			body: _buildBody(),
		);
	}

	Widget _buildBody(){
		// 데이터 초기화가 안됬으면...
		if(_isInitData == false || _isNetworking) return _buildBodyLoading();
		// 에러가 발생 했을 경우
		if(_isError) return _buildBodyError();
		// 아이콘 이름 구하기
		final String iconName = "assets/images/${_nowWeather.weather[0].icon.substring(0,2)}.png";
	
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					
					Image.asset(iconName),
					Text(
						"${ _nowWeather.main.temp.toStringAsFixed(2) }°C",
						style: TextStyle(color: Colors.white, fontSize: 80.0)
					),
					Text(
						"${_nowWeather.name} - ${_nowWeather.sys.country}",
						style: TextStyle(color: Colors.white70)
					),
					// 하단 여백 박스
					SizedBox(
						width: MediaQuery.of(context).size.width,
						height: 40.0,
					),
				],
			)
		);
	}

	/// 초기화 로딩 화면
	Widget _buildBodyLoading(){
		return Center(
			child: CircularProgressIndicator()
		);
	}

	/// 에러화면
	Widget _buildBodyError(){
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Icon(Icons.warning, size: 256.0, color: Colors.amber ),
					Text(_errorMessage),
				],
			),
		);
	}

	/// 날씨 정보 가져오기 (API)
	void _netGetNowWeather() async { 
		try{
			final String url = SharedValues.WEATHER_API_BASE_URL + "weather?appid=${SharedValues.WEATHER_API_KEY}&id=${widget.cityId}";
			Common.log4net(url);
			setState(() { _isNetworking = true; });
			Http.Response response = await Http.get(url);
			Common.log4net(response.body);
			WeatherResponse weatherResponse = WeatherResponse.fromJson(jsonDecode(response.body));
			setState(() {
				_isInitData = true;				
				_isNetworking = false;
				_nowWeather = weatherResponse;
			});
		} catch (error) {
			Common.log4err(error);
			setState(() {
				 _isNetworking = false;
				_isInitData = true;
				_isError = true;
				_errorMessage = error.toString(); // ?!
			});
		} 
	}
}