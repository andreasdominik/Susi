# get weather info from openweater.org
#

const INI_WEATHER_API = :openweather_api_key
const INI_WEATHER_ID = :openweather_city_id
const WEATHER_URL = "api.openweathermap.org/data/2.5/weather"


"""
    getOpenWeather()

Return a Dict with weather information from openweather.org. The `config.ini`
of the framework must include the lines

```
openweather_api_key=1234567abcdef
openweather_city_id=2950159
```

with a valid app-key (available from openweather.org for free) and the id of a
city.

## Value:
The return value has the elements:
- `:pressure`: pressure in hPa
- `:temperature`: temperature in degrees Celsius
- `:windspeed`: wind speed in meter/sec
- `:winddir`: wind direction in degrees
- `:clouds`: cloudiness in percent
- `:rain1h`
- `:rain3h`: rain in mm in the last 1 or 3 hours
- `:sunrise`
- `:sunset`: local time of sunrise/sunset as DateTime object
"""
function getOpenWeather()

    api = getConfig(INI_WEATHER_API)
    printDebug("api = $api")
    city = getConfig(INI_WEATHER_ID)
    printDebug("city = $city")

    url = "http://$WEATHER_URL?id=$city&APPID=$api"
    printDebug("url = $url")

    response = read(`curl $url`, String)
    openWeather = tryParseJSON(response)

    if !(openWeather isa Dict)
        return nothing
    end

    weather = Dict()
    weather[:temperature] = getFromKeys(openWeather, :main, :temp)
    weather[:windspeed] = getFromKeys( openWeather, :wind, :speed)
    weather[:winddir] = getFromKeys( openWeather, :wind, :deg)
    weather[:clouds] = getFromKeys( openWeather, :clouds, :all)
    weather[:rain1h] = getFromKeys( openWeather, :rain, Symbol("1h"))
    if weather[:rain1h] == nothing
        weather[:rain1h] = 0.0
    end
    weather[:rain3h] = getFromKeys( openWeather, :rain, Symbol("3h"))
    if weather[:rain3h] == nothing
        weather[:rain3h] = 0.0
    end

    sunrise = getFromKeys(openWeather, :sys, :sunrise, true)
    if (sunrise isa DateTime) && haskey(openWeather, :timezone)
        weather[:sunrise] = sunrise + Dates.Second(openWeather[:timezone])
    end

    sunset = getFromKeys(openWeather, :sys, :sunset, true)
    if (sunset isa DateTime) && haskey(openWeather, :timezone)
        weather[:sunset] = sunset + Dates.Second(openWeather[:timezone])
    end

    return weather
end




function getFromKeys(hierDict, key1, key2, isDate = false)

    if haskey(hierDict, key1) && haskey(hierDict[key1], key2)
        val = hierDict[key1][key2]
        if isDate
            val = unix2datetime(val)
        end
        return val
    else
        return nothing
    end
end
