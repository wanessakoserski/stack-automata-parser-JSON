require_relative 'parser'

json = '{ "a": "foo", "b": [ 2, "abc", false, 3.3, "io" ], "c": 1.0, "d": 2.2, "e": true, "f": false, "g": null, "h": { "a": 1.0, "b": "tchau", "c": null }}'

parserJson = ParserJson.new
parserJson.parse(json)
