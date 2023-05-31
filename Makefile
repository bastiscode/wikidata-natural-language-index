OUT_DIR=.

.PHONY: properties
properties:
	@mkdir -p $(OUT_DIR)
	@curl -s https://qlever.cs.uni-freiburg.de/api/wikidata -H "Accept: text/tab-separated-values" -H "Content-type: application/sparql-query" --data "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> PREFIX wdt: <http://www.wikidata.org/prop/direct/> PREFIX wd: <http://www.wikidata.org/entity/> PREFIX wikibase: <http://wikiba.se/ontology#> SELECT ?p ?propLabel (GROUP_CONCAT(DISTINCT ?propAlias; SEPARATOR = \"; \") AS ?propAliases) (GROUP_CONCAT(DISTINCT ?invProp; SEPARATOR = \"; \") AS ?invProps) WHERE { ?prop wikibase:directClaim ?p . ?prop rdfs:label ?propLabel . FILTER(LANG(?propLabel) = \"en\") . OPTIONAL { ?prop skos:altLabel ?propAlias . FILTER(LANG(?propAlias) = \"en\") } OPTIONAL { ?prop wdt:P1696 ?invProp } } GROUP BY ?p ?propLabel" \
	> $(OUT_DIR)/wikidata-properties.tsv

.PHONY: entities
entities:
	@mkdir -p $(OUT_DIR)
	@curl -s https://qlever.cs.uni-freiburg.de/api/wikidata -H "Accept: text/tab-separated-values" -H "Content-type: application/sparql-query" --data "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX wikibase: <http://wikiba.se/ontology#> PREFIX schema: <http://schema.org/> PREFIX wdt: <http://www.wikidata.org/prop/direct/> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> SELECT ?entity ?entity_name (GROUP_CONCAT(DISTINCT ?alias; SEPARATOR = \"; \") AS ?aliases) (GROUP_CONCAT(DISTINCT ?instance_of; SEPARATOR = \"; \") AS ?instances) (GROUP_CONCAT(DISTINCT ?instance_name; SEPARATOR = \"; \") AS ?instance_names) ?sitelinks WHERE { ?entity ^schema:about/wikibase:sitelinks ?sitelinks . ?entity wdt:P18 ?pic . ?entity rdfs:label ?entity_name . FILTER (LANG(?entity_name) = \"en\") . ?entity wdt:P31 ?instance_of . ?instance_of rdfs:label ?instance_name . FILTER (LANG(?instance_name) = \"en\") . OPTIONAL { ?entity skos:altLabel ?alias . FILTER (LANG(?alias) = \"en\") } } GROUP BY ?entity ?entity_name ?sitelinks ORDER BY DESC(?sitelinks)" \
	> $(OUT_DIR)/wikidata-entities.tsv

.PHONY: download
download: properties entities

.PHONY: index
index: download