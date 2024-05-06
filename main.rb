require_relative 'parser'

json = '{"a": "foo", "c": 1.0, "d": 2.2, "e": true, "f": false, "g": null}'
#json = '{"cu":"toba", "arrayzadaXD":[10, 20,[35, [123.456], 36], [false, true], "johanesburgo"], "id": null, "nome": "Chrystian", "silvafeio":0.002, "idade": 21, "vivo":true, "sobrenome": "Oliveira", "obj": {"nome": 0.1, "arr": [1, 2, 3], "fiofo": {"limpinho": 599.80,"celular": 99.99, "teste":[true, [50.2, "minecraft"]]}}, "erick":"lindao", "yuri":{"cachorro":17.50}, "bundadochrys": [{"sprayzada": 20}, 2, {"abc": 20, "cba": [0, 2, {"sla": 12, "algo": {"somos": "foda"}}], "double": 2.3, "bool": true, "string": "PAU NO CU"}, 3, "teste"]}'
parserJson = ParserJson.new
parserJson.parse(json)
puts parserJson.pa
