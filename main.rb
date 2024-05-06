require_relative 'parser'

json = '{"a": "foo", "c": 1.0, "d": 2.2, "e": true, "f": false, "g": null}'

parserJson = ParserJson.new
parserJson.parse(json)
puts parserJson.pa
