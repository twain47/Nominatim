@APIDB
Feature: Search queries
    Testing different queries and parameters

    Scenario: Simple XML search
        When sending xml search query "Schaan"
        Then result 0 has attributes place_id,osm_type,osm_id
        And result 0 has attributes place_rank,boundingbox
        And result 0 has attributes lat,lon,display_name
        And result 0 has attributes class,type,importance,icon
        And result 0 has not attributes address
        And result 0 has bounding box in 46.5,47.5,9,10

    Scenario: Simple JSON search
        When sending json search query "Vaduz"
        Then result 0 has attributes place_id,licence,icon,class,type
        And result 0 has attributes osm_type,osm_id,boundingbox
        And result 0 has attributes lat,lon,display_name,importance
        And result 0 has not attributes address
        And result 0 has bounding box in 46.5,47.5,9,10

    Scenario: JSON search with addressdetails
        When sending json search query "Montevideo" with address
        Then address of result 0 is
          | type         | value |
          | city         | Montevideo |
          | state        | Montevideo |
          | country      | Uruguay |
          | country_code | uy |

    Scenario: XML search with addressdetails
        When sending xml search query "Aleg" with address
        Then address of result 0 is
          | type         | value |
          | city         | Aleg |
          | state        | Brakna |
          | country      | Mauritania |
          | country_code | mr |

    Scenario: coordinate search with addressdetails
        When sending json search query "14.271104294939,107.69828796387"
        Then results contain
          | display_name |
          | Plei Ya Rê, Kon Tum province, Vietnam |

    Scenario: Address details with unknown class types
        When sending json search query "Hundeauslauf, Hamburg" with address
        Then results contain
          | ID | class   | type |
          | 0  | leisure | dog_park |
        And result addresses contain
          | ID | address29 |
          | 0  | Hundeauslauf |
        And address of result 0 has no types leisure,dog_park

    Scenario: Disabling deduplication
        When sending json search query "Sievekingsallee, Hamburg"
        Then there are no duplicates
        When sending json search query "Sievekingsallee, Hamburg"
          | dedupe |
          | 0 |
        Then there are duplicates

    Scenario: Search with bounded viewbox in right area
        When sending json search query "restaurant" with address
          | bounded | viewbox |
          | 1       | 9.93027,53.61634,10.10073,53.54500 |
        Then result addresses contain
          | state |
          | Hamburg |

    Scenario: Search with bounded viewboxlbrt in right area
        When sending json search query "restaurant" with address
          | bounded | viewboxlbrt |
          | 1       | 9.93027,53.54500,10.10073,53.61634 |
        Then result addresses contain
          | state |
          | Hamburg |

    Scenario: No POI search with unbounded viewbox
        When sending json search query "restaurant"
          | viewbox |
          | 9.93027,53.61634,10.10073,53.54500 |
        Then results contain
          | display_name |
          | ^[^,]*[Rr]estaurant.* |

    Scenario: bounded search remains within viewbox, even with no results
         When sending json search query "restaurant"
           | bounded | viewbox |
           | 1       | 43.5403125,-5.6563282,43.54285,-5.662003 |
        Then less than 1 result is returned

    Scenario: bounded search remains within viewbox with results
        When sending json search query "restaurant"
         | bounded | viewbox |
         | 1       | 9.93027,53.61634,10.10073,53.54500 |
        Then result has bounding box in 53.54500,53.61634,9.93027,10.10073

    Scenario: Prefer results within viewbox
        When sending json search query "25 de Mayo" with address
          | accept-language |
          | en |
        Then result addresses contain
          | ID | state |
          | 0  | Salto |
        When sending json search query "25 de Mayo" with address
          | accept-language | viewbox |
          | en              | -56.35879,-34.18330,-56.31618,-34.20815 |
        Then result addresses contain
          | ID | state |
          | 0  | Florida |

    Scenario: Overly large limit number for search results
        When sending json search query "restaurant"
          | limit |
          | 1000 |
        Then at most 50 results are returned

    Scenario: Limit number of search results
        When sending json search query "restaurant"
          | limit |
          | 4 |
        Then exactly 4 results are returned

    Scenario: Restrict to feature type country
        When sending xml search query "Uruguay"
        Then results contain
          | ID | place_rank |
          | 1  | 16 |
        When sending xml search query "Uruguay"
          | featureType |
          | country |
        Then results contain
          | place_rank |
          | 4 |

    Scenario: Restrict to feature type state
        When sending xml search query "Dakota"
        Then results contain
          | place_rank |
          | 12 |
        When sending xml search query "Dakota"
          | featureType |
          | state |
        Then results contain
          | place_rank |
          | 8 |

    Scenario: Restrict to feature type city
        When sending xml search query "vaduz"
        Then results contain
          | ID | place_rank |
          | 1  | 30 |
        When sending xml search query "vaduz"
          | featureType |
          | city |
        Then results contain
          | place_rank |
          | 16 |

    Scenario: Restrict to feature type settlement
        When sending json search query "Burg"
        Then results contain
          | ID | class |
          | 1  | amenity |
        When sending json search query "Burg"
          | featureType |
          | settlement |
        Then results contain
          | class    | type |
          | boundary | administrative | 

    Scenario Outline: Search with polygon threshold (json)
        When sending json search query "switzerland"
          | polygon_geojson | polygon_threshold |
          | 1               | <th> |
        Then at least 1 result is returned
        And result 0 has attributes geojson

     Examples:
        | th |
        | -1 |
        | 0.0 |
        | 0.5 |
        | 999 |

    Scenario Outline: Search with polygon threshold (xml)
        When sending xml search query "switzerland"
          | polygon_geojson | polygon_threshold |
          | 1               | <th> |
        Then at least 1 result is returned
        And result 0 has attributes geojson

     Examples:
        | th |
        | -1 |
        | 0.0 |
        | 0.5 |
        | 999 |

    Scenario Outline: Search with invalid polygon threshold (xml)
        When sending xml search query "switzerland"
          | polygon_geojson | polygon_threshold |
          | 1               | <th> |
        Then a HTTP 400 is returned

     Examples:
        | th |
        | x |
        | ;; |
        | 1m |

    Scenario Outline: Search with extratags
        When sending <format> search query "Hauptstr"
          | extratags |
          | 1 |
        Then result has attributes extratags

    Examples:
        | format |
        | xml |
        | json |
        | jsonv2 |

    Scenario Outline: Search with namedetails
        When sending <format> search query "Hauptstr"
          | namedetails |
          | 1 |
        Then result has attributes namedetails

    Examples:
        | format |
        | xml |
        | json |
        | jsonv2 |

    Scenario Outline: Search result with contains TEXT geometry
        When sending <format> search query "Highmore"
          | polygon_text |
          | 1 |
        Then result has attributes <response_attribute>

    Examples:
        | format   | response_attribute |
        | xml      | geotext |
        | json     | geotext |
        | jsonv2   | geotext |

    Scenario Outline: Search result contains polygon-as-points geometry
        When sending <format> search query "Highmore"
          | polygon |
          | 1 |
        Then result has attributes <response_attribute>

    Examples:
        | format   | response_attribute |
        | xml      | polygonpoints |
        | json     | polygonpoints |
        | jsonv2   | polygonpoints |

    Scenario Outline: Search result contains SVG geometry
        When sending <format> search query "Highmore"
          | polygon_svg |
          | 1 |
        Then result has attributes <response_attribute>

    Examples:
        | format   | response_attribute |
        | xml      | geosvg |
        | json     | svg |
        | jsonv2   | svg |

    Scenario Outline: Search result contains KML geometry
        When sending <format> search query "Highmore"
          | polygon_kml |
          | 1 |
        Then result has attributes <response_attribute>

    Examples:
        | format   | response_attribute |
        | xml      | geokml |
        | json     | geokml |
        | jsonv2   | geokml |

    Scenario Outline: Search result contains GEOJSON geometry
        When sending <format> search query "Highmore"
          | polygon_geojson |
          | 1 |
        Then result has attributes <response_attribute>

    Examples:
        | format   | response_attribute |
        | xml      | geojson |
        | json     | geojson |
        | jsonv2   | geojson |