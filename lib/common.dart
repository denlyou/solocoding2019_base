class Common {
	static final bool isDebug = true;

	static void log(Object obj){
		if( isDebug ) print("👾 ${obj}");
	}
	static void log4net(Object obj){
		if( isDebug ) print("⚡ ${obj}");
	}
	static void log4err(Object obj){
		if( isDebug ) print("😱 ${obj}");
	}
}

class SharedValues {
	// 날씨 API 📑 https://openweathermap.org/current
	static final String WEATHER_API_BASE_URL = "https://api.openweathermap.org/data/2.5/";
	static final String WEATHER_API_KEY = "7b08a6a288b8d81581b168cd8cb081ee";

	// 
	static final int MAX_HISTORY = 10; // 최근 조회 지역 저장 갯수
}