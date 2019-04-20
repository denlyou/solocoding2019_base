import "dart:convert";
import "dart:async";
import "package:flutter/material.dart";
import "package:location/location.dart";
import "package:http/http.dart" as Http;
import "package:solocoding2019_base/common.dart";
import "package:solocoding2019_base/views/search.dart";
import "package:solocoding2019_base/models/weather_response.dart";


class HomePage extends StatefulWidget {
	@override
	State<StatefulWidget> createState() => new HomePageState();
}
class HomePageState extends State<HomePage> {
	bool _isInitData = false; // 초기 데이터(위치 가져오기) 완료 여부
	bool _isNetworking = false; // API 통신중?

	bool _isError = false; // 오류 발생 여부
	String _errorMessage = ""; // 에러시 메세지

	LocationData _nowLocationData; // 현재 위치를 가져 올 변수
	WeatherResponse _nowWeather;

	@override
	void initState() {
		// 현재 위치 구하기 (async)
		_getLocation().then( (LocationData nowLocationData) {
			setState(() {
				_nowLocationData = nowLocationData;
			});
			if( nowLocationData != null ) _netGetNowWeather();
		}).catchError((error) {
			setState(() {
				_isError = true;
				_errorMessage = error.toString(); // ?!
			});
		});
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		print("HomePageState.build()");
		return Scaffold(
			backgroundColor: Color.fromRGBO(37, 97, 161, 1.0),
			appBar: AppBar(
				title: Text("날씨"),
				leading: IconButton(
					icon: Icon(Icons.search),
					onPressed: (){
						// TODO 지역 검색
						final route = MaterialPageRoute(builder: (_) => SearchPage());
						Navigator.push(context, route);
					},
				),
				actions: <Widget>[
					// 다시 통신 버튼
					IconButton(
						icon: Icon(Icons.replay),
						onPressed: () {
							setState(() { _isError = false; });
							_netGetNowWeather();
						},
					)
				],
			),
			body: _buildBody()
		);
	}

	/// 내용을 만듭니다.
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
					Text(
						"${_nowWeather.name} - ${_nowWeather.sys.country}",
						style: TextStyle(color: Colors.white70)
					),
					Image.asset(iconName),
					Text(
						"${ _nowWeather.main.temp.toStringAsFixed(2) }°C",
						style: TextStyle(color: Colors.white, fontSize: 80.0)
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
	

	/// 현재 위치를 가져오는 메소드
	Future<LocationData> _getLocation() async {
		LocationData currentLocation;
		final location = new Location();

		try {
			currentLocation = await location.getLocation();
		} catch (e) {
			if (e.code == "PERMISSION_DENIED") {
				setState(() {
					_isError = true;
					_errorMessage = "위치 정보를 가져올 권한이 없거나 문제가 발생하였습니다.";
				});
			} 
			currentLocation = null;		
		}

		return currentLocation;
	}

	/// 현재 위치에서 날시 정보 가져오기 (API)
	void _netGetNowWeather() async { 
		try{
			final lat = _nowLocationData.latitude;
			final long = _nowLocationData.longitude;
			final String url = SharedValues.WEATHER_API_BASE_URL + "weather?appid=${SharedValues.WEATHER_API_KEY}&lat=$lat&lon=$long";
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