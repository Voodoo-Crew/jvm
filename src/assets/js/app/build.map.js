
function loadMap (url, MapContainer) {

  $.getJSON(url, function (data, textStatus) {

    var dataAll = data;
    var opts = {
        container: MapContainer
      , map:       'ukraine_provinces_mill_ru'
    };
    var odata = data.countries.ukraine;

    buildMap(opts, odata);

  }) // getJSON END
  .done(function () {
    console.info('getJSON.DONE');
  })
  .fail(function () {
    console.warn('getJSON.FAIL');
  })
  .always(function () {
    console.log('getJSON.FINALLY');
  });

};

function buildMap (lo, lod) {

  console.info('buildMap lo = [', lo, ']');
  console.info('buildMap lod = [', lod, ']');

  var objRegions = lod.regions || []
    , arrCities  = lod.cities  || [];

  var defo = {
      container:          '#container-map'
    , map:                'world_mill_en'
    , backgroundColor:    '#383f47'   // 'transparent'
    , hoverOpacity:       0.7
    , hoverColor:         false
    , regionsSelectable:  true
    , markersSelectable:  true
    , markerStyle: {
        initial: {
            r:      5
          , fill:   '#F8E23B'
          , stroke: '#383f47'
        }
      }
    , markers: arrCities
    , series: {
        markers: [
          {
            attribute:         'fill'
          , normalizeFunction: 'polynomial'
          , scale: [
              '#C8EEFF'
            , '#0071A4'
            ]
          , values: arrCities
          }
        , {
              attribute:         'r'
            , normalizeFunction: 'polynomial'
            , scale: [
                5
              , 10
              ]
            , values: _.pluck(arrCities, 'population') //arrCitizens
          }
        ]
      , regions: [{
            attribute:         'fill'
          , normalizeFunction: 'polynomial'    //  'polynomial' | 'linear'
          , scale: [
                '#5EAE9E'
              , '#25A0C5'
              , '#5B5BFF'
              , '#8D18AB'
              , '#B300B3'
              , '#D73E68'
              , '#FF2626'
            ]
          , values: objRegions
        }]
      }
    , onRegionLabelShow: function (e, el, code) {
        // el.html('[' + code + '] ' + el.html() + ': ' + objRegions[code] + 'pt');
        el.html('[' + code + '] ' + el.html());
      }
    , onMarkerLabelShow: function (event, label, index) {
        label.html(label.html() + ' [' + arrCities[index].latLng + ']' + '<br />' + 'Population: ' + arrCities[index].population + '.');
      }
  };

  var objMap = new jvm.WorldMap(_.extend(defo, lo));

  $('.btn-clear-regions').click(function () {
    objMap.clearSelectedRegions();
  });

  console.info('objMap = [', objMap, ']');

  return objMap;
};
