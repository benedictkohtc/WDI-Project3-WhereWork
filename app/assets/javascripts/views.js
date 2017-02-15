function initMap() {
  let user_lat
  let user_lng

  let types = [ "wifi", "aircon", "availsockets", "coffee", "quiet",
    "uncrowded" ]

  let filterstates = {}
  let all_locations = []
  let shown_locations = []
  let markers = []

  let map = new google.maps.Map( document.getElementById( 'listMap' ), {

    zoom: 16,
    center: { lat: 1.3072052, lng: 103.831843 },
    scaleControl: true,
    fullscreenControl: true
  } )
  let infoWindow = new google.maps.InfoWindow()

  let defaultBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng( 1.077484, 103.582585 ),
    new google.maps.LatLng( 1.490568, 104.093450 )
  )
  let options = {
    bounds: defaultBounds
  }
  let input = document.getElementById( 'pac-input' )
  map.controls[ google.maps.ControlPosition.TOP_CENTER ].push( input )
  let autocomplete = new google.maps.places.Autocomplete( input, options )

  function placeMarker( location ) {
    let latLng = new google.maps.LatLng( location[ 'lat' ], location[ 'lng' ] )
    let marker = new google.maps.Marker( {
      position: latLng,
      map: map
    } )
    google.maps.event.addListener( marker, 'click', function() {
      infoWindow.close()
      infoWindow.setContent( "<div id= 'infoWindow'>" +
        "<a href='/locations/" + location[ 'id' ] + "'>" + location[
          'name' ] + '</a>' + '</div>' )
      infoWindow.open( map, marker )
    } )
    markers.push( marker )
  };
  let userLocationInfoWindow = new google.maps.InfoWindow( { map: map } )

  if ( navigator.geolocation ) {
    navigator.geolocation.getCurrentPosition( function( position ) {
      user_lat = position.coords.latitude
      user_lng = position.coords.longitude
      let pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
      userLocationInfoWindow.setPosition( pos )
      userLocationInfoWindow.setContent( 'Your location' )
      map.setCenter( pos )
      $.ajax( {
        type: 'GET',
        url: '/locations/map_view',
        data: pos,
        contentType: 'application/json',
        dataType: 'json'
      } ).done( function( response ) {
        all_locations = response
        all_locations.forEach( location => {
          location[ 'availsockets' ] =
            location[ 'available_sockets' ] > 0 ? true : false
          console.log(location['availsockets'])
          location[ 'uncrowded' ] =
            location[ 'available_seats' ] /
            location[ 'total_seats' ] > 0.3 ? true : false
        } )
        updateFiltering()
      } )
    }, function() {
      handleLocationError( true, userLocationInfoWindow, map.getCenter() )
    } )
  } else {
    // Browser doesn't support Geolocation
    handleLocationError( false, userLocationInfoWindow, map.getCenter() )
  };

  // FILTERING CODE

  // adds listeners to each button

  $( document ).ready( function() {
    $( '#switch-views' ).click( function() {
      flipView()
    } )
    types.forEach( type => {
      $( '.button-' + type ).click( function() {
        flipFilter( type )
      } )
    } )
  } )

  // changes view from map to list or vice versa
  function flipView() {
    if ( $( '#listCards' ).hasClass( "hidden" ) ) {
      $( '#listCards' ).removeClass( "hidden" )
      $( '#listMap' ).addClass( "hidden" )
      $( '#switch-views' ).text( "Map View" )
    } else {
      $( '#listCards' ).addClass( "hidden" )
      $( '#listMap' ).removeClass( "hidden" )
      $( '#switch-views' ).text( "List View" )
    }
  }

  // generates cards from shown_locations and updates $listCards
  function updateCards() {
    $( '#listCards' ).empty()
    let cardslist = $( '<div></div>' )
    shown_locations.forEach( location => {
      let card = $( '<div></div>' )
      let imagelink = ''
      if (location['cloudinary_link'])      
        imagelink = `<img src=" ${location['cloudinary_link']} " alt='' class='img-responsive img-rounded center-block'>'`
      else
        imagelink = `<img src="http://placehold.it/300x300" alt="" class='img-responsive img-rounded center-block'>`
      let walktime = Math.floor(location['distance']/40) + 1
      let filtersString = ''
      if (location['wifi']) filtersString += 'wifi '
      if (location['aircon']) filtersString += 'aircon '
      if (location['availsockets']) filtersString += 'sockets '
      if (location['coffee']) filtersString += 'coffee '
      if (location['quiet']) filtersString += 'quiet '
      if (location['uncrowded']) filtersString += 'uncrowded '
      let distance = Math.floor(location['distance'])
      card.html(`
        <div class="well location-card row">
          <div class="col-xs-5 col-md-3 location-card-img">
            ${imagelink}
            <span class="label label-default">${walktime} min away</span>
          </div>
          <div class="col-xs-7 col-md-9">
          <h3> <a href="/locations/${location['id']}">${location['name']}</a> </h3>
          ${location['vicinity']}
          <br>
          ${filtersString}
          <hr>
          ${distance} metres away
          <hr>
          <p class="label label-default">${location['available_seats']} seats available</p>
          <p class="label label-default">${location['available_sockets']} sockets available</p>
          <hr>
          </div>
        </div>
        `)
      cardslist.append( card )
    } )
    $('#listCards').append(cardslist)
  }  

  // changes filterstates type
  function flipFilter( type ) {
    filterstates[ type ] = filterstates[ type ] === true ? false : true
    updateFiltering()
  }

  // updates the shown_locations array according to the filters
  function updateFiltering() {
    markers.forEach( marker => marker.setMap( null ) )
    markers = []
    shown_locations = all_locations.slice()
    types.forEach( type => {
      if ( filterstates[ type ] === true ) {
        $( '.button-' + type )
          .removeClass( 'btn-default' )
          .addClass( 'btn-primary' )
        shown_locations.forEach( ( location, ind, arr ) => {
          if ( location[ type ] === false ) {
            arr.splice( ind, 1 )
          }
        } )
      } else {
        $( '.button-' + type )
          .addClass( 'btn-default' )
          .removeClass( 'btn-primary' )
      }
    } )
    renderShownLocations()
  }

  function renderShownLocations() {
    // add markers to map
    shown_locations.forEach( location => placeMarker( location ) )
      // update cards
    updateCards()
  }

}

function handleLocationError( browserHasGeolocation, userLocationInfoWindow,
  pos ) {
  userLocationInfoWindow.setPosition( pos )
  userLocationInfoWindow.setContent( browserHasGeolocation ?
    'Error: Please allow your Geolocation service.' :
    'Error: Your browser doesn\'t support geolocation.' )
}